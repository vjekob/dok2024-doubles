namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60013 "DEMO Spy Telemetry" implements "DEMO Telemetry"
{
    procedure Initialize(Dimensions: Interface "DEMO Telemetry Dimensions")
    begin

    end;

    var
        _isInvoked_SendToTelemetry: Boolean;
        _isInvoked_SendToTelemetry_EventId: Text;

    procedure SendToTelemetry(EventId: Text; Msg: Text)
    begin
        _isInvoked_SendToTelemetry := true;
        _isInvoked_SendToTelemetry_EventId := EventId;
    end;

    procedure SendToTelemetry(EventId: Text; Msg: Text; Dimensions: Dictionary of [Text, Text])
    begin
        _isInvoked_SendToTelemetry := true;
        _isInvoked_SendToTelemetry_EventId := EventId;
    end;

    procedure SendToTelemetry(EventId: Text; Msg: Text; DimensionKey: Text; DimensionValue: Text)
    begin
        _isInvoked_SendToTelemetry := true;
        _isInvoked_SendToTelemetry_EventId := EventId;
    end;

    procedure IsInvoked_SendToTelemetry(): Boolean
    begin
        exit(_isInvoked_SendToTelemetry);
    end;

    procedure IsInvoked_SendToTelemetry_EventId(): Text
    begin
        exit(_isInvoked_SendToTelemetry_EventId);
    end;
}
