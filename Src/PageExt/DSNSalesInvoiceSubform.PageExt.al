pageextension 51101 DSNSalesInvoiceSubform extends "Sales Invoice Subform"
{
    layout
    {

        addlast(Control39)
        {
            field("DSNTotal Medio PagoDSN"; "DSNAmount")
            {
                ApplicationArea = all;
                Caption = 'Total Medio Pago';
                AssistEdit = true;
                Editable = false;
                ToolTip = 'Specifies the value of the DSNAmount field.';
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
                Caption = 'Pendiente';
                ToolTip = 'Specifies the value of the Pendiente field.';
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
        SalesHeader: Record "Sales Header";
        DSNCobrosCajeros: Record "Cobros Cajeros";
        DSNFuncionesCobros: Codeunit "DSNFunciones Cobros";
        Pendiente: Decimal;
        MontoCambio: Decimal;
        TotalMedioPago: Decimal;
        TotalMedioPagoLCY: Decimal;
        TotalDocumento: Decimal;
        DSNamount: Decimal;

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
        DSNamount := 0;
        TotalDocumento := DSNFuncionesCobros.TotalDocumento(rec."Document Type", rec."Document No.");
        //TODO: Se le pasa document type y document No (si tuviesen valor, no cambiaria el valor). TotalMedioPago y LCY son VAR por lo tanto, aunque les hayamos puesto valor, se lo pudieramos modificar.
        DSNFuncionesCobros.TotalCobrado(rec."Document Type", rec."Document No.", TotalMedioPago, TotalMedioPagoLCY);
        //TODO: se crea una variable global para almacenar el dato y poder crear condiciones
        if rec."Currency Code" = '' then
            DSNamount := TotalMedioPagoLCY
        else
            DSNamount := TotalMedioPago;
        if TotalDocumento > DSNamount then
            Pendiente := TotalDocumento - DSNamount
        else
            if DSNamount > TotalDocumento then
                MontoCambio := DSNamount - TotalDocumento;
    end;


}