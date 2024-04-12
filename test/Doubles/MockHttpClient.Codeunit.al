namespace Vjeko.Demos.Restaurant.Test;
using Vjeko.Demos.Restaurant;

codeunit 60018 "DEMO Mock Httpclient" implements "DEMO HttpClient"
{
    var
        _response: Interface "DEMO HttpResponse";
        _return: Boolean;

    procedure Send(Request: HttpRequestMessage; var Response: Interface "DEMO HttpResponse"): Boolean
    begin
        Response := _response;
        exit(_return);
    end;

    procedure SetReturn(Return: Boolean)
    begin
        _return := Return;
    end;

    procedure SetResponse(Response: Interface "DEMO HttpResponse")
    begin
        _response := Response;
    end;
}
