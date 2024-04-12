namespace Vjeko.Demos.Restaurant.Test;

using Vjeko.Demos.Restaurant;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;

codeunit 60001 "DEMO Library - Restaurant"
{
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        Initialized: Boolean;

    local procedure Initialize()
    begin
        if Initialized then
            exit;
        if not RestaurantSetup.Get() then
            RestaurantSetup.Insert();

        RestaurantSetup."Menu Nos." := LibraryUtility.GetGlobalNoSeriesCode();
        RestaurantSetup."Recipe Nos." := LibraryUtility.GetGlobalNoSeriesCode();
        RestaurantSetup."Use StockStalk" := false;
        RestaurantSetup.Modify();

        Initialized := true;
    end;

    local procedure GetNextGlobalNo(): Code[20]
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        exit(NoSeriesMgt.GetNextNo(LibraryUtility.GetGlobalNoSeriesCode(), WorkDate(), true));
    end;

    procedure CreateRecipe(var Recipe: Record "DEMO Recipe Header")
    begin
        Initialize();
        Recipe."No." := GetNextGlobalNo();
        Recipe.Insert(true);
    end;

    procedure CreateRecipeLine(var RecipeLine: Record "DEMO Recipe Line"; RecipeNo: Code[20]);
    var
        Item: Record Item;
        ItemUoM: Record "Item Unit of Measure";
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        Initialize();

        // [GIVEN] Some posting setup
        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", 0);

        // [GIVEN] An item with a unit of measure
        LibraryInventory.CreateItemWithPostingSetup(Item, GeneralPostingSetup."Gen. Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemUnitOfMeasureCode(ItemUoM, Item."No.", 1);

        // [GIVEN] A recipe line
        RecipeLine.Reset();
        RecipeLine.SetRange("Recipe No.", RecipeNo);
        if RecipeLine.FindLast() then;

        RecipeLine.Init();
        RecipeLine."Recipe No." := RecipeNo;
        RecipeLine."Line No." += 10000;
        RecipeLine."Item No." := Item."No.";
        RecipeLine."Unit of Measure Code" := ItemUoM.Code;
        RecipeLine.Quantity := Random(50) / 10 + 1;
        RecipeLine.Insert(false);

        RecipeLine.Reset();
    end;
}
