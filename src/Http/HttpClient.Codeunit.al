namespace Vjeko.Demos.Restaurant;

codeunit 50012 "DEMO HttpClient" implements "DEMO HttpClient"
{
    procedure Send(Request: HttpRequestMessage; var Response: Interface "DEMO HttpResponse") Result: Boolean
    var
        HttpResponse: Codeunit "DEMO HttpResponse";
        HttpResponseNotSent: Codeunit "DEM HttpResponse Not Sent";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
    begin
        // To fall back in case sending fails
        Response := HttpResponseNotSent;

        Result := Client.Send(Request, ResponseMessage);

        // If sending succeeded, initialize the actual response from the response message received
        HttpResponse.Initialize(ResponseMessage);
        Response := HttpResponse;
    end;
}
