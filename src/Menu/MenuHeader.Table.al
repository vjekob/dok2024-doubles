namespace Vjeko.Demos.Restaurant;

table 50003 "DEMO Menu Header"
{
    Caption = 'Menu Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }

        field(2; Date; Date)
        {
            Caption = 'Date';
        }

        field(3; Warning; Boolean)
        {
            Caption = 'Warning';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

}
