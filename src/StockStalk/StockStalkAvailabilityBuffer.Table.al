namespace Vjeko.Demos.Restaurant.StockStalk;

table 50011 "DEMO StockStalk Avail. Buffer"
{
    Caption = 'StockStalk Availability Buffer';
    TableType = Temporary;

    fields
    {
        field(1; "StockStalk Id"; Text[250])
        {
            Caption = 'StockStalk Id';
        }

        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }

        field(3; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
        }

        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
    }
}
