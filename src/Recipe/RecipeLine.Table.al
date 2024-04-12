namespace Vjeko.Demos.Restaurant;

using Microsoft.Inventory.Item;

table 50001 "DEMO Recipe Line"
{
    Caption = 'Recipe Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Recipe No."; Code[20])
        {
            Caption = 'Recipe No.';
            TableRelation = "DEMO Recipe Header";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }

        field(4; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure" where("Item No." = field("Item No."));
        }

        field(5; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
    }

    keys
    {
        key(PK; "Recipe No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
