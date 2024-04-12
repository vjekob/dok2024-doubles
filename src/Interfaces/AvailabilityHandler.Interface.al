namespace Vjeko.Demos.Restaurant;

interface "DEMO Availability Handler"
{
    procedure Initialize(var Recipe: Record "DEMO Recipe Header"; Date: Date; Client: Interface "DEMO HttpClient");
    procedure GetAvailableQty(ItemNo: Code[20]): Decimal;
}
