namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60008 "DEMO Dummy Suggest Menus" implements "DEMO Suggest Menus"
{
    procedure WriteMenuLine(var MenuLine: Record "DEMO Menu Line"; RecipeHeader: Record "DEMO Recipe Header"; Servings: Integer)
    begin
    end;

    procedure IsInvoked_WriteMenuLine(): Boolean
    begin
    end;
}
