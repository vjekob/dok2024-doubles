namespace Vjeko.Demos.Restaurant;

using Microsoft.Inventory.Item;

interface "DEMO Availability Base"
{
    procedure FilterItem(var Item: Record Item; LocationCode: Code[20]; VariantCode: Code[20]; Date: Date);
    procedure CalcAvailQuantities(var Item: Record Item; IsBalanceAtDate: Boolean; var GrossRequirement: Decimal; var PlannedOrderRcpt: Decimal; var ScheduledRcpt: Decimal; var PlannedOrderReleases: Decimal; var ProjAvailableBalance: Decimal; var ExpectedInventory: Decimal; var QtyAvailable: Decimal; var AvailableInventory: Decimal);
}
