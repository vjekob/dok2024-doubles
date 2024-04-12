namespace Vjeko.Demos.Restaurant;

using Microsoft.Inventory.Item;

interface "DEMO Unit of Measure"
{
    procedure GetQtyPerUnitOfMeasure(Item: Record Item; UnitOfMeasureCode: Code[10]) QtyPerUnitOfMeasure: Decimal;
    procedure CalcBaseQty(ItemNo: Code[20]; VariantCode: Code[10]; UOMCode: Code[10]; QtyBase: Decimal; QtyPerUOM: Decimal): Decimal;
}
