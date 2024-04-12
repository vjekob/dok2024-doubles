namespace Vjeko.Demos.Restaurant.StockStalk;

enum 50004 "DEMO StockStalk Request Status"
{
    Caption = 'StockStalk Request Status';
    Extensible = false;
    AssignmentCompatibility = false;

    value(0; Uninitialized) { Caption = 'Uninitialized'; }
    value(1; Ready) { Caption = 'Ready'; }

    value(2; Created) { Caption = 'Created'; }
    value(3; Pending) { Caption = 'Pending'; }
    value(4; Processing) { Caption = 'Processing'; }
    value(5; Completed) { Caption = 'Completed'; }
}
