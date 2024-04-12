namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60017 "DEMO Mock Http Error" implements "DEMO HttpResponse"
{
    var
        _httpStatusCode: Integer;

    procedure HttpStatusCode(): Integer
    begin
        exit(_httpStatusCode);
    end;

    procedure Set_HttpStatusCode(Value: Integer)
    begin
        _httpStatusCode := Value;
    end;

    procedure ReasonPhrase(): Text
    begin

    end;

    procedure IsBlockedByEnvironment(): Boolean
    begin

    end;

    procedure IsSuccessStatusCode(): Boolean
    begin
        exit(false);
    end;

    procedure GetContent(): Text
    begin

    end;

    procedure HasBody(): Boolean
    begin

    end;

    procedure GetHeaders(): HttpHeaders
    begin

    end;
}