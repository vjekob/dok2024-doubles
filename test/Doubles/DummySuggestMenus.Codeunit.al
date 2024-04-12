namespace Vjeko.Demos.Restaurant.Test;

using Vjeko.Demos.Restaurant;
using Microsoft.Inventory.Item;

codeunit 60008 "DEMO Dummy Suggest Menus" implements "DEMO Suggest Menus"
{
    procedure WriteMenuLine(var MenuLine: Record "DEMO Menu Line"; RecipeHeader: Record "DEMO Recipe Header"; Servings: Integer)
    begin
    end;

    procedure ProcessRecipeLine(RecipeLine: Record "DEMO Recipe Line"; Item: Record Item; MenuHeader: Record "DEMO Menu Header"; AvailabilityHandler: Interface "DEMO Availability Handler"; UoMMgt: Interface "DEMO Unit of Measure"; Availability: Interface "DEMO Availability Base"; var Servings: Integer)
    begin
    end;

    procedure ProcessRecipe(RecipeHeader: Record "DEMO Recipe Header"; MenuHeader: Record "DEMO Menu Header"; var MenuLine: Record "DEMO Menu Line"; AvailabilityHandler: Interface "DEMO Availability Handler"; UoMMgt: Interface "DEMO Unit of Measure"; Availability: Interface "DEMO Availability Base"; SuggestMenus: Interface "DEMO Suggest Menus"): Boolean
    begin
    end;

    procedure GetItem(RecipeLine: Record "DEMO Recipe Line"; var Item: Record Item): Boolean
    begin
    end;

    procedure InitializeMenu(var MenuHeader: Record "DEMO Menu Header"; var MenuLine: Record "DEMO Menu Line"; Date: Date; NoSeriesMgt: Interface "DEMO NoSeries"; SuggestMenus: Interface "DEMO Suggest Menus")
    begin
    end;

    procedure FinalizeMenu(var MenuHeader: Record "DEMO Menu Header"; HasLines: Boolean)
    begin
    end;

    procedure GetMenuNos(): Code[20]
    begin
    end;
}
