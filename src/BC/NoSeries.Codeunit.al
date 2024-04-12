namespace Vjeko.Demos.Restaurant.BC;

using Vjeko.Demos.Restaurant;
using Microsoft.Foundation.NoSeries;

codeunit 50010 "DEMO NoSeries" implements "DEMO NoSeries"
{
    procedure GetNextNo(NoSeriesCode: Code[20]; SeriesDate: Date; ModifySeries: Boolean) Result: Code[20]
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        exit(NoSeriesMgt.GetNextNo(NoSeriesCode, SeriesDate, ModifySeries));
    end;
}
