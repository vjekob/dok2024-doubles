namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60015 "DEMO Stub BlockedByEnvironment" implements "DEMO HttpResponse"
{
    procedure HttpStatusCode(): Integer
    begin

    end;

    procedure ReasonPhrase(): Text
    begin

    end;

    procedure IsBlockedByEnvironment(): Boolean
    begin
        exit(true);
    end;

    procedure IsSuccessStatusCode(): Boolean
    begin

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