namespace Vjeko.Demos.Restaurant.StockStalk;

using Vjeko.Demos.Restaurant;

interface "DEMO StockStalk Process Response"
{
    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry");
}
