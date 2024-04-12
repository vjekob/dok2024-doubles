namespace Vjeko.Demos.Restaurant.StockStalk;

using Vjeko.Demos.Restaurant;
using Microsoft.Inventory.Item;

codeunit 50006 "DEMO StockStalk Request"
{
    var
        _telemetry: Interface "DEMO Telemetry";
        _telemetryDimensions: Codeunit "DEMO StockStalk Telemetry Dims";
        _items: JsonArray;
        _date: Date;
        _response: JsonArray;
        _id: Guid;
        _url: Text;
        _apiKey: Text;
        _requestId: Text;
        _status: Enum "DEMO StockStalk Request Status";
        _created: Boolean;
        _usable: Boolean;
        _nextRequestAt: DateTime;

    procedure Create(var RecipeHeader: Record "DEMO Recipe Header"; Date: Date; Telemetry: Interface "DEMO Telemetry"): Boolean
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
        RecipeHeader2: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        Item: Record Item;
        ItemJson: JsonObject;
        AlreadyCreatedErr: Label 'StockStalk request is already created.';
    begin
        if _created then
            Error(AlreadyCreatedErr);

        _created := true;
        _date := Date;
        _telemetry := Telemetry;
        _telemetry.Initialize(_telemetryDimensions);

        if not RestaurantSetup.Get() then
            exit(false);

        if not RestaurantSetup."Use StockStalk" then
            exit(false);

        RestaurantSetup.TestField("StockStalk URL");
        _apiKey := RestaurantSetup.GetStockStalkAPIKey();
        _url := RestaurantSetup."StockStalk URL";
        if not _url.EndsWith('/') then
            _url := _url + '/';

        RecipeHeader2.CopyFilters(RecipeHeader);
        if not RecipeHeader2.FindSet(false) then
            exit(false);

        _id := CreateGuid();
        _telemetryDimensions.SetId(_id);

        repeat
            RecipeLine.SetRange("Recipe No.", RecipeHeader2."No.");
            if RecipeLine.FindSet(false) then
                repeat
                    if Item.Get(RecipeLine."Item No.") and (Item."DEMO StockStalk Item ID" <> '') then begin
                        Clear(ItemJson);
                        ItemJson.Add('itemId', Item."DEMO StockStalk Item ID");
                        ItemJson.Add('uom', LowerCase(RecipeLine."Unit of Measure Code"));
                        ItemJson.Add('quantity', RecipeLine.Quantity);
                        _items.Add(ItemJson);
                        _status := "DEMO StockStalk Request Status"::Ready;
                        _usable := true;
                    end;
                until RecipeLine.Next() = 0;
        until RecipeHeader2.Next() = 0;

        TElemetry.SendToTelemetry('ST000', 'StockStalk request created', 'Usable', Format(_usable));
        exit(_usable);
    end;

    procedure ProcessAvailability(var TempAvailability: Record "DEMO StockStalk Avail. Buffer" temporary)
    var
        Item: Record Item;
        Token: JsonToken;
        RequestNotCompletedErr: Label 'StockStalk request is not completed. Please call Check() first.';
        UnexpectedTokenErr: Label 'Unexpected token in StockStalk response. Please, contact your administrator or switch off StockStalk.';
    begin
        if _status <> "DEMO StockStalk Request Status"::Completed then
            Error(RequestNotCompletedErr);

        TempAvailability.Reset();
        TempAvailability.DeleteAll();

        foreach Token in _response do begin
            if not Token.IsObject() then
                Error(UnexpectedTokenErr);

            UpdateValueFromToken(Token, 'itemId', TempAvailability."StockStalk Id");
            UpdateValueFromToken(Token, 'uom', TempAvailability."Unit of Measure Code");
            UpdateValueFromToken(Token, 'quantity', TempAvailability.Quantity);
            TempAvailability.Insert();
        end;
    end;

    procedure IsUsable(): Boolean
    begin
        exit(_usable);
    end;

    procedure Status(): Enum "DEMO StockStalk Request Status"
    begin
        exit(_status);
    end;

    procedure Send(Client: Interface "DEMO HttpClient") Result: Boolean
    var
        Request: HttpRequestMessage;
        ResponseJson: JsonObject;
        RequestAlreadySentErr: Label 'StockStalk request is already sent.';
    begin
        MakeSureIsCreated();
        MakeSureIsUsable();

        if _status <> "DEMO StockStalk Request Status"::Ready then
            Error(RequestAlreadySentErr);

        PreparePostMessage(Request);
        Result := ProcessRequest(Request, Client, _telemetry);
    end;

    procedure Check(Client: Interface "DEMO HttpClient") Result: Boolean
    var
        Request: HttpRequestMessage;
        RequestNotSentErr: Label 'StockStalk request is not sent. Please call Send() first.';
    begin
        MakeSureIsCreated();
        MakeSureIsUsable();

        case _status of
            "DEMO StockStalk Request Status"::Ready:
                Error(RequestNotSentErr);
            "DEMO StockStalk Request Status"::Completed:
                exit(FailSilently('ST010', 'StockStalk request is already completed.', _telemetry));
        end;

        PrepareGetMessage(Request);
        Result := ProcessRequest(Request, Client, _telemetry);
    end;

    procedure AwaitNextRetry()
    var
        SleepTime: Integer;
    begin
        SleepTime := _nextRequestAt - CurrentDateTime();
        if SleepTime < 0 then
            exit;

        // Sleep time should never be longer than 5 seconds, as per StockStalk API documentation
        if SleepTime > 5000 then
            SleepTime := 5000;

        Sleep(SleepTime);
    end;

    local procedure ProcessRequest(Request: HttpRequestMessage; Client: Interface "DEMO HttpClient"; Telemetry: Interface "DEMO Telemetry"): Boolean
    var
        ResponseJson: JsonObject;
    begin
        if not SendAndUpdateState(Request, ResponseJson, Client, Telemetry) then
            exit(false);

        ProcessResponse(ResponseJson, _requestId, _response, _status, Telemetry);
        exit(true);
    end;

    local procedure MakeSureIsCreated()
    var
        NotCreatedErr: Label 'StockStalk request is not created. Please call Create() first.';
    begin
        if not _created then
            Error(NotCreatedErr);
    end;

    local procedure MakeSureIsUsable()
    var
        NotUsableErr: Label 'StockStalk request is not usable. Make sure to call Create() first and inspect its return value. Alternatively, check IsUsable().';
    begin
        if not _usable then
            Error(NotUsableErr);
    end;

    internal procedure SendAndUpdateState(Request: HttpRequestMessage; var ResponseJson: JsonObject; Client: Interface "DEMO HttpClient"; Telemetry: Interface "DEMO Telemetry"): Boolean
    var
        Response: Interface "DEMO HttpResponse";
    begin
        if not Client.Send(Request, Response) then
            exit(FailSilently('ST001', 'Failed to send request to StockStalk', 'Error', GetLastErrorText(), Telemetry));

        Telemetry.SendToTelemetry('ST007', 'StockStalk request sent.');

        if not ProcessResponseMessage(Response, ResponseJson, _status, Telemetry) then
            exit(false);

        UpdateStatus(ResponseJson, _status, Telemetry);
        if _status <> "DEMO StockStalk Request Status"::Completed then
            ConfigureAwaitTime(Response, _nextRequestAt);

        exit(true);
    end;

    local procedure PreparePostMessage(Request: HttpRequestMessage)
    var
        Headers: HttpHeaders;
        Content: HttpContent;
        Items: Text;
    begin
        InitializeRequest(Request, 'POST', '');
        Authorize(Request);

        _items.WriteTo(Items);
        Content.WriteFrom(Items);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        Request.Content := Content;

        _telemetry.SendToTelemetry('ST006', 'StockStalk POST request prepared.');
    end;

    local procedure PrepareGetMessage(Request: HttpRequestMessage)
    begin
        InitializeRequest(Request, 'GET', _requestId);
        Authorize(Request);

        _telemetry.SendToTelemetry('ST011', 'StockStalk GET request prepared.');
    end;

    local procedure InitializeRequest(Request: HttpRequestMessage; Method: Text; Path: Text)
    var
        Url: Text;
    begin
        Url := _url + 'request';
        if Path <> '' then
            Url := Url + '/' + Path;

        Request.Method := Method;
        Request.SetRequestUri(Url);
    end;

    local procedure Authorize(Request: HttpRequestMessage)
    var
        Headers: HttpHeaders;
    begin
        Request.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('X-Functions-Key', _apiKey);
    end;

    internal procedure ProcessResponseMessage(Response: Interface "DEMO HttpResponse"; var ResponseJson: JsonObject; var Status: Enum "DEMO StockStalk Request Status"; Telemetry: Interface "DEMO Telemetry"): Boolean
    var
        ResponseText: Text;
        BlockedByEnvironmentErr: Label 'StockStalk request is blocked by environment. Please, check your configuration or contact your administrator.';
        UnexpectedStatusCodeErr: Label 'Unexpected status %1 %2 received from StockStalk. Please retry, contact your administrator, or switch off StockStalk.', Comment = '%1 is the status code, %2 is the reason phrase.';
        UnauthorizedErr: Label 'Unauthorized access to StockStalk. Please, check your configuration, contact your administrator, or switch off StockStalk.';
        BadRequestErr: Label 'Bad request to StockStalk: %1. Please contact your administrator, or switch off StockStalk.', Comment = '%1 is the response text.';
    begin
        if Response.IsBlockedByEnvironment then
            Error(BlockedByEnvironmentErr);

        // Intentionally not checking IsSuccesStatusCode. StockStalk responds with 200, every other 200-range status is unexpected and thus invalid
        if Response.HttpStatusCode = 200 then begin
            ResponseJson.ReadFrom(Response.GetContent());
            Telemetry.SendToTelemetry('ST012', 'StockStalk response received', 'Body', ResponseText);
            exit(true);
        end;

        // Checking ahead because we do not need the response text.
        if Response.HttpStatusCode = 401 then
            Error(UnauthorizedErr);

        // Any status not expected from StockStalk API is considered an error
        if not (Response.HttpStatusCode in [400, 404, 410, 429]) then
            Error(UnexpectedStatusCodeErr, Response.HttpStatusCode, Response.ReasonPhrase);

        ResponseText := Response.GetContent();

        case Response.HttpStatusCode of
            400: // Bad request (error in syntax or request content)
                Error(BadRequestErr, ResponseText);
            404: // Not found (StockStalk doesn't recognize the request ID)
                begin
                    Status := "DEMO StockStalk Request Status"::Completed;
                    exit(FailSilently('ST002', 'StockStalk returned 404 Not Found.', Telemetry));
                end;
            410: // Gone (StockStalk request is expired)
                begin
                    Status := "DEMO StockStalk Request Status"::Completed;
                    exit(FailSilently('ST003', 'StockStalk returned 410 Gone.', Telemetry));
                end;
            429: // Too many requests (sending request before time indicated by StockStalk)
                begin
                    ConfigureAwaitTime(Response, _nextRequestAt);
                    Telemetry.SendToTelemetry('ST004', 'StockStalk returned 429 Too Many Requests. Check your implementation.');
                    exit(true);
                end;
        end;
    end;

    internal procedure ConfigureAwaitTime(Response: Interface "DEMO HttpResponse"; var NextRequestAt: DateTime)
    var
        Headers: HttpHeaders;
        RetryAfterTexts: array[1] of Text;
        RetryAfter: Integer;
    begin
        _nextRequestAt := CurrentDateTime() + 1000;

        if not Response.GetHeaders().Contains('Retry-After') then
            exit;
        if not Response.GetHeaders().GetValues('Retry-After', RetryAfterTexts) then
            exit;

        if not Evaluate(RetryAfter, RetryAfterTexts[1]) then
            exit;

        NextRequestAt := CurrentDateTime() + RetryAfter * 1000;
    end;

    internal procedure UpdateStatus(ResponseJson: JsonObject; var Status: Enum "DEMO StockStalk Request Status"; Telemetry: Interface "DEMO Telemetry")
    var
        Token: JsonToken;
        Value: JsonValue;
        StatusText: Text;
        NewStatus: Enum "DEMO StockStalk Request Status";
        MissingStatusErr: Label 'Unexpected response from StockStalk: status missing. Please, contact your administrator or switch off StockStalk.';
        UnknownStatusErr: Label 'Unknown status "%1" received from StockStalk. Please, contact your administrator or switch off StockStalk.', Comment = '%1 is the status received from StockStalk.';
    begin
        if not ResponseJson.Get('status', Token) then
            Error(MissingStatusErr);
        if not Token.IsValue() then
            Error(MissingStatusErr);
        if Token.AsValue().IsNull then
            Error(MissingStatusErr);

        StatusText := Token.AsValue().AsText();
        case StatusText of
            'created':
                NewStatus := "DEMO StockStalk Request Status"::Created;
            'pending':
                NewStatus := "DEMO StockStalk Request Status"::Pending;
            'processing':
                NewStatus := "DEMO StockStalk Request Status"::Processing;
            'completed':
                NewStatus := "DEMO StockStalk Request Status"::Completed;
            else
                Error(UnknownStatusErr, StatusText);
        end;

        if NewStatus = Status then
            exit;

        Telemetry.SendToTelemetry('ST005', 'StockStalk request status updated', 'Status', StatusText);
        Status := NewStatus;
    end;

    internal procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Process: Interface "DEMO StockStalk Process Response"; Telemetry: Interface "DEMO Telemetry")
    var
        OldRequestId, NewRequestId : Text;
    begin
        OldRequestId := _requestId;
        Process.ProcessResponse(ResponseJson, NewRequestId, Response, Telemetry);
        if NewRequestId = OldRequestId then
            exit;

        RequestId := NewRequestId;
        _telemetryDimensions.SetRequestId(_requestId);
    end;

    local procedure FailSilently(EventId: Text; Msg: Text; Telemetry: Interface "DEMO Telemetry"): Boolean
    begin
        Telemetry.SendToTelemetry(EventId, Msg);
        exit(false); // Unneeded, but clarifies the intention
    end;

    local procedure FailSilently(EventId: Text; Msg: Text; DimensionKey: Text; DimensionValue: Text; Telemetry: Interface "DEMO Telemetry"): Boolean
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add(DimensionKey, DimensionValue);
        Telemetry.SendToTelemetry(EventId, Msg, Dimensions);
        exit(false); // Unneeded, but clarifies the intention
    end;

    local procedure UpdateValueFromToken(Token: JsonToken; Field: Text; var Value: Text)
    begin
        Value := GetValueFromToken(Token, Field).AsText();
    end;

    local procedure UpdateValueFromToken(Token: JsonToken; Field: Text; var Value: Code[10])
    begin
        Value := GetValueFromToken(Token, Field).AsCode();
    end;

    local procedure UpdateValueFromToken(Token: JsonToken; Field: Text; var Value: Decimal)
    begin
        Value := GetValueFromToken(Token, Field).AsDecimal();
    end;

    local procedure GetValueFromToken(Token: JsonToken; Field: Text): JsonValue
    var
        Entry: JsonObject;
        InvalidTokenErr: Label 'Invalid token %1 in StockStalk response. Please, contact your administrator or switch off StockStalk.', Comment = '%1 is the key to read from StockStalk response.';
    begin
        Entry := Token.AsObject();
        if not Entry.Contains(Field) then
            Error(InvalidTokenErr, Field);
        if not Entry.Get(Field, Token) then
            Error(InvalidTokenErr, Field);
        if not Token.IsValue() then
            Error(InvalidTokenErr, Field);
        if Token.AsValue().IsNull() then
            Error(InvalidTokenErr, Field);

        exit(Token.AsValue());
    end;
}
