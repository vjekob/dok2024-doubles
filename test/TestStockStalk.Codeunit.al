namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;
using Vjeko.Demos.Restaurant.StockStalk;
using Microsoft.Inventory.Item;

codeunit 60003 "DEMO Test StockStalk"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRestaurant: Codeunit "DEMO Library - Restaurant";

    procedure Initialize()
    var
        Menu: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        RestaurantSetup: Record "DEMO Restaurant Setup";
    begin
        Menu.DeleteAll();
        MenuLine.DeleteAll();

        RecipeHeader.DeleteAll();
        RecipeLine.DeleteAll();

        if not RestaurantSetup.Get() then
            RestaurantSetup.Insert();
    end;

    [Test]
    procedure Integration_HappyPath()
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        Item: Record Item;
        StockStalk: Codeunit "DEMO StockStalk Availability";
        Quantity: Decimal;
        i, j : Integer;
    begin
        // [SCENARIO] Tests the happy path through StockStalk process
        Initialize();

        // [GIVEN] Three recipes with three lines each
        for i := 1 to 3 do begin
            LibraryRestaurant.CreateRecipe(RecipeHeader);
            for j := 1 to 3 do
                LibraryRestaurant.CreateRecipeLine(RecipeLine, RecipeHeader."No.");
        end;

        // [GIVEN] StockStalk ID assigned to all items
        RecipeLine.FindSet();
        repeat
            Item.Get(RecipeLine."Item No.");
            Item."DEMO StockStalk Item ID" := Item."No.";
            Item.Modify();
        until RecipeLine.Next() = 0;

        // [GIVEN] Correct restaurant setup
        RestaurantSetup.Get();
        RestaurantSetup."StockStalk URL" := 'https://stockstalk.azurewebsites.net/api/v1';
        RestaurantSetup.SetStockStalkAPIKey('JF4Rlt_Rf3wLJ7EojF41SV6Us9t7SuSbAVfg9hkOpcYGAzFupMoMtg==');
        RestaurantSetup."Use StockStalk" := true;
        RestaurantSetup.Modify();

        // [WHEN] StockStalk updates stock levels
        StockStalk.Initialize(RecipeHeader, Today());

        // [THEN] Availability must be updated
        RecipeLine.Reset();
        RecipeLine.FindSet(false);
        repeat
            Quantity := StockStalk.GetAvailableQty(RecipeLine."Item No.");
            Assert.AreNotEqual(0, Quantity, 'StockStalk available quantity must be different than 0.'); // Oops... 🤔
        until RecipeLine.Next() = 0;
    end;
}
