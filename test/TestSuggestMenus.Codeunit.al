namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;
using Microsoft.Inventory.Item;

codeunit 60002 "DEMO Test Suggest Menus"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRestaurant: Codeunit "DEMO Library - Restaurant";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";

    procedure Initialize()
    var
        Menu: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        Recipe: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
    begin
        Menu.DeleteAll();
        MenuLine.DeleteAll();
        Recipe.DeleteAll();
        RecipeLine.DeleteAll();
    end;

    [Test]
    procedure InitializeMenu_NoSetup_Fails()
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
    begin
        // [SCENARIO] When there is no setup, InitializeMenu fails

        // [GIVEN] No setup
        if RestaurantSetup.Delete() then;

        // [WHEN] Initializing menus
        asserterror SuggestMenus.InitializeMenu(MenuHeader, MenuLine, WorkDate());

        // [THEN] Expected to fail on Get
        Assert.ExpectedErrorCode('DB:RecordNotFound');
    end;

    [Test]
    procedure InitializeMenu_Setup_NoMenuNos_Fails()
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
    begin
        // [SCENARIO] When the setup doesn't define Menu Nos., InitializeMenu fails

        // [GIVEN] Setup without Menu Nos.
        RestaurantSetup."Menu Nos." := '';
        if not RestaurantSetup.Insert() then
            RestaurantSetup.Modify();

        // [WHEN] Initializing menus
        asserterror SuggestMenus.InitializeMenu(MenuHeader, MenuLine, WorkDate());

        // [THEN] Expected to fail on TestField
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    procedure InitializeMenu_Setup()
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
    begin
        // [SCENARIO] When the system is correctly set up, initializing menu creates a menu entry
        Initialize();

        // [GIVEN] Setup with Menu Nos.
        RestaurantSetup."Menu Nos." := LibraryUtility.GetGlobalNoSeriesCode();
        if not RestaurantSetup.Insert() then
            RestaurantSetup.Modify();

        // [WHEN] Initializing menus
        SuggestMenus.InitializeMenu(MenuHeader, MenuLine, WorkDate());

        // [THEN] Header is initialized and written to database
        MenuHeader.Find();
        Assert.AreNotEqual('', MenuHeader."No.", 'Menu No. should not be empty');
        Assert.AreEqual(WorkDate(), MenuHeader."Date", 'Menu Date must be defined');

        // [THEN] Line is initialized
        Assert.AreEqual(MenuHeader."No.", MenuLine."Menu No.", 'Menu No. was not assigned to line');
        Assert.AreEqual(0, MenuLine."Line No.", 'Line No. was not initialized');
    end;

    [Test]
    procedure ProcessRecipe_NoLines_False()
    var
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        DummyAvailability: Codeunit "DEMO Dummy Avail. Handler";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";
        MockAvailability: Codeunit "DEMO Mock Availability";
        SpySuggestMenus: Codeunit "DEMO Spy Suggest Menus";
        Result: Boolean;
    begin
        // [SCENARIO] When there are no recipe lines, ProcessRecipe returns false
        Initialize();

        // [GIVEN] No recipe lines
        RecipeLine.DeleteAll();

        // [WHEN] Processing a recipe
        Result := SuggestMenus.ProcessRecipe(RecipeHeader, MenuHeader, MenuLine, DummyAvailability, StubUnitOfMeasure, MockAvailability, SpySuggestMenus);

        // [THEN] Result must be false
        Assert.IsFalse(Result, 'Processing a recipe with no lines should return false');

        // [THEN] Write wasn't invoked
        Assert.IsFalse(SpySuggestMenus.IsInvoked_WriteMenuLine(), 'WriteMenuLine should not be invoked');
    end;

    [Test]
    procedure ProcessRecipe_NoItem_False()
    var
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        DummyAvailability: Codeunit "DEMO Dummy Avail. Handler";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";
        MockAvailability: Codeunit "DEMO Mock Availability";
        SpySuggestMenus: Codeunit "DEMO Spy Suggest Menus";
        Result: Boolean;
    begin
        // [SCENARIO] When there are no recipe lines, ProcessRecipe returns false
        Initialize();

        // [GIVEN] A recipe line exists
        RecipeLine.Insert();

        // [WHEN] Processing a recipe
        Result := SuggestMenus.ProcessRecipe(RecipeHeader, MenuHeader, MenuLine, DummyAvailability, StubUnitOfMeasure, MockAvailability, SpySuggestMenus);

        // [THEN] Result must be false
        Assert.IsFalse(Result, 'Processing a recipe with no lines should return false');

        // [THEN] Write wasn't invoked
        Assert.IsFalse(SpySuggestMenus.IsInvoked_WriteMenuLine(), 'WriteMenuLine should not be invoked');
    end;

    [Test]
    procedure ProcessRecipe_NoAvailability_False()
    var
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: array[2] of Record "DEMO Recipe Line";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        DummyAvailability: Codeunit "DEMO Dummy Avail. Handler";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";
        MockAvailability: Codeunit "DEMO Mock Availability";
        SpySuggestMenus: Codeunit "DEMO Spy Suggest Menus";
        Result: Boolean;
    begin
        // [SCENARIO] Process recipe returns false if ingredients are not available in minimum quantity
        Initialize();

        // [GIVEN] Two recipe lines
        LibraryRestaurant.CreateRecipeLine(RecipeLine[1], '');
        LibraryRestaurant.CreateRecipeLine(RecipeLine[2], '');

        // [GIVEN] Enough inventory for the first line
        MockAvailability.CreateInventory(RecipeLine[1]);

        // [WHEN] Processing a recipe
        Result := SuggestMenus.ProcessRecipe(RecipeHeader, MenuHeader, MenuLine, DummyAvailability, StubUnitOfMeasure, MockAvailability, SpySuggestMenus);

        // [THEN] Result should be false
        Assert.IsFalse(Result, 'Processing a recipe with no availability should return false');

        // [THEN] Write wasn't invoked
        Assert.IsFalse(SpySuggestMenus.IsInvoked_WriteMenuLine(), 'WriteMenuLine should not be invoked');
    end;

    [Test]
    procedure ProcessRecipe_HasAvailability_True()
    var
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: array[2] of Record "DEMO Recipe Line";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        DummyAvailability: Codeunit "DEMO Dummy Avail. Handler";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";
        MockAvailability: Codeunit "DEMO Mock Availability";
        SpySuggestMenus: Codeunit "DEMO Spy Suggest Menus";
        Result: Boolean;
    begin
        // [SCENARIO] Process recipe returns true if ingredients are available in minimum quantity
        Initialize();

        // [GIVEN] Two recipe lines
        LibraryRestaurant.CreateRecipeLine(RecipeLine[1], '');
        LibraryRestaurant.CreateRecipeLine(RecipeLine[2], '');

        // [GIVEN] Enough inventory for both lines
        MockAvailability.CreateInventory(RecipeLine[1]);
        MockAvailability.CreateInventory(RecipeLine[2]);

        // [WHEN] Processing a recipe
        Result := SuggestMenus.ProcessRecipe(RecipeHeader, MenuHeader, MenuLine, DummyAvailability, StubUnitOfMeasure, MockAvailability, SpySuggestMenus);

        // [THEN] Result should be true
        Assert.IsTrue(Result, 'Processing a recipe with availability should return true');

        // [THEN] A menu line should be written
        Assert.IsTrue(SpySuggestMenus.IsInvoked_WriteMenuLine(), 'WriteMenuLine should be invoked');
    end;

    [Test]
    procedure GetNeededQuantity()
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        RecipeLine: Record "DEMO Recipe Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";
        MockAvailability: Codeunit "DEMO Mock Availability";
        Result: Decimal;
    begin
        // [SCENARIO] GetNeededQuantity returns the quantity needed to satisfy the minimum requirement

        // [GIVEN] An item
        LibraryInventory.CreateItem(Item);

        // [GIVEN] A unit of measure for the item
        ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;

        // [GIVEN] A recipe line
        RecipeLine."Item No." := Item."No.";
        RecipeLine."Unit of Measure Code" := ItemUnitOfMeasure.Code;
        RecipeLine.Quantity := Random(100) / 10 + 1;

        // [WHEN] Getting the needed quantity
        Result := SuggestMenus.GetNeededQuantity(Item, RecipeLine, StubUnitOfMeasure);

        // [THEN] Result should be the quantity from the recipe line
        Assert.AreEqual(RecipeLine.Quantity * ItemUnitOfMeasure."Qty. per Unit of Measure", Result, 'Needed quantity is not correctly calculated');
    end;

    [Test]
    procedure GetAvailableQuantity()
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        RecipeLine: Record "DEMO Recipe Line";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        MockAvailability: Codeunit "DEMO Mock Availability";
        Result: Decimal;
    begin
        // [SCENARIO] GetAvailableQuantity returns the quantity available in the inventory

        // [GIVEN] A recipe line
        LibraryRestaurant.CreateRecipeLine(RecipeLine, '');

        // [GIVEN] Enough inventory for the recipe line
        MockAvailability.CreateInventory(RecipeLine, 2);

        // [GIVEN] The item from the recipe line
        Item.Get(RecipeLine."Item No.");

        // [GIVEN] The unit of measure for the item
        ItemUnitOfMeasure.Get(Item."No.", RecipeLine."Unit of Measure Code");

        // [WHEN] Getting the available quantity
        Result := SuggestMenus.GetAvailableQuantity(Item, WorkDate(), MockAvailability);

        // [THEN] Result should be correct
        Assert.AreEqual(2 * RecipeLine.Quantity * ItemUnitOfMeasure."Qty. per Unit of Measure", Result, 'Available quantity is not correctly calculated');
    end;

    [Test]
    procedure CalculateServings_AssignsAllWhen0()
    var
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        Servings: Integer;
    begin
        // [SCENARIO] CalculateServings assigns all available servings when 0 is passed

        // [GIVEN] Quantity of servings was not previously calculated
        Servings := 0;

        // [WHEN] Calculating servings
        SuggestMenus.CalculateServings(Servings, 4, 15);

        // [THEN] Returning 15 / 4 = 3 servings
        Assert.AreEqual(3, Servings, 'Servings should be 3');
    end;

    [Test]
    procedure CalculateServings_NoChangeWhenMoreThanServings()
    var
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        Servings: Integer;
    begin
        // [SCENARIO] CalculateServings returns the same number of servings when more than available is passed

        // [GIVEN] Quantity of servings was previously calculated to 2
        Servings := 2;

        // [WHEN] Calculating servings
        SuggestMenus.CalculateServings(Servings, 4, 15);

        // [THEN] Returning 15 / 4 = 3 servings
        Assert.AreEqual(2, Servings, 'Servings should be 3');
    end;

    [Test]
    procedure CalculateServings_UpdatesWhenLessThanServings()
    var
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        Servings: Integer;
    begin
        // [SCENARIO] CalculateServings updates the number of servings when less than available is passed

        // [GIVEN] Quantity of servings was previously calculated to 2
        Servings := 2;

        // [WHEN] Calculating servings
        SuggestMenus.CalculateServings(Servings, 4, 5);

        // [THEN] Returning 5 / 4 = 1 servings
        Assert.AreEqual(1, Servings, 'Servings should be 1');
    end;

    [Test]
    procedure AssignMenuLine()
    var
        MenuLine: Record "DEMO Menu Line";
        RecipeHeader: Record "DEMO Recipe Header";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        LineNo: Integer;
        Servings: Integer;
    begin
        // [SCENARIO] AssignMenuLine writes a menu line with the expected values
        Initialize();

        // [GIVEN] A previous menu line
        LineNo := Round(Random(10) * 10000, 10000, '>');
        MenuLine."Line No." := LineNo;

        // [GIVEN] A recipe header
        RecipeHeader."No." := 'TEST';
        RecipeHeader.Description := 'Test Recipe';

        // [GIVEN] A random number of servings
        Servings := Round(Random(100), 1, '>');

        // [WHEN] Writing a menu line
        SuggestMenus.AssignMenuLine(MenuLine, RecipeHeader, Servings);

        // [THEN] Menu line has expected values
        Assert.AreEqual(RecipeHeader."No.", MenuLine."Recipe No.", 'Recipe No. should be copied');
        Assert.AreEqual(RecipeHeader.Description, MenuLine.Description, 'Description should be copied');
        Assert.AreEqual(Servings, MenuLine."Available Servings", 'Available Servings should be copied');
        Assert.AreEqual(LineNo + 10000, MenuLine."Line No.", 'Line No. should be incremented');
    end;

    [Test]
    procedure SuggestMenus_NoAvailability_Warning()
    var
        Recipe: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        Menu: Record "DEMO Menu Header";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        DummyAvailability: Codeunit "DEMO Dummy Avail. Handler";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";
        MockAvailability: Codeunit "DEMO Mock Availability";
        DummySuggestMenus: Codeunit "DEMO Dummy Suggest Menus";
    begin
        // [SCENARIO] Suggest menus for a given date creates nothing when there is no availability for the ingredients
        Initialize();

        // [GIVEN] A recipe with three lines
        LibraryRestaurant.CreateRecipe(Recipe);
        LibraryRestaurant.CreateRecipeLine(RecipeLine, Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine, Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine, Recipe."No.");

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D, DummyAvailability, StubUnitOfMeasure, MockAvailability, DummySuggestMenus);

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
        DummyAvailability: Codeunit "DEMO Dummy Avail. Handler";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";
        MockAvailability: Codeunit "DEMO Mock Availability";
        DummySuggestMenus: Codeunit "DEMO Dummy Suggest Menus";
    begin
        // [SCENARIO] Suggest menus for a given date creates nothing when there is not enough availability for the ingredients
        Initialize();

        // [GIVEN] A recipe with three lines
        LibraryRestaurant.CreateRecipe(Recipe);
        LibraryRestaurant.CreateRecipeLine(RecipeLine[1], Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine[2], Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine[3], Recipe."No.");

        // [GIVEN] Enough inventory for the first two lines
        MockAvailability.CreateInventory(RecipeLine[1]);
        MockAvailability.CreateInventory(RecipeLine[2]);

        // [GIVEN] Not enougn inventory for the last line
        MockAvailability.CreateInventory(RecipeLine[3], 0.5);

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D, DummyAvailability, StubUnitOfMeasure, MockAvailability, DummySuggestMenus);

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
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        DummyAvailability: Codeunit "DEMO Dummy Avail. Handler";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";
        MockAvailability: Codeunit "DEMO Mock Availability";
        SpySuggestMenus: Codeunit "DEMO Spy Suggest Menus";
    begin
        // [SCENARIO] Suggest menus for a given date creates the menus with quantites that correspond to availability of lowest-available ingredient
        Initialize();

        // [GIVEN] A recipe with three lines
        LibraryRestaurant.CreateRecipe(Recipe);
        LibraryRestaurant.CreateRecipeLine(RecipeLine[1], Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine[2], Recipe."No.");
        LibraryRestaurant.CreateRecipeLine(RecipeLine[3], Recipe."No.");

        // [GIVEN] Enough inventory for 4.5 servings for the first line
        MockAvailability.CreateInventory(RecipeLine[1], 4.5);

        // [GIVEN] Enouvh inventory for 3.5 servings for the second line
        MockAvailability.CreateInventory(RecipeLine[2], 3.5);

        // [GIVEN] Enough inventory for 2.5 servings for the last line
        MockAvailability.CreateInventory(RecipeLine[3], 2.5);

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D, DummyAvailability, StubUnitOfMeasure, MockAvailability, SpySuggestMenus);

        // [THEN] A menu was created and not flagged with warning
        Menu.FindFirst();
        Assert.IsFalse(Menu.Warning, 'Menu should have a warning');

        // [THEN] A menu line was created for the recipe, with 2 servings
        Assert.AreEqual(2, SpySuggestMenus.LastValue_WriteMenuLine_Servings(), 'Menu line should have 2 servings');
    end;

    [Test]
    procedure SuggestMenus_MultipleRecipes()
    var
        Recipe: array[3] of Record "DEMO Recipe Header";
        RecipeLine: array[3, 3] of Record "DEMO Recipe Line";
        Menu: Record "DEMO Menu Header";
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        DummyAvailability: Codeunit "DEMO Dummy Avail. Handler";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";
        MockAvailability: Codeunit "DEMO Mock Availability";
        SpySuggestMenus: Codeunit "DEMO Spy Suggest Menus";
        i, j : Integer;
    begin
        // [SCENARIO] Suggest menus for a given date creates the as many menu lines as there are recipes with availability
        Initialize();

        // [GIVEN] Three recipes with three lines each, and enough availability for all of them
        for i := 1 to 3 do begin
            LibraryRestaurant.CreateRecipe(Recipe[i]);
            for j := 1 to 3 do begin
                LibraryRestaurant.CreateRecipeLine(RecipeLine[j, i], Recipe[i]."No.");
                MockAvailability.CreateInventory(RecipeLine[j, i], i);
            end;
        end;

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D, DummyAvailability, StubUnitOfMeasure, MockAvailability, SpySuggestMenus);

        // [THEN] A menu was created and not flagged with warning
        Menu.FindFirst();
        Assert.IsFalse(Menu.Warning, 'Menu should have a warning');

        // [THEN] All recipe lines written
        Assert.AreEqual(3, SpySuggestMenus.CountInvoked_WriteMenuLine(), 'Unexpected number of menu lines written');
    end;
}
