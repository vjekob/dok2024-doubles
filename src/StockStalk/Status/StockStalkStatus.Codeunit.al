namespace Vjeko.Demos.Restaurant.StockStalk;
using Vjeko.Demos.Restaurant;

codeunit 50015 "DEMO StockStalk Uninitialized" implements "DEMO StockStalk Status Handler"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry")
    begin

    end;
}

codeunit 50016 "DEMO StockStalk Ready" implements "DEMO StockStalk Status Handler"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry")
    begin

    end;
}

codeunit 50017 "DEMO StockStalk Created" implements "DEMO StockStalk Status Handler"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry")
    var
        Token: JsonToken;
        MissingRequestIdErr: Label 'Unexpected response from StockStalk: request ID missing. Please, contact your administrator or switch off StockStalk.';
    begin
        if not ResponseJson.Get('requestId', Token) then
            Error(MissingRequestIdErr);
        if not Token.IsValue() then
            Error(MissingRequestIdErr);
        if Token.AsValue().IsNull() then
            Error(MissingRequestIdErr);

        RequestId := Token.AsValue().AsText();

        Telemetry.SendToTelemetry('ST008', 'StockStalk request ID received', 'RequestId', RequestId);
    end;
}

codeunit 50018 "DEMO StockStalk Pending" implements "DEMO StockStalk Status Handler"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry")
    begin

    end;
}

codeunit 50019 "DEMO StockStalk Processing" implements "DEMO StockStalk Status Handler"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry")
    begin

    end;
}

codeunit 50020 "DEMO StockStalk Completed" implements "DEMO StockStalk Status Handler"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry")
    var
        Token: JsonToken;
        MissingItemsErr: Label 'Unexpected response from StockStalk: items array missing. Please, contact your administrator or switch off StockStalk.';
    begin
        if not ResponseJson.Get('items', Token) then
            exit;
        if not Token.IsArray() then
            Error(MissingItemsErr);
        response := Token.AsArray();

        Telemetry.SendToTelemetry('ST009', 'StockStalk response completed', 'Items', Format(Response.Count));
    end;
}
