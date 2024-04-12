codeunit 70001 "Upgrade Tests"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        InstallTests: Codeunit "Install Tests";
    begin
        InstallTests.SetupTestSuite();
    end;
}
