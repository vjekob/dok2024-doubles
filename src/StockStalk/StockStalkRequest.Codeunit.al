namespace Vjeko.Demos.Restaurant.StockStalk;

using Vjeko.Demos.Restaurant;
using Microsoft.Inventory.Item;

codeunit 50006 "DEMO StockStalk Request"
{
    var
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

    procedure Create(var RecipeHeader: Record "DEMO Recipe Header"; Date: Date): Boolean
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

        SendToTelemetry('ST000', 'StockStalk request created', 'Usable', Format(_usable));
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

    procedure Send() Result: Boolean
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
        Result := ProcessRequest(Request);
    end;

    procedure Check() Result: Boolean
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
                exit(FailSilently('ST010', 'StockStalk request is already completed.'));
        end;

        PrepareGetMessage(Request);
        Result := ProcessRequest(Request);
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

    local procedure ProcessRequest(Request: HttpRequestMessage): Boolean
    var
        ResponseJson: JsonObject;
    begin
        if not SendAndUpdateState(Request, ResponseJson) then
            exit(false);

        ProcessResponse(ResponseJson);
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

    local procedure SendAndUpdateState(Request: HttpRequestMessage; var ResponseJson: JsonObject): Boolean
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        if not Client.Send(Request, Response) then
            exit(FailSilently('ST001', 'Failed to send request to StockStalk', 'Error', GetLastErrorText()));

        SendToTelemetry('ST007', 'StockStalk request sent.');

        if not ProcessResponseMessage(Response, ResponseJson) then
            exit(false);

        UpdateStatus(ResponseJson);
        if _status <> "DEMO StockStalk Request Status"::Completed then
            ConfigureAwaitTime(Response);

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

        SendToTelemetry('ST006', 'StockStalk POST request prepared.');
    end;

    local procedure PrepareGetMessage(Request: HttpRequestMessage)
    begin
        InitializeRequest(Request, 'GET', _requestId);
        Authorize(Request);

        SendToTelemetry('ST011', 'StockStalk GET request prepared.');
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

    local procedure ProcessResponseMessage(Response: HttpResponseMessage; var ResponseJson: JsonObject): Boolean
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
            Response.Content.ReadAs(ResponseText);
            ResponseJson.ReadFrom(ResponseText);
            SendToTelemetry('ST012', 'StockStalk response received', 'Body', ResponseText);
            exit(true);
        end;

        // Checking ahead because we do not need the response text.
        if Response.HttpStatusCode = 401 then
            Error(UnauthorizedErr);

        // Any status not expected from StockStalk API is considered an error
        if not (Response.HttpStatusCode in [400, 404, 410, 429]) then
            Error(UnexpectedStatusCodeErr, Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content.ReadAs(ResponseText);

        case Response.HttpStatusCode of
            400: // Bad request (error in syntax or request content)
                Error(BadRequestErr, ResponseText);
            404: // Not found (StockStalk doesn't recognize the request ID)
                begin
                    _status := "DEMO StockStalk Request Status"::Completed;
                    exit(FailSilently('ST002', 'StockStalk returned 404 Not Found.'));
                end;
            410: // Gone (StockStalk request is expired)
                begin
                    _status := "DEMO StockStalk Request Status"::Completed;
                    exit(FailSilently('ST003', 'StockStalk returned 410 Gone.'));
                end;
            429: // Too many requests (sending request before time indicated by StockStalk)
                begin
                    ConfigureAwaitTime(Response);
                    SendToTelemetry('ST004', 'StockStalk returned 429 Too Many Requests. Check your implementation.');
                    exit(true);
                end;
        end;
    end;

    local procedure ConfigureAwaitTime(Response: HttpResponseMessage)
    var
        Headers: HttpHeaders;
        RetryAfterTexts: array[1] of Text;
        RetryAfter: Integer;
    begin
        _nextRequestAt := CurrentDateTime() + 1000;

        if not Response.Headers.Contains('Retry-After') then
            exit;
        if not Response.Headers.GetValues('Retry-After', RetryAfterTexts) then
            exit;

        if not Evaluate(RetryAfter, RetryAfterTexts[1]) then
            exit;

        _nextRequestAt := CurrentDateTime() + RetryAfter * 1000;
    end;

    local procedure UpdateStatus(ResponseJson: JsonObject)
    var
        Token: JsonToken;
        Value: JsonValue;
        Status: Text;
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

        Status := Token.AsValue().AsText();
        case Status of
            'created':
                NewStatus := "DEMO StockStalk Request Status"::Created;
            'pending':
                NewStatus := "DEMO StockStalk Request Status"::Pending;
            'processing':
                NewStatus := "DEMO StockStalk Request Status"::Processing;
            'completed':
                NewStatus := "DEMO StockStalk Request Status"::Completed;
            else
                Error(UnknownStatusErr, Status);
        end;

        if NewStatus = _status then
            exit;

        SendToTelemetry('ST005', 'StockStalk request status updated', 'Status', Status);
        _status := NewStatus;
    end;

    local procedure ProcessResponse(ResponseJson: JsonObject)
    var
        Token: JsonToken;
        MissingRequestIdErr: Label 'Unexpected response from StockStalk: request ID missing. Please, contact your administrator or switch off StockStalk.';
        MissingItemsErr: Label 'Unexpected response from StockStalk: items array missing. Please, contact your administrator or switch off StockStalk.';
    begin
        case _status of
            "DEMO StockStalk Request Status"::Created:
                begin
                    if not ResponseJson.Get('requestId', Token) then
                        Error(MissingRequestIdErr);
                    if not Token.IsValue() then
                        Error(MissingRequestIdErr);
                    if Token.AsValue().IsNull() then
                        Error(MissingRequestIdErr);

                    _requestId := Token.AsValue().AsText();

                    SendToTelemetry('ST008', 'StockStalk request ID received', 'RequestId', _requestId);
                end;
            "DEMO StockStalk Request Status"::Completed:
                begin
                    if not ResponseJson.Get('items', Token) then
                        exit;
                    if not Token.IsArray() then
                        Error(MissingItemsErr);
                    _response := Token.AsArray();

                    SendToTelemetry('ST009', 'StockStalk response completed', 'Items', Format(_response.Count));
                end;
        end;
    end;

    local procedure FailSilently(EventId: Text; Msg: Text): Boolean
    begin
        SendToTelemetry(EventId, Msg);
        exit(false); // Unneeded, but clarifies the intention
    end;

    local procedure FailSilently(EventId: Text; Msg: Text; DimensionKey: Text; DimensionValue: Text): Boolean
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add(DimensionKey, DimensionValue);
        SendToTelemetry(EventId, Msg, Dimensions);
        exit(false); // Unneeded, but clarifies the intention
    end;

    local procedure SendToTelemetry(EventId: Text; Msg: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        SendToTelemetry(EventId, Msg, Dimensions);
    end;

    local procedure SendToTelemetry(EventId: Text; Msg: Text; DimensionKey: Text; DimensionValue: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add(DimensionKey, DimensionValue);
        SendToTelemetry(EventId, Msg, Dimensions);
    end;

    local procedure SendToTelemetry(EventId: Text; Msg: Text; Dimensions: Dictionary of [Text, Text])
    begin
        Dimensions.Add('StockStalkRequestId', _requestId);
        Dimensions.Add('Id', Format(_id));
        Session.LogMessage(EventId, Msg, Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, Dimensions);
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
