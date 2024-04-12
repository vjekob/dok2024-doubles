namespace Vjeko.Demos.Restaurant;

interface "DEMO Availability Handler"
{
    procedure Initialize(var Recipe: Record "DEMO Recipe Header"; Date: Date);
    procedure GetAvailableQty(ItemNo: Code[20]): Decimal;
}
