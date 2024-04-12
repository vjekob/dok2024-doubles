namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60002 "DEMO Test Suggest Menus"
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
    begin
        Menu.DeleteAll();
        MenuLine.DeleteAll();
    end;

    [Test]
    procedure SuggestMenus_NoAvailability_Warning()
    var
        Recipe: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        Menu: Record "DEMO Menu Header";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
    begin
        // [SCENARIO] Suggest menus for a given date creates nothing when there is no availability for the ingredients
        Initialize();

        // [GIVEN] A recipe with three lines
        LibraryRestaurant.CreateRecipe(Recipe);
        LibraryRestaurant.CreateRecipeLine(RecipeLine, Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine, Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine, Recipe."No.");

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D);

        // [THEN] A menu was created and flagged with warning
        Menu.FindFirst();
        Assert.IsTrue(Menu.Warning, 'Menu should have a warning');
    end;

    [Test]
    procedure SuggestMenus_NotEnoughAvailability_Warning()
    var
        Recipe: Record "DEMO Recipe Header";
        RecipeLine: array[3] of Record "DEMO Recipe Line";
        Menu: Record "DEMO Menu Header";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
    begin
        // [SCENARIO] Suggest menus for a given date creates nothing when there is not enough availability for the ingredients
        Initialize();

        // [GIVEN] A recipe with three lines
        LibraryRestaurant.CreateRecipe(Recipe);
        LibraryRestaurant.CreateRecipeLine(RecipeLine[1], Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine[2], Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine[3], Recipe."No.");

        // [GIVEN] Enough inventory for the first two lines
        LibraryRestaurant.CreateInventory(RecipeLine[1]);
        LibraryRestaurant.CreateInventory(RecipeLine[2]);

        // [GIVEN] Not enougn inventory for the last line
        LibraryRestaurant.CreateInventory(RecipeLine[3], 0.5);

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D);

        // [THEN] A menu was created and flagged with warning
        Menu.FindFirst();
        Assert.IsTrue(Menu.Warning, 'Menu should have a warning');
    end;

    [Test]
    procedure SuggestMenus_EnoughAvailability_Lowest()
    var
        Recipe: Record "DEMO Recipe Header";
        RecipeLine: array[3] of Record "DEMO Recipe Line";
        Menu: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
    begin
        // [SCENARIO] Suggest menus for a given date creates the menus with quantites that correspond to availability of lowest-available ingredient
        Initialize();

        // [GIVEN] A recipe with three lines
        LibraryRestaurant.CreateRecipe(Recipe);
        LibraryRestaurant.CreateRecipeLine(RecipeLine[1], Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine[2], Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine[3], Recipe."No.");

        // [GIVEN] Enough inventory for 4.5 servings for the first line
        LibraryRestaurant.CreateInventory(RecipeLine[1], 4.5);

        // [GIVEN] Enouvh inventory for 3.5 servings for the second line
        LibraryRestaurant.CreateInventory(RecipeLine[2], 3.5);

        // [GIVEN] Enough inventory for 2.5 servings for the last line
        LibraryRestaurant.CreateInventory(RecipeLine[3], 2.5);

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D);

        // [THEN] A menu was created and not flagged with warning
        Menu.FindFirst();
        Assert.IsFalse(Menu.Warning, 'Menu should have a warning');

        // [THEN] A menu line was created for the recipe, with 2 servings
        MenuLine.FindFirst();
        Assert.AreEqual(2, MenuLine."Available Servings", 'Menu line should have 2 servings');
    end;

    [Test]
    procedure SuggestMenus_MultipleRecipes()
    var
        Recipe: array[3] of Record "DEMO Recipe Header";
        RecipeLine: array[3, 3] of Record "DEMO Recipe Line";
        Menu: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        i, j : Integer;
    begin
        // [SCENARIO] Suggest menus for a given date creates the as many menu lines as there are recipes with availability
        Initialize();

        // [GIVEN] Three recipes with three lines each, and enough availability for all of them
        for i := 1 to 3 do begin
            LibraryRestaurant.CreateRecipe(Recipe[i]);
            for j := 1 to 3 do begin
                LibraryRestaurant.CreateRecipeLine(RecipeLine[j, i], Recipe[i]."No.");
                LibraryRestaurant.CreateInventory(RecipeLine[j, i], i);
            end;
        end;

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D);

        // [THEN] A menu was created and not flagged with warning
        Menu.FindFirst();
        Assert.IsFalse(Menu.Warning, 'Menu should have a warning');

        // [THEN] All recipe lines are available in expected quantities
        for i := 1 to 3 do begin
            MenuLine.SetRange("Recipe No.", Recipe[i]."No.");
            MenuLine.FindFirst();
            Assert.AreEqual(i, MenuLine."Available Servings", 'Unexpected number of servings');
        end;
    end;
}
