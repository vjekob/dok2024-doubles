namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;
using Microsoft.Inventory.Item;

codeunit 60007 "DEMO Mock Suggest Menus" implements "DEMO Suggest Menus"
{
    #region WriteMenuLine

    var
        _isInvoked_WriteMenuLine: Boolean;
        _countInvoked_WriteMenuLine: Integer;
        _lastValue_WriteMenuLine_Servings: Integer;

    procedure WriteMenuLine(var MenuLine: Record "DEMO Menu Line"; RecipeHeader: Record "DEMO Recipe Header"; Servings: Integer)
    begin
        _isInvoked_WriteMenuLine := true;
        _countInvoked_WriteMenuLine += 1;
        _lastValue_WriteMenuLine_Servings := Servings;
    end;

    procedure IsInvoked_WriteMenuLine(): Boolean
    begin
        exit(_isInvoked_WriteMenuLine);
    end;

    procedure CountInvoked_WriteMenuLine(): Integer
    begin
        exit(_countInvoked_WriteMenuLine);
    end;

    procedure LastValue_WriteMenuLine_Servings(): Integer
    begin
        exit(_lastValue_WriteMenuLine_Servings);
    end;

    #endregion

    #region ProcessRecipeLine

    var
        _setValue_ProcessRecipeLine_Servings: Integer;

    procedure ProcessRecipeLine(RecipeLine: Record "DEMO Recipe Line"; Item: Record Item; MenuHeader: Record "DEMO Menu Header"; AvailabilityHandler: Interface "DEMO Availability Handler"; UoMMgt: Interface "DEMO Unit of Measure"; Availability: Interface "DEMO Availability Base"; var Servings: Integer)
    begin
        Servings := _setValue_ProcessRecipeLine_Servings;
    end;

    procedure SetValue_ProcessRecipeLine_Servings(Value: Integer)
    begin
        _setValue_ProcessRecipeLine_Servings := Value;
    end;

    #endregion

    #region ProcessRecipe

    var
        _setReturn_ProcessRecipe: Boolean;

    procedure ProcessRecipe(RecipeHeader: Record "DEMO Recipe Header"; MenuHeader: Record "DEMO Menu Header"; var MenuLine: Record "DEMO Menu Line"; AvailabilityHandler: Interface "DEMO Availability Handler"; UoMMgt: Interface "DEMO Unit of Measure"; Availability: Interface "DEMO Availability Base"; SuggestMenus: Interface "DEMO Suggest Menus"): Boolean
    begin
        exit(_setReturn_ProcessRecipe);
    end;

    procedure SetReturn_ProcessRecipe(Value: Boolean)
    begin
        _setReturn_ProcessRecipe := Value;
    end;

    #endregion

    #region GetItem

    var
        _setReturn_GetItem: Boolean;

    procedure GetItem(RecipeLine: Record "DEMO Recipe Line"; var Item: Record Item): Boolean
    begin
        exit(_setReturn_GetItem);
    end;

    procedure SetReturn_GetItem(Value: Boolean)
    begin
        _setReturn_GetItem := Value;
    end;

    #endregion

    #region InitializeMenu

    procedure InitializeMenu(var MenuHeader: Record "DEMO Menu Header"; var MenuLine: Record "DEMO Menu Line"; Date: Date; NoSeriesMgt: Interface "DEMO NoSeries"; SuggestMenus: Interface "DEMO Suggest Menus")
    begin
    end;

    #endregion

    #region FinalizeMenu

    var
        _isInvoked_FinalizeMenu: Boolean;
        _isInvoked_FinalizeMenu_HasLines: Boolean;

    procedure FinalizeMenu(var MenuHeader: Record "DEMO Menu Header"; HasLines: Boolean)
    begin
        _isInvoked_FinalizeMenu := true;
        _isInvoked_FinalizeMenu_HasLines := HasLines;
    end;

    procedure IsInvoked_FinalizeMenu(): Boolean
    begin
        exit(_isInvoked_FinalizeMenu);
    end;

    procedure IsInvoked_FinalizeMenu_HasLines(): Boolean
    begin
        exit(_isInvoked_FinalizeMenu_HasLines);
    end;

    #endregion

    #region GetMenuNos

    var
        _isInvoked_GetMenuNos: Boolean;

    procedure GetMenuNos(): Code[20]
    begin
        _isInvoked_GetMenuNos := true;
        exit('STUBNOS-01');
    end;

    procedure IsInvoked_GetMenuNos(): Boolean
    begin
        exit(_isInvoked_GetMenuNos);
    end;

    #endregion
}

