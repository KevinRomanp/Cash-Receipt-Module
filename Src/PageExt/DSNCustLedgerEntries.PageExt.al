pageextension 51103 DSNCustLedgerEntries extends "Customer Ledger Entries"
{
    layout
    {
    }
    actions
    {
        addlast("F&unctions")
        {
            Action(ImprimirInforme)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Re-Imprimir Recibo';
                Image = PrintReport;
                ToolTip = 'Executes the Re-Imprimir Recibo action.';
                trigger OnAction()
                var
                    CustLedgEntr: Record "Cust. Ledger Entry";
                    ConfigEmpresa: Record "Config. Empresas";
                begin
                    ConfigEmpresa.Get();
                    ConfigEmpresa.TestField(ReciboIngreso);
                    CurrPage.SetSelectionFilter(CustLedgEntr);
                    rec.TestField("Document Type", rec."Document Type"::Payment);
                    Report.Run(ConfigEmpresa.ReciboIngreso, true, true, CustLedgEntr);
                end;
            }
        }
    }
}