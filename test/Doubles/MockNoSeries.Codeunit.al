namespace Vjeko.Demos.Restaurant.Test;

using Vjeko.Demos.Restaurant;

codeunit 60010 "DEMO Mock NoSeries" implements "DEMO NoSeries"
{
    var
        _invokedWith_GetNextNo_NoSeriesCode: Code[20];

    procedure GetNextNo(NoSeriesCode: Code[20]; SeriesDate: Date; ModifySeries: Boolean) Result: Code[20]
    begin
        _invokedWith_GetNextNo_NoSeriesCode := NoSeriesCode;
        exit('STUB-01');
    end;

    procedure InvokedWith_GetNextNo_NoSeriesCode() Result: Code[20]
    begin
        exit(_invokedWith_GetNextNo_NoSeriesCode);
    end;
}
