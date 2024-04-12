namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;
using Microsoft.Inventory.Item;

codeunit 60005 "DEMO Stub Unit of Measure" implements "DEMO Unit of Measure"
{
    procedure GetQtyPerUnitOfMeasure(Item: Record Item; UnitOfMeasureCode: Code[10]) QtyPerUnitOfMeasure: Decimal
    begin
        exit(1);
    end;

    procedure CalcBaseQty(ItemNo: Code[20]; VariantCode: Code[10]; UOMCode: Code[10]; QtyBase: Decimal; QtyPerUOM: Decimal): Decimal
    begin
        exit(QtyBase * QtyPerUOM);
    end;
}