namespace Vjeko.Demos.Restaurant;

interface "DEMO NoSeries"
{
    procedure GetNextNo(NoSeriesCode: Code[20]; SeriesDate: Date; ModifySeries: Boolean) Result: Code[20];
}
