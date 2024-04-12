namespace Vjeko.Demos.Restaurant.Test;

using Vjeko.Demos.Restaurant;
using Microsoft.Inventory.Item;

codeunit 60002 "DEMO Test Suggest Menus"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        SuggestMenus: Codeunit "DEMO Suggest Menus";
        Assert: Codeunit Assert;
        DummyAvailability: Codeunit "DEMO Dummy Avail. Handler";
        DummyNoSeries: Codeunit "DEMO Dummy NoSeries";
        StubUnitOfMeasure: Codeunit "DEMO Stub Unit of Measure";

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
    procedure GetMenuNos_NoSetup_Fails()
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
    begin
        // [SCENARIO] When there is no setup, GetMenuNos fails

        // [GIVEN] No setup
        if RestaurantSetup.Delete() then;

        // [WHEN] Getting menu nos.
        asserterror SuggestMenus.GetMenuNos();

        // [THEN] Expected to fail on Get
        Assert.ExpectedErrorCode('DB:RecordNotFound');
    end;

    [Test]
    procedure GetMenuNos_Setup_NoMenuNos_Fails()
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
    begin
        // [SCENARIO] When the setup doesn't define Menu Nos., GetMenuNos fails

        // [GIVEN] Setup without Menu Nos.
        RestaurantSetup."Menu Nos." := '';
        if not RestaurantSetup.Insert() then
            RestaurantSetup.Modify();

        // [WHEN] Getting menu nos.
        asserterror SuggestMenus.GetMenuNos();

        // [THEN] Expected to fail on TestField
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    procedure GetMenuNos_Setup_HasMenuNos_Returns()
    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
    begin
        // [SCENARIO] When the setup defines Menu Nos., GetMenuNos returns the value

        // [GIVEN] Setup with Menu Nos.
        RestaurantSetup."Menu Nos." := 'TEST';
        if not RestaurantSetup.Insert() then
            RestaurantSetup.Modify();

        // [WHEN] Getting menu nos.
        Assert.AreEqual('TEST', SuggestMenus.GetMenuNos(), 'Menu Nos. should be returned');
    end;

    [Test]
    procedure InitializeMenu()
    var
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        MockNoSeries: Codeunit "DEMO Mock NoSeries";
        MockSuggestMenus: Codeunit "DEMO Mock Suggest Menus";
    begin
        // [SCENARIO] When the system is correctly set up, initializing menu creates a menu entry
        Initialize();

        // [WHEN] Initializing menus
        SuggestMenus.InitializeMenu(MenuHeader, MenuLine, WorkDate(), MockNoSeries, MockSuggestMenus);

        // [THEN] No. series is invoked with configured series
        Assert.AreEqual('STUBNOS-01', MockNoSeries.InvokedWith_GetNextNo_NoSeriesCode(), 'No. series should be invoked with configured series');

        // [THEN] Header is initialized and written to database
        Assert.AreEqual('STUB-01', MenuHeader."No.", 'Menu No. not correctly assigned empty');
        Assert.AreEqual(WorkDate(), MenuHeader.Date, 'Menu Date must be defined');

        // [THEN] Line is initialized
        Assert.AreEqual(MenuHeader."No.", MenuLine."Menu No.", 'Menu No. was not assigned to line');
        Assert.AreEqual(0, MenuLine."Line No.", 'Line No. was not initialized');
    end;

    [Test]
    procedure FinalizeMenu_HasLines_NoWarning()
    var
        MenuHeader: Record "DEMO Menu Header";
    begin
        // [SCENARIO] When there are menu lines, header is not flagged with warning
        Initialize();

        // [GIVEN] A menu header
        MenuHeader.Insert();

        // [WHEN] Finalizing a menu with lines
        SuggestMenus.FinalizeMenu(MenuHeader, true);

        // [THEN] Menu header is not flagged with warning
        Assert.IsFalse(MenuHeader.Warning, 'Menu header should not be flagged with warning');
    end;

    [Test]
    procedure FinalizeMenu_NoLines_Warning()
    var
        MenuHeader: Record "DEMO Menu Header";
    begin
        // [SCENARIO] When there are no menu lines, header is flagged with warning
        Initialize();

        // [GIVEN] A menu header
        MenuHeader.Insert();

        // [WHEN] Finalizing a menu with no lines
        SuggestMenus.FinalizeMenu(MenuHeader, false);

        // [THEN] Menu header is flagged with warning
        Assert.IsTrue(MenuHeader.Warning, 'Menu header should be flagged with warning');
    end;

    [Test]
    procedure ProcessRecipe_NoLines_False()
    var
        RecipeHeader: Record "DEMO Recipe Header";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        MockAvailability: Codeunit "DEMO Mock Availability";
        MockSuggestMenus: Codeunit "DEMO Mock Suggest Menus";
        Result: Boolean;
    begin
        // [SCENARIO] When there are no recipe lines, ProcessRecipe returns false
        Initialize();

        // [WHEN] Processing a recipe
        Result := SuggestMenus.ProcessRecipe(RecipeHeader, MenuHeader, MenuLine, DummyAvailability, StubUnitOfMeasure, MockAvailability, MockSuggestMenus);

        // [THEN] Result must be false
        Assert.IsFalse(Result, 'Processing a recipe with no lines should return false');

        // [THEN] Write wasn't invoked
        Assert.IsFalse(MockSuggestMenus.IsInvoked_WriteMenuLine(), 'WriteMenuLine should not be invoked');
    end;

    [Test]
    procedure ProcessRecipe_NoItem_False()
    var
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        MockAvailability: Codeunit "DEMO Mock Availability";
        MockSuggestMenus: Codeunit "DEMO Mock Suggest Menus";
        Result: Boolean;
    begin
        // [SCENARIO] When there are no recipe lines, ProcessRecipe returns false
        Initialize();

        // [GIVEN] A recipe line exists
        RecipeLine.Insert();

        // [WHEN] Processing a recipe
        Result := SuggestMenus.ProcessRecipe(RecipeHeader, MenuHeader, MenuLine, DummyAvailability, StubUnitOfMeasure, MockAvailability, MockSuggestMenus);

        // [THEN] Result must be false
        Assert.IsFalse(Result, 'Processing a recipe with no lines should return false');

        // [THEN] Write wasn't invoked
        Assert.IsFalse(MockSuggestMenus.IsInvoked_WriteMenuLine(), 'WriteMenuLine should not be invoked');
    end;

    [Test]
    procedure ProcessRecipe_NoAvailability_False()
    var
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        MockAvailability: Codeunit "DEMO Mock Availability";
        MockSuggestMenus: Codeunit "DEMO Mock Suggest Menus";
        Result: Boolean;
    begin
        // [SCENARIO] Process recipe returns false if ingredients are not available in minimum quantity
        Initialize();

        // [GIVEN] A recipe line
        RecipeLine.Insert();

        // [GIVEN] Expected servings
        MockSuggestMenus.SetReturn_GetItem(true);
        MockSuggestMenus.SetValue_ProcessRecipeLine_Servings(0);

        // [WHEN] Processing a recipe
        Result := SuggestMenus.ProcessRecipe(RecipeHeader, MenuHeader, MenuLine, DummyAvailability, StubUnitOfMeasure, MockAvailability, MockSuggestMenus);

        // [THEN] Result should be false
        Assert.IsFalse(Result, 'Processing a recipe with no availability should return false');

        // [THEN] Write wasn't invoked
        Assert.IsFalse(MockSuggestMenus.IsInvoked_WriteMenuLine(), 'WriteMenuLine should not be invoked');
    end;

    [Test]
    procedure ProcessRecipe_HasAvailability_True()
    var
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        MenuHeader: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        MockAvailability: Codeunit "DEMO Mock Availability";
        MockSuggestMenus: Codeunit "DEMO Mock Suggest Menus";
        Result: Boolean;
    begin
        // [SCENARIO] Process recipe returns true if ingredients are available in minimum quantity
        Initialize();

        // [GIVEN] A recipe line
        RecipeLine.Insert();

        // [GIVEN] Expected servings
        MockSuggestMenus.SetReturn_GetItem(true);
        MockSuggestMenus.SetValue_ProcessRecipeLine_Servings(2);

        // [WHEN] Processing a recipe
        Result := SuggestMenus.ProcessRecipe(RecipeHeader, MenuHeader, MenuLine, DummyAvailability, StubUnitOfMeasure, MockAvailability, MockSuggestMenus);

        // [THEN] Result should be true
        Assert.IsTrue(Result, 'Processing a recipe with availability should return true');

        // [THEN] A menu line should be written
        Assert.IsTrue(MockSuggestMenus.IsInvoked_WriteMenuLine(), 'WriteMenuLine should be invoked');
    end;

    [Test]
    procedure GetNeededQuantity()
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        RecipeLine: Record "DEMO Recipe Line";
        Result: Decimal;
    begin
        // [SCENARIO] GetNeededQuantity returns the quantity needed to satisfy the minimum requirement

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
        MockAvailability: Codeunit "DEMO Mock Availability";
        Result: Decimal;
    begin
        // [SCENARIO] GetAvailableQuantity returns the quantity available in the inventory

        // [GIVEN] An item unit of measure
        ItemUnitOfMeasure."Qty. per Unit of Measure" := Random(100) / 50 + 1;

        // [GIVEN] Enough inventory for the recipe line
        MockAvailability.CreateInventory(RecipeLine, 2);

        // [WHEN] Getting the available quantity
        Result := SuggestMenus.GetAvailableQuantity(Item, WorkDate(), MockAvailability);

        // [THEN] Result should be correct
        Assert.AreEqual(2 * RecipeLine.Quantity * ItemUnitOfMeasure."Qty. per Unit of Measure", Result, 'Available quantity is not correctly calculated');
    end;

    [Test]
    procedure CalculateServings_AssignsAllWhen0()
    var
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
        LineNo: Integer;
        Servings: Integer;
    begin
        // [SCENARIO] AssignMenuLine writes a menu line with the expected values

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
    procedure SuggestMenus_NoLinesy_Warning()
    var
        Recipe: Record "DEMO Recipe Header";
        MockAvailability: Codeunit "DEMO Mock Availability";
        MockSuggestMenus: Codeunit "DEMO Mock Suggest Menus";
    begin
        // [SCENARIO] Suggest menus for a given date creates nothing when there is no availability for the ingredients
        Initialize();

        // [GIVEN] A recipe with no lines
        Recipe.Insert();
        MockSuggestMenus.SetReturn_ProcessRecipe(false);

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D, DummyAvailability, StubUnitOfMeasure, MockAvailability, MockSuggestMenus, DummyNoSeries);

        // [THEN] A menu was created and flagged with warning
        Assert.IsTrue(MockSuggestMenus.IsInvoked_FinalizeMenu(), 'FinalizeMenu should be invoked');
        Assert.IsFalse(MockSuggestMenus.IsInvoked_FinalizeMenu_HasLines(), 'FinalizeMenu should be invoked with no lines');
    end;

    [Test]
    procedure SuggestMenus_HasLines_NoWarning()
    var
        Recipe: Record "DEMO Recipe Header";
        MockAvailability: Codeunit "DEMO Mock Availability";
        MockSuggestMenus: Codeunit "DEMO Mock Suggest Menus";
    begin
        // [SCENARIO] Suggest menus for a given date creates nothing when there is no availability for the ingredients
        Initialize();

        // [GIVEN] A recipe with lines
        Recipe.Insert();
        MockSuggestMenus.SetReturn_ProcessRecipe(true);

        // [WHEN] Suggesting menus
        SuggestMenus.SuggestMenus(18760123D, DummyAvailability, StubUnitOfMeasure, MockAvailability, MockSuggestMenus, DummyNoSeries);

        // [THEN] A menu was created and  notflagged with warning
        Assert.IsTrue(MockSuggestMenus.IsInvoked_FinalizeMenu(), 'FinalizeMenu should be invoked');
        Assert.IsTrue(MockSuggestMenus.IsInvoked_FinalizeMenu_HasLines(), 'FinalizeMenu should be invoked with lines');
    end;
}
