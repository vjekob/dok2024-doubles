namespace Vjeko.Demos.Restaurant;

using Microsoft.Inventory.Item;

interface "DEMO Suggest Menus"
{
    procedure InitializeMenu(var MenuHeader: Record "DEMO Menu Header"; var MenuLine: Record "DEMO Menu Line"; Date: Date; NoSeriesMgt: Interface "DEMO NoSeries"; SuggestMenus: Interface "DEMO Suggest Menus");
    procedure FinalizeMenu(var MenuHeader: Record "DEMO Menu Header"; HasLines: Boolean);
    procedure GetMenuNos(): Code[20];
    procedure ProcessRecipe(RecipeHeader: Record "DEMO Recipe Header"; MenuHeader: Record "DEMO Menu Header"; var MenuLine: Record "DEMO Menu Line"; AvailabilityHandler: Interface "DEMO Availability Handler"; UoMMgt: Interface "DEMO Unit of Measure"; Availability: Interface "DEMO Availability Base"; SuggestMenus: Interface "DEMO Suggest Menus"): Boolean;
    procedure GetItem(RecipeLine: Record "DEMO Recipe Line"; var Item: Record Item): Boolean;
    procedure ProcessRecipeLine(RecipeLine: Record "DEMO Recipe Line"; Item: Record Item; MenuHeader: Record "DEMO Menu Header"; AvailabilityHandler: Interface "DEMO Availability Handler"; UoMMgt: Interface "DEMO Unit of Measure"; Availability: Interface "DEMO Availability Base"; var Servings: Integer)
    procedure WriteMenuLine(var MenuLine: Record "DEMO Menu Line"; RecipeHeader: Record "DEMO Recipe Header"; Servings: Integer)
}
