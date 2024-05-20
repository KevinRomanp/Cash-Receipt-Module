pageextension 51102 DSNSalesOrderSubform extends "Sales Order Subform"
{
    layout
    {

        addlast(Control45)
        {
            field("DSNTotal Medio PagoDSN"; "Amount")
            {
                ApplicationArea = all;
                AssistEdit = true;
                Editable = false;
                Caption = 'Total Medio Pago';
                ToolTip = 'Specifies the sum of amounts in the Line Amount field on the sales return order lines.';
                trigger OnAssistEdit()
                var
                    CobrosCajerosPage: Page "DSNCobros Cajeros";

                begin
                    CobrosCajerosPage.GetInvoiceKeys(Rec."Document Type", rec."Document No.");
                    CobrosCajerosPage.RunModal();
                    CurrPage.Update();
                end;
            }
            field(DSNPendienteDSN; Pendiente)
            {
                ApplicationArea = all;
                Editable = false;
                ToolTip = 'Specifies the value of the Pendiente field.';
                Caption = 'Pendiente';
            }
            field(DSNMontoCambioDSN; MontoCambio)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Monto de cambio';
                ToolTip = 'Specifies the value of the Monto de cambio field.';
            }

        }
    }

    var
        DSNCobrosCajeros: Record "Cobros Cajeros";
        SalesHeader: Record "Sales Header";
        DSNFuncionesCobros: Codeunit "DSNFunciones Cobros";
        Pendiente: Decimal;
        MontoCambio: Decimal;
        TotalMedioPago: Decimal;
        TotalMedioPagoLCY: Decimal;
        TotalDocumento: Decimal;
        amount: Decimal;

    trigger OnAfterGetCurrRecord()
    begin
        CalcPendiente();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CalcPendiente();
    end;

    procedure CalcPendiente()
    begin
        Pendiente := 0;
        MontoCambio := 0;
        amount := 0;
        TotalDocumento := DSNFuncionesCobros.TotalDocumento(rec."Document Type", rec."Document No.");
        //TODO: Se le pasa document type y document No (si tuviesen valor, no cambiaria el valor). TotalMedioPago y LCY son VAR por lo tanto, aunque les hayamos puesto valor, se lo pudieramos modificar.
        DSNFuncionesCobros.TotalCobrado(rec."Document Type", rec."Document No.", TotalMedioPago, TotalMedioPagoLCY);
        //TODO: se crea una variable global para almacenar el dato y poder crear condiciones
        if rec."Currency Code" = '' then
            amount := TotalMedioPagoLCY
        else
            amount := TotalMedioPago;
        if TotalDocumento > amount then
            Pendiente := TotalDocumento - amount
        else
            if amount > TotalDocumento then
                MontoCambio := amount - TotalDocumento;
    end;


}