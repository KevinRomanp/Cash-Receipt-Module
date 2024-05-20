codeunit 51101
"DSNFunciones Cobros"
{
    var
        DSNCobrosCajeros: Record "Cobros Cajeros";
        DSNControlCajeros: Record ControlCajeros;
        errorStCajeroLbl: Label 'Para poder registrar facturas o pedidos, la caja debe estar abierta.';

    [Scope('Cloud')]
    procedure TotalDocumento(TipoDoc2: Enum "Sales Document Type"; NoDoc2: Code[20]): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", TipoDoc2);
        SalesLine.SetRange("Document No.", NoDoc2);
        if SalesLine.FindFirst() then begin
            SalesLine.CalcSums("Amount Including VAT");
            exit(SalesLine."Amount Including VAT");
        end;
    end;

    [Scope('Cloud')]
    procedure TotalDocumentoLCY(TipoDoc2: Enum "Sales Document Type"; NoDoc2: Code[20]): Decimal
    var
        SalesLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
        Currency: record Currency;
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", TipoDoc2);
        SalesLine.SetRange("Document No.", NoDoc2);
        if SalesLine.FindFirst() then begin
            SalesHeader.get(SalesLine."Document Type", SalesLine."Document No.");
            if SalesHeader."Currency Code" <> '' then begin
                Currency.get(SalesHeader."Currency Code");
                SalesLine.CalcSums("Amount Including VAT");
                exit(Round((1 / SalesHeader."Currency Factor") * SalesLine."Amount Including VAT", currency."Amount Rounding Precision"));
            end
            else begin
                SalesLine.CalcSums("Amount Including VAT");
                exit(SalesLine."Amount Including VAT");
            end;
        end;
    end;

    [Scope('Cloud')]
    //TODO: Cuando se le pasan parametros al procecure, si no tiene var por delante y llamamos el procedure, cuando le pasemos parametros, no cambia valor. Ir a SalesInvoiceSubform
    procedure TotalCobrado(TipoDoc2: Enum "Sales Document Type"; NoDoc2: Code[20]; var Amount: Decimal; var AmountLCY: Decimal)

    begin
        //Commit();
        DSNCobrosCajeros.Reset();
        DSNCobrosCajeros.SetRange("Tipo documento", TipoDoc2);
        DSNCobrosCajeros.SetRange("No. Documento", NoDoc2);
        if DSNCobrosCajeros.FindSet() then
            repeat
                DSNCobrosCajeros.CalcSums("Importe", "Importe($)");
                Amount := DSNCobrosCajeros.Importe;
                AmountLCY := DSNCobrosCajeros."Importe($)";
            until DSNCobrosCajeros.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeOnRun', '', false, false)]
    local procedure OnBeforeOnRun(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesType: Enum "Sales Document Type";
    begin
        ValidaCajaAbierta(UserId);
        if (SalesHeader."Document Type" <> SalesType::Invoice) or (SalesHeader."Document Type" <> SalesType::Order) then
            exit;

        DSNCobrosCajeros.Reset();
        DSNCobrosCajeros.SetRange("No. Documento", SalesHeader."No.");
        DSNCobrosCajeros.SetRange("Tipo documento", SalesHeader."Document Type");
        DSNCobrosCajeros.SetFilter(Importe, '<>%1', 0);
        if DSNCobrosCajeros.FindFirst() then begin
            SalesLine.Reset();
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.FindFirst();


        end
    end;

    [Scope('Cloud')]
    procedure CalcImportePendiente(TipoDoc2: Enum "Sales Document Type"; NoDoc2: Code[20]; var TotalDoc: Decimal; var TotalMedioPagoLCY: Decimal; var TotalMedioPago: Decimal; var Pendiente: Decimal; var MontoCambio: Decimal)
    begin
        Pendiente := 0;
        MontoCambio := 0;
        TotalMedioPagoLCY := 0;
        TotalCobrado(TipoDoc2, NoDoc2, TotalMedioPago, TotalMedioPagoLCY);
        //TODO: Como actualizar una variable sin tener que moverme de linea:

        if TotalDoc > TotalMedioPagoLCY then
            Pendiente := TotalDoc - TotalMedioPagoLCY
        else
            if TotalMedioPagoLCY > TotalDoc then
                MontoCambio := TotalMedioPagoLCY - TotalDoc
    end;

    [Scope('Cloud')]
    procedure ValidaCajaAbierta(UserId: Code[50])
    var
        DSNCajeros: Record Cajeros;
    begin
        DSNCajeros.Reset();
        DSNCajeros.SetRange(Cajero, UserId);
        if DSNCajeros.FindFirst() then begin
            DSNControlCajeros.Reset();
            DSNControlCajeros.SetRange(Usuario, UserId);
            DSNControlCajeros.SetRange(EstadoRegistro, DSNControlCajeros.EstadoRegistro::Abierto);
            if not DSNControlCajeros.FindFirst() then
                Error(errorStCajeroLbl);
        end;
    end;
}