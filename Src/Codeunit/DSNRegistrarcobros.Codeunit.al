codeunit 51100 "DSNRegistrar cobros"
{
    Permissions =
        tabledata Cajeros = R,
        tabledata "Cobros Cajeros" = RIMD,
        tabledata "Conf. Medios de Pagos" = R,
        tabledata "Gen. Journal Line" = R,
        tabledata "Sales Header" = R,
        tabledata "Sales Invoice Header" = R,
        tabledata "Sales Invoice Line" = R,
        tabledata "User Setup" = R;

    var
        DSNConfMediosDePagos: Record "Conf. Medios de Pagos";

        DSNCobroscajeros: record "Cobros Cajeros";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnRunOnBeforePostICGenJnl', '', false, false)]
    local procedure OnRunOnBeforePostICGenJnl(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var SrcCode: Code[10]; var GenJnlLineDocType: Enum "Gen. Journal Document Type"; GenJnlLineDocNo: Code[20])
    var
        ConfMediosdepagos: Record "Conf. Medios de Pagos";

        SIH2: Record "Sales Invoice Header";
        Cajeros: Record Cajeros;
        Currency: Record Currency;
        GenJnlLine: Record "Gen. Journal Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        CobrosCajeros: Record "Cobros Cajeros";
        UserSetup: Record "User Setup";
        CobrosCajeros2: Record "Cobros Cajeros";
        FuncionesCobros: Codeunit "DSNFunciones Cobros";
        SalesType: Enum "Sales Document Type";
        MontoCambio: Decimal;
        ImporteTotalPagado: Decimal;
        TotalMedioPago: Decimal;
        TotalMedioPagoLCY: Decimal;
        MontoFactura: Decimal;
        NoLin: Integer;
        HayEfectivo: Boolean;
        Msg003Lbl: Label 'El importe cobrado es menor al total facturado.';
        Msg004Lbl: Label 'Cobro liq. %1 #%2', Comment = '%1 =No Doc; %2 = ';
        Msg005Lbl: Label 'Cobro liq. %1', Comment = '%1 =No Doc';
        ErrorNoAceptaEfectivoLbl: Label 'El método de pago %1 no acepta devolución de efectivo.', Comment = '%1 = metodo de pago';
        errorEfectivoLbl: Label 'Debe pagar el monto exacto o utilizar efectivo para darle cambio.';
        ErrorDivisaDifLbl: Label 'No puede pagar con divisas diferentes a la de la cabecera. Por favor revise sus métodos de pago.';
        ErrorUsuarioDiffLbl: Label 'Este pedido tiene métodos de pago y pertenece al cajero %1. El cajero primero debe borrarlos para que usted pueda registrar.';
        CajeroDiffConfirmLbl: Label 'Este pedido tiene métodos de pago y pertenece al cajero %1. Tendrá que eliminar los métodos de pago manualmente. ¿Desea continuar?';
        ErrorBorrarMP: Label 'Debe borrar los métodos de pago de este documento para evitar errores en el cuadre de caja.';
        ConfirmBorrarMP: Label 'Este pedido tiene métodos de pago y pertenece al cajero %1. Se eliminarán todos los métodos de pago. ¿Desea continuar?';
    begin
        if (SalesHeader."Document Type" <> SalesType::Invoice) and (SalesHeader."Document Type" <> SalesType::Order) then
            exit;
        if not SalesHeader.Invoice then
            exit;

        if SalesHeader.DSQuotesPS then
            exit;
        if SalesHeader.DSNPOSExt then
            exit;

        //Para verificar si alguien que no es cajero quiere registrar el pedido de un cajero

        CobrosCajeros.Reset();
        CobrosCajeros.SetRange("Tipo documento", SalesHeader."Document Type");
        CobrosCajeros.SetRange("No. Documento", SalesHeader."No.");
        if CobrosCajeros.FindFirst() then begin
            Cajeros.Reset();
            Cajeros.SetRange(Cajero, UserId);
            UserSetup.Get(UserId);
            if not (Cajeros.FindFirst()) and not (UserSetup."Supervisor Cajeros") then
                Error(ErrorUsuarioDiffLbl, CobrosCajeros.Usuario);
        end;

        //Para verificar si el supervisor quiere registar el pedido de un cajero
        CobrosCajeros.Reset();
        CobrosCajeros.SetRange("Tipo documento", SalesHeader."Document Type");
        CobrosCajeros.SetRange("No. Documento", SalesHeader."No.");
        if CobrosCajeros.FindFirst() then
            if CobrosCajeros.Usuario <> UserId then
                UserSetup.Get(UserId);
        if UserSetup."Supervisor Cajeros" then
            if confirm(StrSubstNo(ConfirmBorrarMP, CobrosCajeros.Usuario)) then begin
                CobrosCajeros2.Reset();
                CobrosCajeros2.SetRange("Tipo documento", CobrosCajeros."Tipo documento");
                CobrosCajeros2.SetRange("No. Documento", CobrosCajeros."No. Documento");
                CobrosCajeros2.FindSet();
                CobrosCajeros2.DeleteAll();
                Commit();
                exit;
            end
            else
                error('');

        //Para verificar si un cajero quiere registar el pedido de otro cajero
        CobrosCajeros.Reset();
        CobrosCajeros.SetRange("Tipo documento", SalesHeader."Document Type");
        CobrosCajeros.SetRange("No. Documento", SalesHeader."No.");
        if CobrosCajeros.FindFirst() then
            if CobrosCajeros.Usuario <> UserId then
                if Confirm(StrSubstNo(CajeroDiffConfirmLbl, CobrosCajeros.Usuario)) then
                    error(ErrorBorrarMP)
                else
                    error('');




        Cajeros.Reset();
        Cajeros.SetRange(Cajero, UserId);
        if not Cajeros.FindFirst() then
            exit;

        UserSetup.Reset();
        UserSetup.Get(UserId);
        FuncionesCobros.ValidaCajaAbierta(UserId);
        ImporteTotalPagado := 0;
        SIH2.Get(SalesInvoiceHeader."No.");
        SIH2.CalcFields("Remaining Amount", "Amount Including VAT");
        if SIH2."Amount Including VAT" = 0 then
            exit;

        //Para que no de error si insertan el default sin querer.
        CobrosCajeros.Reset();
        CobrosCajeros.SetRange("Tipo documento", SalesHeader."Document Type");
        CobrosCajeros.SetRange("No. Documento", SalesHeader."No.");
        CobrosCajeros.SetFilter("Importe($)", '<=%1', 0);
        if CobrosCajeros.FindFirst() then
            CobrosCajeros.Delete();

        FuncionesCobros.totalcobrado(SalesHeader."Document Type", SalesHeader."No.", TotalMedioPago, TotalMedioPagoLCY);

        //Dar error si hay devuelta pero no efectivo
        if SalesHeader."Currency Code" <> '' then begin
            Currency.get(SalesHeader."Currency Code");
            //if TotalMedioPagoLCY > Round(((1 / SalesHeader."Currency Factor") * FuncionesCobros.TotalDocumento(SalesHeader."Document Type", SalesHeader."No.")), Currency."Amount Rounding Precision") then begin
            if TotalMedioPagoLCY > FuncionesCobros.TotalDocumentoLCY(SalesHeader."Document Type", SalesHeader."No.") then begin
                CobrosCajeros.Reset();
                CobrosCajeros.SetRange("No. Documento", SalesHeader."No.");
                CobrosCajeros.SetRange("Tipo documento", SalesHeader."Document Type");
                CobrosCajeros.SetRange("Forma de pago DGII", CobrosCajeros."Forma de pago DGII"::Efectivo);
                CobrosCajeros.SetFilter("Importe($)", '>%1', 0);
                if not CobrosCajeros.FindFirst() then
                    Error(errorEfectivoLbl);
            end;
        end
        else
            if SalesHeader."Currency Code" = '' then begin
                if TotalMedioPagoLCY > FuncionesCobros.TotalDocumentoLCY(SalesHeader."Document Type", SalesHeader."No.") then begin
                    CobrosCajeros.Reset();
                    CobrosCajeros.SetRange("No. Documento", SalesHeader."No.");
                    CobrosCajeros.SetRange("Tipo documento", SalesHeader."Document Type");
                    CobrosCajeros.SetRange("Forma de pago DGII", CobrosCajeros."Forma de pago DGII"::Efectivo);
                    CobrosCajeros.SetFilter("Importe($)", '>%1', 0);
                    if not CobrosCajeros.FindFirst() then
                        Error(errorEfectivoLbl);
                end;
            end;

        MontoCambio := TotalMedioPagoLCY - FuncionesCobros.TotalDocumentoLCY(SalesHeader."Document Type", SalesHeader."No.");

        TestMedioPago(SalesHeader."Document Type", SalesHeader."No.");
        if MontoCambio > 0 then
            Error(Msg003Lbl);


        CLEAR(MontoFactura);

        CobrosCajeros2.Reset();
        CobrosCajeros2.SETCURRENTKEY("Tipo documento", "No. documento");
        CobrosCajeros2.SetRange("Tipo documento", 1, 2);
        CobrosCajeros2.SetFilter("No. documento", '%1|%2', salesheader."No.", SIH2."Pre-Assigned No.");
        CobrosCajeros2.FindSet();
        repeat
            CobrosCajeros2."No. Registro Factura" := SIH2."No.";
            CobrosCajeros2."Fecha registro" := SIH2."Posting Date";
            CobrosCajeros2.Modify();
        until CobrosCajeros2.Next() = 0;

        CobrosCajeros2.CALCSUMS("Importe($)");
        MontoFactura := CobrosCajeros2."Importe($)";

        HayEfectivo := false;
        if MontoCambio <> 0 then begin
            CobrosCajeros.Reset();
            CobrosCajeros.SetRange("No. Documento", CobrosCajeros2."No. Documento");
            CobrosCajeros.SetRange(NoAceptaDevuelta, true);
            if CobrosCajeros.FindFirst() then begin
                ConfMediosdepagos.Get(CobrosCajeros."Cod. Medio de pago");
                Error(ErrorNoAceptaEfectivoLbl, ConfMediosdepagos.Descripcion);
            end;
            CobrosCajeros.Reset();
            CobrosCajeros.SetRange("No. documento", CobrosCajeros2."No. documento");
            CobrosCajeros.SetRange("devuelta efectivo", true);
            if not CobrosCajeros.FindFirst() then begin
                ConfMediosdepagos.Reset();
                ConfMediosdepagos.SetRange("Devuelta efectivo", true);
                ConfMediosdepagos.FindFirst();

                CobrosCajeros2.Reset();
                CobrosCajeros2.SETCURRENTKEY("Tipo documento", "No. documento");
                CobrosCajeros2.SetRange("Tipo documento", 1, 2);
                CobrosCajeros2.SetFilter("No. documento", '%1|%2', SIH2."Order No.", SIH2."Pre-Assigned No.");
                CobrosCajeros2.FindLast();

                //CobrosCajeros.INIT;
                CobrosCajeros.VALIDATE("No. documento", CobrosCajeros2."No. documento");
                CobrosCajeros.VALIDATE("Tipo documento", CobrosCajeros2."Tipo documento");
                CobrosCajeros.VALIDATE("Fecha registro", CobrosCajeros2."Fecha registro");
                CobrosCajeros.VALIDATE("No. linea", CobrosCajeros2."No. linea" + 10000);
                CobrosCajeros.VALIDATE("Cod. medio de pago", ConfMediosdepagos."Cod. med. pago");
                CobrosCajeros.VALIDATE("Importe($)", MontoCambio);
                CobrosCajeros.VALIDATE("Cod. cliente", CobrosCajeros2."Cod. cliente");
                CobrosCajeros.VALIDATE("Codigo Pos", CobrosCajeros2."Codigo POS");
                CobrosCajeros.VALIDATE(usuario, CobrosCajeros2.Usuario);
                CobrosCajeros.VALIDATE("No. Batch", CobrosCajeros2."No. Batch");
                CobrosCajeros."Dimension Set ID" := SalesHeader."Dimension Set ID";
                CobrosCajeros."No. Registro Factura" := SIH2."No.";
                CobrosCajeros."Cod. Divisa" := CobrosCajeros2."Cod. Divisa";
                CobrosCajeros.Insert();
            end;

            CobrosCajeros.Reset();
            CobrosCajeros.SETCURRENTKEY("No. Registro Factura");
            CobrosCajeros.SetRange("No. Registro Factura", SIH2."No.");
            //MediosdePago.SETFILTER("Forma de pago DGII", '<>%1', DSNFormaDePagoDGII::Efectivo);
            if (CobrosCajeros.FindSet()) and (SIH2."Applies-to Doc. No." = '') then
                repeat
                    ConfMediosdepagos.Get(CobrosCajeros."Cod. Medio de pago");
                    ConfMediosdepagos.TestField("Account No.");
                    if not ConfMediosdepagos.Credito then begin
                        NoLin += 1000;
                        SalesInvoiceLine.Reset();
                        SalesInvoiceLine.SetRange("Document No.", SIH2."No.");
                        SalesInvoiceLine.CALCSUMS("Amount Including VAT");
                        GenJnlLine.Init();
                        GenJnlLine."Line No." := NoLin;
                        GenJnlLine."Document No." := SIH2."No.";
                        GenJnlLine."Posting Date" := SIH2."Posting Date";
                        GenJnlLine.VALIDATE("Account Type", ConfMediosdepagos."Account Type");
                        GenJnlLine.VALIDATE("Account No.", ConfMediosdepagos."Account No.");
                        GenJnlLine.Description := COPYSTR(StrSubStNo(Msg004Lbl, SIH2."No." + ', ' + ConfMediosdepagos."Cod. Forma Pago"), 1, MAXSTRLEN(GenJnlLine.Description));
                        GenJnlLine."System-Created Entry" := true;

                        if (CobrosCajeros."Forma de pago DGII" = CobrosCajeros."Forma de pago DGII"::Efectivo) and (MontoCambio > 0) then begin
                            MontoCambio := MontoCambio - CobrosCajeros."Importe($)";
                            //CobrosCajeros."Importe($)" := 0;
                            HayEfectivo := true;
                        end;

                        GenJnlLine.VALIDATE("Debit Amount", round(CobrosCajeros."Importe($)", 0.01));
                        ImporteTotalPagado += GenJnlLine."Debit Amount";
                        GenJnlLine."Payment Method Code" := ConfMediosdepagos."Cod. Forma Pago";
                        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
                        GenJnlLine."Applies-to Doc. No." := SIH2."No.";
                        GenJnlLine."Dimension Set ID" := SIH2."Dimension Set ID";
                        GenJnlLine."Salespers./Purch. Code" := SIH2."Salesperson Code";
                        GenJnlLine."Shortcut Dimension 1 Code" := SIH2."Shortcut Dimension 1 Code";
                        GenJnlLine."Shortcut Dimension 2 Code" := SIH2."Shortcut Dimension 2 Code";
                        GenJnlLine."Code POS" := CobrosCajeros."Codigo POS";
                        GenJnlPostLine.RunWithCheck(GenJnlLine);

                    end


                until CobrosCajeros.Next() = 0;
            if HayEfectivo = false and (MontoCambio <> 0) then
                Error('El importe no puede ser menor que el total pagado a menos que se pague con efectivo.');

            // Insertado para realizar un solo asiento al auxiliar de clientes
            if ImporteTotalPagado <> 0 then begin
                GenJnlLine.Init();
                GenJnlLine."Line No." := NoLin;
                GenJnlLine."Document No." := SIH2."No.";
                GenJnlLine."Posting Date" := SIH2."Posting Date";
                GenJnlLine.VALIDATE("Account Type", GenJnlLine."Account Type"::Customer);
                GenJnlLine.VALIDATE("Account No.", SIH2."Sell-to Customer No.");
                GenJnlLine.Description := StrSubStNo(Msg005Lbl, SIH2."No.");
                GenJnlLine."System-Created Entry" := true;

                GenJnlLine.VALIDATE("Credit Amount", ROUND(ImporteTotalPagado, 0.01)); // usar importe de lo que se coloco en caj
                GenJnlLine."Payment Method Code" := ConfMediosdepagos."Cod. Forma Pago"; // usar importe de lo que se coloco en caja
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
                GenJnlLine."Applies-to Doc. No." := SIH2."No.";
                GenJnlLine."Dimension Set ID" := SIH2."Dimension Set ID";
                GenJnlLine."Salespers./Purch. Code" := SIH2."Salesperson Code";
                GenJnlLine."Shortcut Dimension 1 Code" := SIH2."Shortcut Dimension 1 Code";
                GenJnlLine."Shortcut Dimension 2 Code" := SIH2."Shortcut Dimension 2 Code";
                GenJnlLine."Code POS" := CobrosCajeros."Codigo POS";
                GenJnlPostLine.RunWithCheck(GenJnlLine);
            end;
        end else begin
            SIH2.Reset();
            CobrosCajeros2.Reset();
            CobrosCajeros2.SETCURRENTKEY("Tipo documento", "No. documento");
            CobrosCajeros2.SetRange("Tipo documento", 1, 2);
            CobrosCajeros2.SetFilter("No. documento", '%1|%2', SIH2."Order No.", SIH2."Pre-Assigned No.");

            if CobrosCajeros2.FindSet() then
                repeat
                    CobrosCajeros2."No. Registro Factura" := SIH2."No.";
                    CobrosCajeros2."Dimension Set ID" := SIH2."Dimension Set ID";
                    CobrosCajeros2.Modify();
                until CobrosCajeros2.Next() = 0;

            CobrosCajeros.Reset();
            CobrosCajeros.SETCURRENTKEY("Tipo documento", "No. documento");
            CobrosCajeros.SetRange("Tipo documento", 1, 2);
            CobrosCajeros.SetFilter("No. documento", '%1|%2', SIH2."Order No.", SIH2."Pre-Assigned No.");
            CobrosCajeros.SetRange("No. Registro Factura", SIH2."No.");

            if CobrosCajeros.FindSet() then begin
                repeat
                    NoLin += 1000;
                    ConfMediosdepagos.Get(CobrosCajeros."Cod. medio de pago");
                    if not ConfMediosdepagos.Credito then begin
                        ConfMediosdepagos.TestField("Account Type");
                        ConfMediosdepagos.TestField("Account No.");
                        ConfMediosdepagos.TestField("ID Agrupacion");
                        GenJnlLine.Init();
                        GenJnlLine."Line No." := NoLin;
                        GenJnlLine."Document No." := SIH2."No.";
                        GenJnlLine."Posting Date" := SIH2."Posting Date";
                        GenJnlLine.VALIDATE("Account Type", ConfMediosdepagos."Account Type");
                        GenJnlLine.VALIDATE("Account No.", ConfMediosdepagos."Account No.");
                        GenJnlLine.Description := COPYSTR(StrSubStNo(Msg004Lbl, SIH2."No." + ', ' + ConfMediosdepagos."Cod. Forma Pago"), 1, MAXSTRLEN(GenJnlLine.Description));

                        GenJnlLine."Payment Method Code" := ConfMediosdepagos."Cod. Forma Pago"; // usar importe de lo que se coloco en caja
                        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                        GenJnlLine.VALIDATE("Dimension Set ID", SIH2."Dimension Set ID");
                        GenJnlLine.VALIDATE("Salespers./Purch. Code", SIH2."Salesperson Code");
                        GenJnlLine.Validate("Shortcut Dimension 1 Code", SIH2."Shortcut Dimension 1 Code");
                        GenJnlLine.Validate("Shortcut Dimension 2 Code", SIH2."Shortcut Dimension 2 Code");

                        GenJnlLine."Code POS" := CobrosCajeros."Codigo POS";

                        if ConfMediosdepagos."No acepta devuelta" = false then begin
                            GenJnlLine.VALIDATE(Amount, ROUND(CobrosCajeros."Importe($)", 0.01));
                            ImporteTotalPagado += CobrosCajeros."Importe($)";
                        end
                        else begin
                            GenJnlLine.VALIDATE(Amount, ROUND(CobrosCajeros.Importe, 0.01));
                            ImporteTotalPagado += CobrosCajeros.Importe;
                        end;

                        GenJnlPostLine.RunWithCheck(GenJnlLine);

                    end;

                until CobrosCajeros.Next() = 0;

                // Para insertar una sola linea en el asiento del cliente
                if ImporteTotalPagado <> 0 then begin
                    GenJnlLine.Init();
                    GenJnlLine."Line No." := NoLin;
                    GenJnlLine."Document No." := SIH2."No.";
                    GenJnlLine."Posting Date" := SIH2."Posting Date";
                    GenJnlLine.VALIDATE("Account Type", GenJnlLine."Account Type"::Customer);
                    GenJnlLine.VALIDATE("Account No.", SIH2."Sell-to Customer No.");
                    GenJnlLine.Description := COPYSTR(StrSubStNo(Msg004Lbl, SIH2."No." + ', ' + ConfMediosdepagos."Cod. Forma Pago"), 1, MAXSTRLEN(GenJnlLine.Description));
                    GenJnlLine."System-Created Entry" := true;
                    GenJnlLine.VALIDATE("Credit Amount", ROUND(ImporteTotalPagado, 0.01)); //usar importe de lo que se coloco en caja
                    GenJnlLine."Payment Method Code" := ConfMediosdepagos."Cod. Forma Pago"; //usar importe de lo que se coloco en caja
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                    GenJnlLine.VALIDATE("Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::Invoice);
                    GenJnlLine.VALIDATE("Applies-to Doc. No.", SIH2."No.");
                    GenJnlLine.VALIDATE("Dimension Set ID", SIH2."Dimension Set ID");
                    GenJnlLine.VALIDATE("Salespers./Purch. Code", SIH2."Salesperson Code");
                    GenJnlLine.Validate("Shortcut Dimension 1 Code", SIH2."Shortcut Dimension 1 Code");
                    GenJnlLine.Validate("Shortcut Dimension 2 Code", SIH2."Shortcut Dimension 2 Code");
                    GenJnlLine."Code POS" := CobrosCajeros."Codigo POS";
                    GenJnlPostLine.RunWithCheck(GenJnlLine);
                end
            end;
        end;
    end;

    procedure TestMedioPago(TipoDoc: Enum "Sales Document Type"; var NoDoc: Code[20])
    var
        ErrorNoInfLbl: Label 'El método de pago "%1" no requiere número de información.';
        ErrorReqNoInfLbl: Label 'El método de pago "%1" requiere número de información.';
    begin
        DSNCobrosCajeros.Reset();
        DSNCobrosCajeros.SetRange("Tipo documento", TipoDoc);
        DSNCobrosCajeros.SetRange("No. Documento", NoDoc);
        if DSNCobrosCajeros.FindSet() then
            repeat
                DSNConfMediosDePagos.Get(DSNCobroscajeros."Cod. Medio de pago");
                if (DSNConfMediosDePagos."Req. Información" = true) and (DSNCobroscajeros."No. Información" = '') then
                    error(ErrorReqNoInfLbl, DSNConfMediosDePagos.Descripcion);
                if (DSNConfMediosDePagos."Req. Información" = false) and (DSNCobroscajeros."No. Información" <> '') then
                    Error(ErrorNoInfLbl, DSNConfMediosDePagos.Descripcion);
            until DSNCobroscajeros.Next() = 0;
    end;
}
