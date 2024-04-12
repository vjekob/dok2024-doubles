namespace Vjeko.Demos.Restaurant.StockStalk;

using Vjeko.Demos.Restaurant;

codeunit 50024 "DEMO StockStalk Resp. Compl." implements "DEMO StockStalk Process Response"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry")
    var
        Token: JsonToken;
        MissingItemsErr: Label 'Unexpected response from StockStalk: items array missing. Please, contact your administrator or switch off StockStalk.';
    begin
        if not ResponseJson.Get('items', Token) then
            Error(MissingItemsErr);
        if not Token.IsArray() then
            Error(MissingItemsErr);
        response := Token.AsArray();

        Telemetry.SendToTelemetry('ST009', 'StockStalk response completed', 'Items', Format(Response.Count));
    end;
}
