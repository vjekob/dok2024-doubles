namespace Vjeko.Demos.Restaurant.StockStalk;

using Vjeko.Demos.Restaurant;

codeunit 50025 "DEMO StockStalk Resp. None" implements "DEMO StockStalk Process Response"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry")
    begin
        // Nothing to do
    end;
}
