namespace Vjeko.Demos.Restaurant.Test;

using Vjeko.Demos.Restaurant;
using Vjeko.Demos.Restaurant.StockStalk;

codeunit 60003 "DEMO Test StockStalk"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRestaurant: Codeunit "DEMO Library - Restaurant";
        DummyTelemetry: Codeunit "DEMO Dummy Telemetry";

    procedure Initialize()
    var
        Menu: Record "DEMO Menu Header";
        MenuLine: Record "DEMO Menu Line";
        RecipeHeader: Record "DEMO Recipe Header";
        RecipeLine: Record "DEMO Recipe Line";
        RestaurantSetup: Record "DEMO Restaurant Setup";
    begin
        Menu.DeleteAll();
        MenuLine.DeleteAll();

        RecipeHeader.DeleteAll();
        RecipeLine.DeleteAll();

        if not RestaurantSetup.Get() then
            RestaurantSetup.Insert();
    end;

    // [Test]
    // procedure Integration_HappyPath()
    // var
    //     RestaurantSetup: Record "DEMO Restaurant Setup";
    //     RecipeHeader: Record "DEMO Recipe Header";
    //     RecipeLine: Record "DEMO Recipe Line";
    //     Item: Record Item;
    //     StockStalk: Codeunit "DEMO StockStalk Availability";
    //     Client: Codeunit "DEMO HttpClient";
    //     Quantity: Decimal;
    //     i, j : Integer;
    // begin
    //     // [SCENARIO] Tests the happy path through StockStalk process
    //     Initialize();

    //     // [GIVEN] Three recipes with three lines each
    //     for i := 1 to 3 do begin
    //         LibraryRestaurant.CreateRecipe(RecipeHeader);
    //         for j := 1 to 3 do
    //             LibraryRestaurant.CreateRecipeLine(RecipeLine, RecipeHeader."No.");
    //     end;

    //     // [GIVEN] StockStalk ID assigned to all items
    //     RecipeLine.FindSet();
    //     repeat
    //         Item.Get(RecipeLine."Item No.");
    //         Item."DEMO StockStalk Item ID" := Item."No.";
    //         Item.Modify();
    //     until RecipeLine.Next() = 0;

    //     // [GIVEN] Correct restaurant setup
    //     RestaurantSetup.Get();
    //     RestaurantSetup."StockStalk URL" := 'https://stockstalk.azurewebsites.net/api/v1';
    //     RestaurantSetup.SetStockStalkAPIKey('JF4Rlt_Rf3wLJ7EojF41SV6Us9t7SuSbAVfg9hkOpcYGAzFupMoMtg==');
    //     RestaurantSetup."Use StockStalk" := true;
    //     RestaurantSetup.Modify();

    //     // [WHEN] StockStalk updates stock levels
    //     StockStalk.Initialize(RecipeHeader, Today(), Client);

    //     // [THEN] Availability must be updated
    //     RecipeLine.Reset();
    //     RecipeLine.FindSet(false);
    //     repeat
    //         Quantity := StockStalk.GetAvailableQty(RecipeLine."Item No.");
    //         Assert.AreNotEqual(0, Quantity, 'StockStalk available quantity must be different than 0.'); // Oops... 🤔
    //     until RecipeLine.Next() = 0;
    // end;

    [Test]
    procedure ProcessResponse_Created_NoRequestId_Error()
    var
        Created: Codeunit "DEMO StockStalk Resp. Created";
        BadJson: JsonObject;
        Response: JsonArray;
        RequestId: Text;
    begin
        asserterror Created.ProcessResponse(BadJson, RequestId, Response, DummyTelemetry);
        Assert.IsTrue(GetLastErrorText().StartsWith('Unexpected response from StockStalk: request ID missing'), 'Unexpected error message.');
    end;

    [Test]
    procedure ProcessResponse_Created_RequestId_Changes()
    var
        Created: Codeunit "DEMO StockStalk Resp. Created";
        GoodJson: JsonObject;
        Response: JsonArray;
        RequestId: Text;
    begin
        GoodJson.Add('requestId', 'TEST-02');
        RequestId := 'TEST-01';

        Created.ProcessResponse(GoodJson, RequestId, Response, DummyTelemetry);

        Assert.AreEqual('TEST-02', RequestId, 'Request ID must be changed.');
    end;

    [Test]
    procedure ProcessResponse_Completed_NoItems_Error()
    var
        Completed: Codeunit "DEMO StockStalk Resp. Compl.";
        BadJson: JsonObject;
        Response: JsonArray;
        RequestId: Text;
    begin
        asserterror Completed.ProcessResponse(BadJson, RequestId, Response, DummyTelemetry);
        Assert.IsTrue(GetLastErrorText().StartsWith('Unexpected response from StockStalk: items array missing'), 'Unexpected error message.');
    end;

    [Test]
    procedure ProcessResponse_Completed_NotArray_Error()
    var
        Completed: Codeunit "DEMO StockStalk Resp. Compl.";
        BadJson: JsonObject;
        Response: JsonArray;
        RequestId: Text;
    begin
        BadJson.Add('items', 'not an array');
        asserterror Completed.ProcessResponse(BadJson, RequestId, Response, DummyTelemetry);
        Assert.IsTrue(GetLastErrorText().StartsWith('Unexpected response from StockStalk: items array missing'), 'Unexpected error message.');
    end;

    [Test]
    procedure ProcessResponse_Completed_Changes()
    var
        Completed: Codeunit "DEMO StockStalk Resp. Compl.";
        GoodJson: JsonObject;
        Response, Input : JsonArray;
        ResponseText, InputText : Text;
        RequestId: Text;
    begin
        Input.Add('item1');
        GoodJson.Add('items', Input);

        Completed.ProcessResponse(GoodJson, RequestId, Response, DummyTelemetry);

        Response.WriteTo(ResponseText);
        Input.WriteTo(InputText);
        Assert.AreEqual(InputText, ResponseText, 'Response must be the same as input.');
    end;

    [Test]
    procedure ProcessResponse_ChangesId()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        MockProcessResponse: Codeunit "DEMO Mock StockStalk ProcResp";
        DummyJson: JsonObject;
        Response: JsonArray;
        RequestId: Text;
    begin
        RequestId := 'TEST-01';
        MockProcessResponse.SetValue_RequestId('TEST-02');

        StockStalkRequest.ProcessResponse(DummyJson, RequestId, Response, MockProcessResponse, DummyTelemetry);

        Assert.AreEqual('TEST-02', RequestId, 'Request ID must be changed.');
    end;

    [Test]
    procedure ProcessResponse_Keeps()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        MockProcessResponse: Codeunit "DEMO Mock StockStalk ProcResp";
        DummyJson: JsonObject;
        Response: JsonArray;
        RequestId: Text;
    begin
        RequestId := 'TEST-01';
        MockProcessResponse.SetValue_RequestId('TEST-01');

        StockStalkRequest.ProcessResponse(DummyJson, RequestId, Response, MockProcessResponse, DummyTelemetry);

        Assert.AreEqual('TEST-01', RequestId, 'Request ID must be changed.');
    end;

    [Test]
    procedure UpdateStatus_NoStatus_Error()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        BadJson: JsonObject;
        Status: Enum "DEMO StockStalk Request Status";
    begin
        asserterror StockStalkRequest.UpdateStatus(BadJson, Status, DummyTelemetry);
        Assert.IsTrue(GetLastErrorText().StartsWith('Unexpected response from StockStalk: status missing'), 'Unexpected error message.');
    end;

    [Test]
    procedure UpdateStatus_Unexpected_Error()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        BadJson: JsonObject;
        Status: Enum "DEMO StockStalk Request Status";
    begin
        BadJson.Add('status', 'unexpected');
        asserterror StockStalkRequest.UpdateStatus(BadJson, Status, DummyTelemetry);
        Assert.IsTrue(GetLastErrorText().StartsWith('Unknown status "unexpected"'), 'Unexpected error message.');
    end;

    [Test]
    procedure UpdateStatus_Created()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        GoodJson: JsonObject;
        Status: Enum "DEMO StockStalk Request Status";
    begin
        GoodJson.Add('status', 'created');
        StockStalkRequest.UpdateStatus(GoodJson, Status, DummyTelemetry);
        Assert.AreEqual(Status, "DEMO StockStalk Request Status"::Created, 'Status must be "created".');
    end;

    [Test]
    procedure UpdateStatus_Pending()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        GoodJson: JsonObject;
        Status: Enum "DEMO StockStalk Request Status";
    begin
        GoodJson.Add('status', 'pending');
        StockStalkRequest.UpdateStatus(GoodJson, Status, DummyTelemetry);
        Assert.AreEqual(Status, "DEMO StockStalk Request Status"::Pending, 'Status must be "pending".');
    end;

    [Test]
    procedure UpdateStatus_Processing()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        GoodJson: JsonObject;
        Status: Enum "DEMO StockStalk Request Status";
    begin
        GoodJson.Add('status', 'processing');
        StockStalkRequest.UpdateStatus(GoodJson, Status, DummyTelemetry);
        Assert.AreEqual(Status, "DEMO StockStalk Request Status"::Processing, 'Status must be "processing".');
    end;

    [Test]
    procedure UpdateStatus_Completed()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        GoodJson: JsonObject;
        Status: Enum "DEMO StockStalk Request Status";
    begin
        GoodJson.Add('status', 'completed');
        StockStalkRequest.UpdateStatus(GoodJson, Status, DummyTelemetry);
        Assert.AreEqual(Status, "DEMO StockStalk Request Status"::Completed, 'Status must be "completed".');
    end;

    [Test]
    procedure UpdateStatus_Unchanged()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        SpyTelemetry: Codeunit "DEMO Spy Telemetry";
        GoodJson: JsonObject;
        Status, NewStatus : Enum "DEMO StockStalk Request Status";
    begin
        GoodJson.Add('status', 'processing');
        Status := "DEMO StockStalk Request Status"::Processing;
        NewStatus := Status;

        StockStalkRequest.UpdateStatus(GoodJson, NewStatus, SpyTelemetry);
        Assert.AreEqual(Status, NewStatus, 'Status must be unchanged.');
        Assert.IsFalse(SpyTelemetry.IsInvoked_SendToTelemetry(), 'Telemetry must not be sent.');
    end;

    [Test]
    procedure ConfigureAwaitTime();
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        StubRetryAfter: Codeunit "DEMO Stub RetryAfter";
        Timestamp, NewTimestamp : DateTime;
    begin
        Timestamp := CreateDateTime(Today(), 0T);
        NewTimestamp := Timestamp;

        StockStalkRequest.ConfigureAwaitTime(StubRetryAfter, NewTimestamp);

        Assert.AreEqual(Timestamp + 5000, NewTimestamp, 'Timestamp must be increased by 5 seconds.');
    end;

    [Test]
    procedure ProcessResponseMessage_Blocked()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        StubBlockedByEnvironment: Codeunit "DEMO Stub BlockedByEnvironment";
        Status: Enum "DEMO StockStalk Request Status";
        Response: JsonObject;
        RequestId: Text;
    begin
        asserterror StockStalkRequest.ProcessResponseMessage(StubBlockedByEnvironment, Response, Status, DummyTelemetry);
        Assert.IsTrue(GetLastErrorText().StartsWith('StockStalk request is blocked by environment'), 'Unexpected error message.');
    end;

    [Test]
    procedure ProcessResponseMessage_200()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        Stub200: Codeunit "DEMO Stub 200";
        Status: Enum "DEMO StockStalk Request Status";
        SpyTelemetry: Codeunit "DEMO Spy Telemetry";
        Response: JsonObject;
        ResponseText: Text;
    begin
        StockStalkRequest.ProcessResponseMessage(Stub200, Response, Status, SpyTelemetry);
        Response.WriteTo(ResponseText);

        Assert.IsTrue(SpyTelemetry.IsInvoked_SendToTelemetry(), 'Telemetry must be sent.');
        Assert.AreEqual('ST012', SpyTelemetry.IsInvoked_SendToTelemetry_EventId(), 'Telemetry event ID must be "ST012".');
        Assert.AreEqual('{"message":"stub"}', ResponseText, 'Response not set');
    end;

    [Test]
    procedure ProcessResponseMessage_401()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        MockHttpError: Codeunit "DEMO Mock Http Error";
        Status: Enum "DEMO StockStalk Request Status";
        Response: JsonObject;
    begin
        MockHttpError.Set_HttpStatusCode(401);
        asserterror StockStalkRequest.ProcessResponseMessage(MockHttpError, Response, Status, DummyTelemetry);
        Assert.IsTrue(GetLastErrorText().StartsWith('Unauthorized access to StockStalk'), 'Unexpected error message.');
    end;

    [Test]
    procedure ProcessResponseMessage_UnexpectedStatus()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        MockHttpError: Codeunit "DEMO Mock Http Error";
        Status: Enum "DEMO StockStalk Request Status";
        Response: JsonObject;
    begin
        MockHttpError.Set_HttpStatusCode(521);
        asserterror StockStalkRequest.ProcessResponseMessage(MockHttpError, Response, Status, DummyTelemetry);
        Assert.IsTrue(GetLastErrorText().StartsWith('Unexpected status 521'), 'Unexpected error message.');
    end;

    [Test]
    procedure ProcessResponseMessage_404_Completes()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        MockHttpError: Codeunit "DEMO Mock Http Error";
        Status: Enum "DEMO StockStalk Request Status";
        Response: JsonObject;
    begin
        MockHttpError.Set_HttpStatusCode(404);
        StockStalkRequest.ProcessResponseMessage(MockHttpError, Response, Status, DummyTelemetry);
        Assert.AreEqual("DEMO StockStalk Request Status"::Completed, Status, 'Status must be "completed".');
    end;

    [Test]
    procedure ProcessResponseMessage_410_Completes()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        MockHttpError: Codeunit "DEMO Mock Http Error";
        Status: Enum "DEMO StockStalk Request Status";
        Response: JsonObject;
    begin
        MockHttpError.Set_HttpStatusCode(410);
        StockStalkRequest.ProcessResponseMessage(MockHttpError, Response, Status, DummyTelemetry);
        Assert.AreEqual("DEMO StockStalk Request Status"::Completed, Status, 'Status must be "completed".');
    end;

    [Test]
    procedure SendAndUpdateState_ClientError()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        MockHttpClient: Codeunit "DEMO Mock HttpClient";
        SpyTelemetry: Codeunit "DEMO Spy Telemetry";
        NotSent: Codeunit "DEM HttpResponse Not Sent";
        Request: HttpRequestMessage;
        Response: JsonObject;
        Result: Boolean;
    begin
        MockHttpClient.SetReturn(false);
        MockHttpClient.SetResponse(NotSent);

        Result := StockStalkRequest.SendAndUpdateState(Request, Response, MockHttpClient, SpyTelemetry);

        Assert.IsFalse(Result, 'Request must not be sent.');
        Assert.IsTrue(SpyTelemetry.IsInvoked_SendToTelemetry(), 'Telemetry must be sent.');
        Assert.AreEqual('ST001', SpyTelemetry.IsInvoked_SendToTelemetry_EventId(), 'Telemetry event ID must be "ST001".');
    end;

    [Test]
    procedure SendAndUpdateState_Sent_410()
    var
        StockStalkRequest: Codeunit "DEMO StockStalk Request";
        MockHttpClient: Codeunit "DEMO Mock HttpClient";
        SpyTelemetry: Codeunit "DEMO Spy Telemetry";
        MockHttpError: Codeunit "DEMO Mock Http Error";
        Request: HttpRequestMessage;
        Response: JsonObject;
        Result: Boolean;
    begin
        MockHttpError.Set_HttpStatusCode(410);
        MockHttpClient.SetReturn(true);
        MockHttpClient.SetResponse(MockHttpError);

        Result := StockStalkRequest.SendAndUpdateState(Request, Response, MockHttpClient, SpyTelemetry);

        Assert.IsFalse(Result, 'Request must not be sent.');
        Assert.IsTrue(SpyTelemetry.IsInvoked_SendToTelemetry(), 'Telemetry must be sent.');
        Assert.AreEqual("DEMO StockStalk Request Status"::Completed, StockStalkRequest.Status, 'Status must be "completed".');
    end;
}
