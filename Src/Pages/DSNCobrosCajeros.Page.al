page 51104 "DSNCobros Cajeros"
{
    Caption = 'Cobros Cajeros';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Cobros Cajeros";
    Permissions =
        tabledata Cajeros = R,
        tabledata "Cobros Cajeros" = RIMD,
        tabledata "Conf. Medios de Pagos" = R,
        tabledata "Sales Header" = R;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Cod. Medio de pago"; Rec."Cod. Medio de pago")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cod. Medio de pago field.';
                    Caption = 'Cod. Medio de pago';
                }
                field("Cod. Divisa"; Rec."Cod. Divisa")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Cod. Divisa field.';
                    Caption = 'Cod. Divisa';
                }

                field("No. Información"; Rec."No. Información")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the No. Información field.';
                    Caption = 'No. Autorización / CK';

                }
                field(Importe; Rec.Importe)
                {
                    ApplicationArea = all;
                    Style = Strong;
                    ToolTip = 'Specifies the value of the Importe field.';
                    Caption = 'Importe';
                    trigger OnValidate()
                    begin
                        rec.TestField("Cod. Medio de pago");

                    end;
                }
                field("Importe($)"; Rec."Importe($)")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Importe($) field.';
                    Caption = 'Importe($)';

                }
            }
            group(Calculos)
            {
                ShowCaption = false;
                field(TotalMedioPago; TotalMedioPago)
                {
                    Caption = 'Total medio pago';
                    ApplicationArea = all;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total medio pago field.';
                }
                field(ImportePendiente; Pendiente)
                {
                    Caption = 'Importe pendiente';
                    ApplicationArea = all;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Importe pendiente field.';
                }
                field(MontoCambio; MontoCambio)
                {
                    Caption = 'Monto cambio';
                    ApplicationArea = all;
                    Editable = false;
                    Style = Strong;
                    ToolTip = 'Specifies the value of the Monto cambio field.';
                }
                field(TotalDocumento; TotalDocumento)
                {
                    Caption = 'Total documento';
                    ApplicationArea = all;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total documento field.';
                }
                field(TotalDocumentoLCY; TotalDocumentoLCY)
                {
                    Caption = 'Total documento($)';
                    ApplicationArea = all;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total documento($) field.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        UsarioEsCajero();
        rec.Reset();
        rec.SetRange("Tipo documento", TipoDoc2);
        rec.SetRange("No. Documento", NoDoc2);
        TotalDocumento := DSNFuncionesCobros.TotalDocumento(TipoDoc2, NoDoc2);
        TotalDocumentoLCY := DSNFuncionesCobros.TotalDocumentoLCY(TipoDoc2, NoDoc2);
        GetDefault();
        CalcImportePendiente();
        CalcMontoCambio();
    end;

    trigger OnClosePage()
    begin
        TestMedioPago();
        GetPaymentMethodCode();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CalcImportePendiente();
        CalcMontoCambio();

    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcImportePendiente();
        CalcMontoCambio();
    end;

    var
        DSNCobrosCajeros: Record "Cobros Cajeros";
        DSNConfMediosDePagos: Record "Conf. Medios de Pagos";
        DSNFuncionesCobros: Codeunit "DSNFunciones Cobros";
        NoDoc2: Code[20];

        TipoDoc2: Enum "Sales Document Type";
        TotalMedioPago: Decimal;
        TotalMedioPagoLCY: Decimal;
        Pendiente: Decimal;

        MontoCambio: Decimal;
        TotalDocumento: Decimal;
        TotalDocumentoLCY: Decimal;

    local procedure UsarioEsCajero()
    var
        DSNCajeros: Record Cajeros;
        ErrorNoEsCajeroLbl: Label 'Esta función solo está disponible para cajeros.';
    begin
        DSNCajeros.Reset();
        DSNCajeros.SetRange(Cajero, UserId);
        if not DSNCajeros.FindFirst() then
            Error(ErrorNoEsCajeroLbl);
    end;

    [Scope('Cloud')]
    procedure CalcImportePendiente()
    begin
        Pendiente := 0;

        TotalMedioPagoLCY := 0;
        DSNFuncionesCobros.TotalCobrado(TipoDoc2, NoDoc2, TotalMedioPago, TotalMedioPagoLCY);
        //TODO: Como actualizar una variable sin tener que moverme de linea:
        //TotalMedioPagoLCY += rec."Importe($)" -xRec."Importe($)";
        if TotalDocumentoLCY > TotalMedioPagoLCY then
            Pendiente := TotalDocumentoLCY - TotalMedioPagoLCY;

        CurrPage.Update(false);
    end;

    procedure CalcMontoCambio()
    begin
        MontoCambio := 0;
        MontoCambio := TotalMedioPagoLCY - DSNFuncionesCobros.TotalDocumentoLCY(TipoDoc2, NoDoc2)
    end;

    [Scope('Cloud')]
    procedure TestMedioPago()
    var
        ErrorNoInfLbl: Label 'El método de pago "%1" no requiere número de información.';
        ErrorReqNoInfLbl: Label 'El método de pago "%1" requiere número de información.';
    begin
        DSNCobrosCajeros.Reset();
        DSNCobrosCajeros.SetRange("Tipo documento", TipoDoc2);
        DSNCobrosCajeros.SetRange("No. Documento", NoDoc2);
        if DSNCobrosCajeros.FindSet() then
            repeat
                DSNConfMediosDePagos.Get(DSNCobroscajeros."Cod. Medio de pago");
                if (DSNConfMediosDePagos."Req. Información" = true) and (DSNCobroscajeros."No. Información" = '') then
                    error(ErrorReqNoInfLbl, DSNConfMediosDePagos.Descripcion);
                if (DSNConfMediosDePagos."Req. Información" = false) and (DSNCobroscajeros."No. Información" <> '') then
                    Error(ErrorNoInfLbl, DSNConfMediosDePagos.Descripcion);
            until DSNCobroscajeros.Next() = 0;
    end;

    procedure GetDefault()
    begin
        DSNConfMediosDePagos.Reset();
        DSNConfMediosDePagos.SetRange(Default, true);
        if DSNConfMediosDePagos.FindFirst() then begin
            DSNCobrosCajeros.Reset();
            DSNCobrosCajeros.SetRange("Tipo documento", TipoDoc2);
            DSNCobrosCajeros.SetRange("No. Documento", NoDoc2);
            if DSNCobrosCajeros.FindFirst() then
                exit
            else begin
                DSNCobrosCajeros.Init();
                DSNCobrosCajeros."Tipo documento" := TipoDoc2;
                DSNCobrosCajeros."No. Documento" := NoDoc2;
                DSNCobrosCajeros."Cod. Medio de pago" := DSNConfMediosDePagos."Cod. med. pago";
                DSNCobrosCajeros."ID Agrupacion" := DSNConfMediosDePagos."ID Agrupacion";
                DSNCobrosCajeros."Forma de pago DGII" := DSNConfMediosDePagos."Forma de pago DGII";
                if DSNCobrosCajeros.Insert() then
                    CurrPage.Update()
            end
        end;
    end;

    procedure GetPaymentMethodCode()
    var
        SalesHeader: Record "Sales Header";
        PaymentMethod: record "Payment Method";
    begin
        SalesHeader.Get(TipoDoc2, NoDoc2);
        DSNCobrosCajeros.Reset();
        DSNCobrosCajeros.SetRange("No. Documento", SalesHeader."No.");
        DSNCobrosCajeros.SetRange("Tipo documento", SalesHeader."Document Type");
        if DSNCobrosCajeros.FindFirst() then
            DSNConfMediosDePagos.Get(DSNCobrosCajeros."Cod. Medio de pago");
        SalesHeader."Payment Method Code" := DSNConfMediosDePagos."Cod. Forma Pago";

        if DSNCobrosCajeros.Count() > 1 then begin
            paymentMethod.Reset();
            paymentMethod.SetRange("DSNForma de pago DGII", paymentMethod."DSNForma de pago DGII"::Mixto);
            paymentMethod.FindFirst();
            SalesHeader."Payment Method Code" := paymentMethod.Code;
        end;
        SalesHeader.Modify();
    end;


    [Scope('Cloud')]
    procedure GetInvoiceKeys(TipoDoc: Enum "Sales Document Type"; var NoDoc: Code[20])
    begin
        TipoDoc2 := TipoDoc;
        NoDoc2 := NoDoc;
    end;


}