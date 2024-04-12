namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60016 "DEMO Stub 200" implements "DEMO HttpResponse"
{
    procedure HttpStatusCode(): Integer
    begin
        exit(200);
    end;

    procedure ReasonPhrase(): Text
    begin

    end;

    procedure IsBlockedByEnvironment(): Boolean
    begin

    end;

    procedure IsSuccessStatusCode(): Boolean
    begin
        exit(true);
    end;

    procedure GetContent(): Text
    begin
        exit('{ "message": "stub" }');
    end;

    procedure HasBody(): Boolean
    begin
        exit(true);
    end;

    procedure GetHeaders(): HttpHeaders
    begin

    end;
}