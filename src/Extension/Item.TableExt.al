namespace Vjeko.Demos.Restaurant;

using Microsoft.Inventory.Item;

tableextension 50005 "DEMO Item Ext." extends Item
{
    fields
    {
        field(50000; "DEMO StockStalk Item ID"; Text[250])
        {
            Caption = 'StockStalk Item ID';
            DataClassification = CustomerContent;
        }
    }
}