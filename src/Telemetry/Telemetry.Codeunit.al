namespace Vjeko.Demos.Restaurant;

codeunit 50021 "DEMO Telemetry" implements "DEMO Telemetry"
{
    var
        _dimensions: Interface "DEMO Telemetry Dimensions";

    procedure Initialize(Dimensions: Interface "DEMO Telemetry Dimensions")
    begin
        _dimensions := Dimensions;
    end;

    procedure SendToTelemetry(EventId: Text; Msg: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        SendToTelemetry(EventId, Msg, Dimensions);
    end;

    procedure SendToTelemetry(EventId: Text; Msg: Text; DimensionKey: Text; DimensionValue: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add(DimensionKey, DimensionValue);
        SendToTelemetry(EventId, Msg, Dimensions);
    end;

    procedure SendToTelemetry(EventId: Text; Msg: Text; Dimensions: Dictionary of [Text, Text])
    begin
        _dimensions.PopulateDimensions(Dimensions);
        Session.LogMessage(EventId, Msg, Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, Dimensions);
    end;
}
