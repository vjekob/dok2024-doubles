namespace Vjeko.Demos.Restaurant;

using Microsoft.Inventory.Item;
using Vjeko.Demos.Restaurant.BC;
using Vjeko.Demos.Restaurant.StockStalk;

codeunit 50002 "DEMO Suggest Menus" implements "DEMO Suggest Menus"
{
    procedure SuggestMenus(Date: Date)
    var
        StockStalk: Codeunit "DEMO StockStalk Availability";
        UoMMgt: Codeunit "DEMO UoM Mgt.";
        Availability: Codeunit "DEMO Availability Base";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        NoSeriesMgt: Codeunit "DEMO NoSeries";
    begin
        SuggestMenus(Date, StockStalk, UoMMgt, Availability, SuggestMenus, NoSeriesMgt);
    end;

    procedure SuggestMenus(Date: Date; AvailabilityHandler: Interface "DEMO Availability Handler"; UoMMgt: Interface "DEMO Unit of Measure"; Availability: Interface "DEMO Availability Base"; SuggestMenus: Interface "DEMO Suggest Menus"; NoSeriesMgt: Interface "DEMO NoSeries")
    var
        RecipeHeader: Record "DEMO Recipe Header";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        HasLines: Boolean;
    begin
        SuggestMenus.InitializeMenu(MenuHeader, MenuLine, Date, NoSeriesMgt, SuggestMenus);

        RecipeHeader.SetRange(Blocked, false);
        AvailabilityHandler.Initialize(RecipeHeader, Date);

        if RecipeHeader.FindSet() then
            repeat
                if SuggestMenus.ProcessRecipe(RecipeHeader, MenuHeader, MenuLine, AvailabilityHandler, UoMMgt, Availability, SuggestMenus) then
                    HasLines := true;
            until RecipeHeader.Next() = 0;

        SuggestMenus.FinalizeMenu(MenuHeader, HasLines);
    end;

    internal procedure InitializeMenu(var MenuHeader: Record "DEMO Menu Header"; var MenuLine: Record "DEMO Menu Line"; Date: Date; NoSeriesMgt: Interface "DEMO NoSeries"; SuggestMenus: Interface "DEMO Suggest Menus")
    var
        MenuNos: Code[20];
    begin
        MenuNos := SuggestMenus.GetMenuNos();

        MenuHeader."No." := NoSeriesMgt.GetNextNo(MenuNos, Date, true);
        MenuHeader.Date := Date;
        MenuHeader.Insert(false);

        MenuLine."Menu No." := MenuHeader."No.";
        MenuLine."Line No." := 0;
    end;

    internal procedure GetMenuNos(): Code[20]
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
    begin
        RestaurantSetup.Get();
        RestaurantSetup.TestField("Menu Nos.");
        exit(RestaurantSetup."Menu Nos.");
    end;

    internal procedure FinalizeMenu(var MenuHeader: Record "DEMO Menu Header"; HasLines: Boolean)
    begin
        if HasLines then
            exit;

        MenuHeader.Warning := true;
        MenuHeader.Modify();
    end;

    internal procedure ProcessRecipe(RecipeHeader: Record "DEMO Recipe Header"; MenuHeader: Record "DEMO Menu Header"; var MenuLine: Record "DEMO Menu Line"; AvailabilityHandler: Interface "DEMO Availability Handler"; UoMMgt: Interface "DEMO Unit of Measure"; Availability: Interface "DEMO Availability Base"; SuggestMenus: Interface "DEMO Suggest Menus"): Boolean
    var
        RecipeLine: Record "DEMO Recipe Line";
        Item: Record Item;
        Servings: Integer;
        NeededQty, AvailableQty, ExternalQty : Decimal;
    begin
        RecipeLine.SetRange("Recipe No.", RecipeHeader."No.");
        if not RecipeLine.FindSet() then
            exit(false);

        repeat
            if not SuggestMenus.GetItem(RecipeLine, Item) then
                exit(false);

            SuggestMenus.ProcessRecipeLine(RecipeLine, Item, MenuHeader, AvailabilityHandler, UoMMgt, Availability, Servings);
            if Servings = 0 then
                exit(false);
        until RecipeLine.Next() = 0;

        SuggestMenus.WriteMenuLine(MenuLine, RecipeHeader, Servings);
        exit(true);
    end;

    internal procedure GetItem(RecipeLine: Record "DEMO Recipe Line"; var Item: Record Item): Boolean
    begin
        exit(Item.Get(RecipeLine."Item No."));
    end;

    internal procedure ProcessRecipeLine(RecipeLine: Record "DEMO Recipe Line"; Item: Record Item; MenuHeader: Record "DEMO Menu Header"; AvailabilityHandler: Interface "DEMO Availability Handler"; UoMMgt: Interface "DEMO Unit of Measure"; Availability: Interface "DEMO Availability Base"; var Servings: Integer)
    var
        NeededQty, AvailableQty, ExternalQty : Decimal;
    begin
        NeededQty := GetNeededQuantity(Item, RecipeLine, UoMMgt);
        AvailableQty := GetAvailableQuantity(Item, MenuHeader.Date, Availability);
        ExternalQty := AvailabilityHandler.GetAvailableQty(Item."No.");

        CalculateServings(Servings, NeededQty, AvailableQty + ExternalQty);
    end;

    internal procedure GetNeededQuantity(Item: Record Item; RecipeLine: Record "DEMO Recipe Line"; UoMMgt: Interface "DEMO Unit of Measure") NeededQty: Decimal
    var
        QtyPerUoM: Decimal;
    begin
        QtyPerUoM := UoMMgt.GetQtyPerUnitOfMeasure(Item, RecipeLine."Unit of Measure Code");
        NeededQty := UoMMgt.CalcBaseQty(RecipeLine."Item No.", '', RecipeLine."Unit of Measure Code", RecipeLine.Quantity, QtyPerUoM);
    end;

    internal procedure GetAvailableQuantity(Item: Record Item; Date: Date; Availability: Interface "DEMO Availability Base") AvailableQty: Decimal
    var
        GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable : Decimal;
    begin
        Availability.FilterItem(Item, '', '', Date);
        Availability.CalcAvailQuantities(Item, true, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable, AvailableQty);
    end;

    internal procedure CalculateServings(var Servings: Integer; NeededQty: Decimal; AvailableQty: Decimal)
    var
        LineServings: Integer;
    begin
        LineServings := Round(AvailableQty / NeededQty, 1, '<');

        if Servings = 0 then begin
            Servings := LineServings;
            exit;
        end;

        if LineServings < Servings then
            Servings := LineServings;
    end;

    internal procedure WriteMenuLine(var MenuLine: Record "DEMO Menu Line"; RecipeHeader: Record "DEMO Recipe Header"; Servings: Integer)
    begin
        AssignMenuLine(MenuLine, RecipeHeader, Servings);
        MenuLine.Insert(false);
    end;

    internal procedure AssignMenuLine(var MenuLine: Record "DEMO Menu Line"; RecipeHeader: Record "DEMO Recipe Header"; Servings: Integer)
    begin
        MenuLine.Init();
        MenuLine."Line No." += 10000;
        MenuLine."Recipe No." := RecipeHeader."No.";
        MenuLine.Description := RecipeHeader.Description;
        MenuLine."Available Servings" := Servings;
    end;
}
