namespace Vjeko.Demos.Restaurant.StockStalk;

using Vjeko.Demos.Restaurant;

codeunit 50023 "DEMO StockStalk Resp. Created" implements "DEMO StockStalk Process Response"
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
