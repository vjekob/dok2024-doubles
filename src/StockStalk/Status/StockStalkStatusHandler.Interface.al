namespace Vjeko.Demos.Restaurant.StockStalk;

using Vjeko.Demos.Restaurant;

interface "DEMO StockStalk Status Handler"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry");
}
