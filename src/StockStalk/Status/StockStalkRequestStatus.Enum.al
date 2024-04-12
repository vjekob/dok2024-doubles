namespace Vjeko.Demos.Restaurant.StockStalk;

enum 50004 "DEMO StockStalk Request Status" implements "DEMO StockStalk Process Response"
{
    Caption = 'StockStalk Request Status';
    Extensible = false;
    AssignmentCompatibility = false;

    value(0; Uninitialized)
    {
        Caption = 'Uninitialized';
        Implementation = "DEMO StockStalk Process Response" = "DEMO StockStalk Resp. None";
    }

    value(1; Ready)
    {
        Caption = 'Ready';
        Implementation = "DEMO StockStalk Process Response" = "DEMO StockStalk Resp. None";
    }


    value(2; Created)
    {
        Caption = 'Created';
        Implementation = "DEMO StockStalk Process Response" = "DEMO StockStalk Resp. Created";
    }

    value(3; Pending)
    {
        Caption = 'Pending';
        Implementation = "DEMO StockStalk Process Response" = "DEMO StockStalk Resp. None";
    }

    value(4; Processing)
    {
        Caption = 'Processing';
        Implementation = "DEMO StockStalk Process Response" = "DEMO StockStalk Resp. None";
    }

    value(5; Completed)
    {
        Caption = 'Completed';
        Implementation = "DEMO StockStalk Process Response" = "DEMO StockStalk Resp. Compl.";
    }
}
