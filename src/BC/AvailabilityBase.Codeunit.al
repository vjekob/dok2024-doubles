namespace Vjeko.Demos.Restaurant.BC;

using Vjeko.Demos.Restaurant;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Availability;

codeunit 50009 "DEMO Availability Base" implements "DEMO Availability Base"
{
    var
        AvailabilityMgt: Codeunit "Item Availability Forms Mgt";

    procedure FilterItem(var Item: Record Item; LocationCode: Code[20]; VariantCode: Code[20]; Date: Date)
    begin
        AvailabilityMgt.FilterItem(Item, LocationCode, VariantCode, Date);
    end;

    procedure CalcAvailQuantities(var Item: Record Item; IsBalanceAtDate: Boolean; var GrossRequirement: Decimal; var PlannedOrderRcpt: Decimal; var ScheduledRcpt: Decimal; var PlannedOrderReleases: Decimal; var ProjAvailableBalance: Decimal; var ExpectedInventory: Decimal; var QtyAvailable: Decimal; var AvailableInventory: Decimal)
    begin
        AvailabilityMgt.CalcAvailQuantities(Item, IsBalanceAtDate, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable, AvailableInventory);
    end;
}
