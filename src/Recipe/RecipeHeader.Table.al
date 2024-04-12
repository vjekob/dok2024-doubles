namespace Vjeko.Demos.Restaurant;

using Microsoft.Foundation.NoSeries;

table 50002 "DEMO Recipe Header"
{
    Caption = 'Recipe Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }

        field(2; Description; Code[100])
        {
            Caption = 'Description';
        }

        field(3; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }

        field(4; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }


    var
        RestaurantSetup: Record "DEMO Restaurant Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            RestaurantSetup.Get();
            RestaurantSetup.TestField("Recipe Nos.");
            NoSeriesMgt.InitSeries(RestaurantSetup."Recipe Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;
}
