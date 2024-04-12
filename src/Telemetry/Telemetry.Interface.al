namespace Vjeko.Demos.Restaurant;

interface "DEMO Telemetry"
{
    procedure Initialize(Dimensions: Interface "DEMO Telemetry Dimensions");
    procedure SendToTelemetry(EventId: Text; Msg: Text);
    procedure SendToTelemetry(EventId: Text; Msg: Text; Dimensions: Dictionary of [Text, Text]);
    procedure SendToTelemetry(EventId: Text; Msg: Text; DimensionKey: Text; DimensionValue: Text);
}
