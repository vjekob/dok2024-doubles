namespace Vjeko.Demos.Restaurant;

codeunit 50013 "DEMO HttpResponse" implements "DEMO HttpResponse"
{
    var
        Response: HttpResponseMessage;

    #region Optimiting content access
    var
        _hasBody: Boolean;
        _contentRead: Boolean;
        _content: Text;

    local procedure ReadContentText()
    begin
        if _contentRead then
            exit;

        _hasBody := Response.Content.ReadAs(_content);
        _contentRead := true;
    end;

    #endregion

    internal procedure Initialize(Message: HttpResponseMessage)
    begin
        Response := Message;
    end;

    procedure HttpStatusCode(): Integer;
    begin
        exit(Response.HttpStatusCode);
    end;

    procedure ReasonPhrase(): Text;
    begin
        exit(Response.ReasonPhrase);
    end;

    procedure IsBlockedByEnvironment(): Boolean;
    begin
        exit(Response.IsBlockedByEnvironment);
    end;

    procedure IsSuccessStatusCode(): Boolean;
    begin
        exit(Response.IsSuccessStatusCode);
    end;

    procedure GetContent(): Text
    begin
        ReadContentText();
        if _hasBody then
            exit(_content);
    end;

    procedure HasBody(): Boolean
    begin
        ReadContentText();
        exit(_hasBody);
    end;

    procedure GetHeaders(): HttpHeaders
    begin
        exit(Response.Headers);
    end;
}
