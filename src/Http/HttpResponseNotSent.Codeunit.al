namespace Vjeko.Demos.Restaurant;

codeunit 50014 "DEM HttpResponse Not Sent" implements "DEMO HttpResponse"
{
    procedure HttpStatusCode(): Integer;
    begin
        exit(0);
    end;

    procedure ReasonPhrase(): Text;
    begin
        exit('');
    end;

    procedure IsBlockedByEnvironment(): Boolean;
    begin
        exit(false);
    end;

    procedure IsSuccessStatusCode(): Boolean;
    begin
        exit(false);
    end;

    procedure GetContent(): Text;
    begin
        exit('');
    end;

    procedure HasBody(): Boolean;
    begin
        exit(false);
    end;

    procedure GetHeaders(): HttpHeaders
    begin
    end;
}
