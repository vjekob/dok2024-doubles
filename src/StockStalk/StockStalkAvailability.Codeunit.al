namespace Vjeko.Demos.Restaurant.StockStalk;
using Vjeko.Demos.Restaurant;
using Microsoft.Inventory.Item;

codeunit 50007 "DEMO StockStalk Availability"
{

    var
        _availability: Record "DEMO StockStalk Avail. Buffer" temporary;
        _stockStalkRequest: Codeunit "DEMO StockStalk Request";
        _requestActive: Boolean;
        _processedAvailability: Boolean;

    procedure Initialize(var Recipe: Record "DEMO Recipe Header"; Date: Date)
    begin
        if not _stockStalkRequest.Create(Recipe, Date) then
            exit;

        if not _stockStalkRequest.Send() then
            exit;

        _requestActive := true;
    end;

    procedure GetAvailableQty(ItemNo: Code[20]): Decimal
    begin
        if not _requestActive then
            exit(0);

        AwaitAvailability();

        _availability.Reset();
        _availability.SetRange("Item No.", ItemNo);
        if not _availability.FindFirst() then
            exit;

        exit(_availability.Quantity);
    end;

    local procedure AwaitAvailability()
    begin
        if not _requestActive then
            exit;

        if _processedAvailability then
            exit;

        _processedAvailability := true;

        while _stockStalkRequest.Status() <> "DEMO StockStalk Request Status"::Completed do begin
            _stockStalkRequest.AwaitNextRetry();
            if not _stockStalkRequest.Check() then
                exit;
        end;

        _stockStalkRequest.ProcessAvailability(_availability);
        UpdateItemNos();
    end;

    local procedure UpdateItemNos()
    var
        Item: Record Item;
    begin
        _availability.Reset();
        if not _availability.FindSet(true) then
            exit;

        repeat
            Item.SetRange("DEMO StockStalk Item ID", _availability."StockStalk Id");
            if Item.FindFirst() then begin
                _availability."Item No." := Item."No.";
                _availability.Modify();
            end;
        until _availability.Next() = 0;

        _availability.SetRange("Item No.", '');
        _availability.DeleteAll();
        _availability.Reset();
    end;
}
