namespace Vjeko.Demos.Restaurant.StockStalk;
using Vjeko.Demos.Restaurant;

codeunit 50022 "DEMO StockStalk Telemetry Dims" implements "DEMO Telemetry Dimensions"
{
    var
        _requestId: Text;
        _id: Guid;

    procedure SetRequestId(RequestId: Text)
    begin
        RequestId := RequestId;
    end;

    procedure SetId(Id: Guid)
    begin
        _id := Id;
    end;

    procedure PopulateDimensions(Dimensions: Dictionary of [Text, Text])
    begin
        Dimensions.Add('StockStalkRequestId', _requestId);
        Dimensions.Add('Id', Format(_id));
    end;
}