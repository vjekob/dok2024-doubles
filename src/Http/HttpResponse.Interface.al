namespace Vjeko.Demos.Restaurant;

interface "DEMO HttpResponse"
{
    procedure HttpStatusCode(): Integer;
    procedure ReasonPhrase(): Text;
    procedure IsBlockedByEnvironment(): Boolean;
    procedure IsSuccessStatusCode(): Boolean;

    procedure GetContent(): Text;
    procedure HasBody(): Boolean;
    procedure GetHeaders(): HttpHeaders;
}
