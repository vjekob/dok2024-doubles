namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant.StockStalk;
using Vjeko.Demos.Restaurant;

codeunit 60011 "DEMO Mock StockStalk ProcResp" implements "DEMO StockStalk Process Response"
{
    var
        _setValue_requestId: Text;

    procedure ProcessResponse(ResponseJson: JsonObject; var RequestId: Text; var Response: JsonArray; Telemetry: Interface "DEMO Telemetry")
    begin
        RequestId := _setValue_requestId;
    end;

    procedure SetValue_RequestId(RequestId: Text)
    begin
        _setValue_requestId := RequestId;
    end;
}
