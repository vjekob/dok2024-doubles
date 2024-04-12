namespace Vjeko.Demos.Restaurant;

table 50004 "DEMO Menu Line"
{
    Caption = 'Menu Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Menu No."; Code[20])
        {
            Caption = 'Menu No.';
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(3; "Recipe No."; Code[20])
        {
            Caption = 'Recipe No.';
            TableRelation = "DEMO Recipe Header";
        }

        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(5; "Available Servings"; Integer)
        {
            Caption = 'Available Servings';
        }

        field(6; Selected; Boolean)
        {
            Caption = 'Selected';
        }
    }

    keys
    {
        key(PK; "Menu No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
