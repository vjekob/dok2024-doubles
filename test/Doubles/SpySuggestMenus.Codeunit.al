namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60007 "DEMO Spy Suggest Menus" implements "DEMO Suggest Menus"
{
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
}
