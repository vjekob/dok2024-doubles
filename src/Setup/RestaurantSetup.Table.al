namespace Vjeko.Demos.Restaurant;
using Microsoft.Foundation.NoSeries;

table 50005 "DEMO Restaurant Setup"
{
    Caption = 'Restaurant Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }

        field(2; "Recipe Nos."; Code[20])
        {
            Caption = 'Recipe Nos.';
            TableRelation = "No. Series";
        }

        field(3; "Menu Nos."; Code[20])
        {
            Caption = 'Menu Nos.';
            TableRelation = "No. Series";
        }

        field(4; "StockStalk URL"; Text[250])
        {
            Caption = 'StockStalk URL';
            ExtendedDatatype = Url;
        }

        field(5; "Use StockStalk"; Boolean)
        {
            Caption = 'Use StockStalk';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        StockStalkAPIKey: Label 'STOCKSTALK_API_KEY', Locked = true;

    procedure GetStockStalkAPIKey() APIKey: Text
    var
        StockStalkNotConfiguredErr: Label 'StockStalk API key is not configured. Please configure it in the Restaurant Setup page.';
        ProblemsAccessingAPIKeyErr: Label 'There seems to be a problem accessing your StockStalk API key. Please reconfigure it in the Restaurant Setup page.';
    begin
        if not IsolatedStorage.Contains(StockStalkAPIKey, DataScope::User) then
            Error(StockStalkNotConfiguredErr);

        if not IsolatedStorage.Get(StockStalkAPIKey, DataScope::User, APIKey) then
            Error(ProblemsAccessingAPIKeyErr);
    end;

    procedure SetStockStalkAPIKey(APIKey: Text)
    var
        StockStalkAPIKeyNotSetErr: Label 'There seems to be a problem setting your StockStalk API key. Please try again.';
    begin
        if not IsolatedStorage.Set(StockStalkAPIKey, APIKey, DataScope::User) then
            Error(StockStalkAPIKeyNotSetErr);
    end;
}
