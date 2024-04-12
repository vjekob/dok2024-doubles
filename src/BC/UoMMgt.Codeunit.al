namespace Vjeko.Demos.Restaurant.BC;

using Vjeko.Demos.Restaurant;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;

codeunit 50008 "DEMO UoM Mgt." implements "DEMO Unit of Measure"
{
    var
        UoMMgt: Codeunit "Unit of Measure Management";

    procedure GetQtyPerUnitOfMeasure(Item: Record Item; UnitOfMeasureCode: Code[10]) QtyPerUnitOfMeasure: Decimal
    begin
        exit(UoMMgt.GetQtyPerUnitOfMeasure(Item, UnitOfMeasureCode));
    end;

    procedure CalcBaseQty(ItemNo: Code[20]; VariantCode: Code[10]; UOMCode: Code[10]; QtyBase: Decimal; QtyPerUOM: Decimal): Decimal
    begin
        exit(UoMMgt.CalcBaseQty(ItemNo, VariantCode, UOMCode, QtyBase, QtyPerUOM));
    end;
}