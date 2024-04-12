namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60012 "DEMO Dummy Telemetry" implements "DEMO Telemetry"
{
    procedure Initialize(Dimensions: Interface "DEMO Telemetry Dimensions")
    begin

    end;

    procedure SendToTelemetry(EventId: Text; Msg: Text)
    begin

    end;

    procedure SendToTelemetry(EventId: Text; Msg: Text; Dimensions: Dictionary of [Text, Text])
    begin

    end;

    procedure SendToTelemetry(EventId: Text; Msg: Text; DimensionKey: Text; DimensionValue: Text)
    begin

    end;
}
