namespace Vjeko.Demos.Restaurant;

interface "DEMO HttpClient"
{
    procedure Send(Request: HttpRequestMessage; var Response: Interface "DEMO HttpResponse"): Boolean;
}
