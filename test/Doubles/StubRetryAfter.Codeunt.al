namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60014 "DEMO Stub RetryAfter" implements "DEMO HttpResponse"
{
    procedure HttpStatusCode(): Integer
    begin

    end;

    procedure ReasonPhrase(): Text
    begin

    end;

    procedure IsBlockedByEnvironment(): Boolean
    begin

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
    var
        Headers: HttpHeaders;
    begin
        Headers.Add('Retry-After', '5')
    end;
}