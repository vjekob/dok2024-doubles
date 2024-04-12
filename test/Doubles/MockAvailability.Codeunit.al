namespace Vjeko.Demos.Restaurant;

using Microsoft.Inventory.Item;

codeunit 60006 "DEMO Mock Availability" implements "DEMO Availability Base"
{
    var
        _availability: Dictionary of [Code[20], Decimal];

    procedure CreateInventory(RecipeLine: Record "DEMO Recipe Line")
    begin
        _availability.Add(RecipeLine."Item No.", RecipeLine.Quantity);
    end;

    procedure CreateInventory(RecipeLine: Record "DEMO Recipe Line"; QtyFactor: Decimal)
    begin
        _availability.Add(RecipeLine."Item No.", RecipeLine.Quantity * QtyFactor);
    end;

    procedure FilterItem(var Item: Record Item; LocationCode: Code[20]; VariantCode: Code[20]; Date: Date)
    begin
        // Nothing to do
    end;

    procedure CalcAvailQuantities(var Item: Record Item; IsBalanceAtDate: Boolean; var GrossRequirement: Decimal; var PlannedOrderRcpt: Decimal; var ScheduledRcpt: Decimal; var PlannedOrderReleases: Decimal; var ProjAvailableBalance: Decimal; var ExpectedInventory: Decimal; var QtyAvailable: Decimal; var AvailableInventory: Decimal)
    begin
        if _availability.ContainsKey(Item."No.") then
            AvailableInventory := _availability.Get(Item."No.")
        else
            AvailableInventory := 0;
    end;
}