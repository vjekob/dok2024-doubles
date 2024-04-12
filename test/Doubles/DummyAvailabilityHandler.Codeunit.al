namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60004 "DEMO Dummy Avail. Handler" implements "DEMO Availability Handler"
{
    procedure Initialize(var Recipe: Record "DEMO Recipe Header"; Date: Date)
    begin
        // Does nothing
    end;

    procedure GetAvailableQty(ItemNo: Code[20]): Decimal
    begin
        // Does nothing
    end;
}
