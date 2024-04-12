namespace Vjeko.Demos.Restaurant;

using Microsoft.Inventory.Item;
using Microsoft.Foundation.NoSeries;
using Vjeko.Demos.Restaurant.StockStalk;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Availability;

codeunit 50002 "DEMO Suggest Menus"
{
    procedure SuggestMenus(Date: Date)
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        Item: Record Item;
        UoMMgt: Codeunit "Unit of Measure Management";
        AvailabilityMgt: Codeunit "Item Availability Forms Mgt";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        StockStalk: Codeunit "DEMO StockStalk Availability";
        Available, HasLines : Boolean;
        Servings, LineServings : Integer;
        QtyPerUoM, NeededQty : Decimal;
        GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable, AvailableInventory : Decimal;
    begin
        RestaurantSetup.Get();
        RestaurantSetup.TestField("Menu Nos.");

        MenuHeader."No." := NoSeriesMgt.GetNextNo(RestaurantSetup."Menu Nos.", Date, true);
        MenuHeader.Date := Date;
        MenuHeader.Insert(false);

        MenuLine."Menu No." := MenuHeader."No.";

        RecipeHeader.SetRange(Blocked, false);
        StockStalk.Initialize(RecipeHeader, Date);

        if RecipeHeader.FindSet() then
            repeat
                Servings := 0;
                RecipeLine.SetRange("Recipe No.", RecipeHeader."No.");
                Available := RecipeLine.FindSet();
                if Available then
                    repeat
                        if Available then begin
                            if Item.Get(RecipeLine."Item No.") then begin
                                QtyPerUoM := UoMMgt.GetQtyPerUnitOfMeasure(Item, RecipeLine."Unit of Measure Code");
                                NeededQty := UoMMgt.CalcBaseQty(RecipeLine."Item No.", '', RecipeLine."Unit of Measure Code", RecipeLine.Quantity, QtyPerUoM);
                                AvailabilityMgt.FilterItem(Item, '', '', Date);
                                AvailabilityMgt.CalcAvailQuantities(Item, true, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable, AvailableInventory);
                                AvailableInventory := AvailableInventory + StockStalk.GetAvailableQty(Item."No.");
                                LineServings := Round(AvailableInventory / NeededQty, 1, '<');
                                if Servings > 0 then begin
                                    if LineServings < Servings then
                                        Servings := LineServings;
                                end else
                                    Servings := LineServings;

                                if Servings = 0 then
                                    Available := false;
                            end else
                                Available := false;
                        end;
                    until RecipeLine.Next() = 0;

                if Available then begin
                    HasLines := true;
                    MenuLine.Init();
                    MenuLine."Line No." += 10000;
                    MenuLine."Recipe No." := RecipeHeader."No.";
                    MenuLine.Description := RecipeHeader.Description;
                    MenuLine."Available Servings" := Servings;
                    MenuLine.Insert(false);
                end;
            until RecipeHeader.Next() = 0;

        if not HasLines then begin
            MenuHeader.Warning := true;
            MenuHeader.Modify();
        end;
    end;
}
