table 51105 "Cobros Cajeros"
{
    DataClassification = CustomerContent;
    Permissions =
        tabledata "Cobros Cajeros" = R,
        tabledata "Conf. Medios de Pagos" = R,
        tabledata ControlCajeros = R,
        tabledata Currency = R,
        tabledata "Currency Exchange Rate" = R;
    Caption = 'Cobros Cajeros';
    fields
    {
        field(1; "Tipo documento"; Enum "Sales Document Type")
        {
            Caption = 'Tipo documento';
            DataClassification = CustomerContent;
        }
        field(2; "No. Documento"; Code[20])
        {
            Caption = 'No. Documento';
            DataClassification = CustomerContent;
        }
        field(3; "No. linea"; Integer)
        {
            Caption = 'No. linea';
            DataClassification = CustomerContent;
        }
        field(4; "Cod. Medio de pago"; Code[10])
        {
            Caption = 'Cod. Medio de pago';
            DataClassification = CustomerContent;
            TableRelation = "Conf. Medios de Pagos";

            trigger OnValidate()
            var
                ConfMP: Record "Conf. Medios de Pagos";
            begin
                if rec."Cod. Medio de pago" <> '' then begin
                    ConfMP.Get(rec."Cod. Medio de pago");
                    rec."Devuelta efectivo" := ConfMP."Devuelta efectivo";
                    rec."ID Agrupacion" := ConfMP."ID Agrupacion";
                    rec."Forma de pago DGII" := ConfMP."Forma de pago DGII";
                    rec.NoAceptaDevuelta := ConfMP."No acepta devuelta";
                end;
            end;
        }
        field(5; "Cod. Cliente"; Code[10])
        {
            Caption = 'Cod. Cliente';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(6; "Fecha registro"; Date)
        {
            Caption = 'Fecha registro';
            DataClassification = CustomerContent;
        }
        field(7; Importe; Decimal)
        {
            Caption = 'Importe';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                controlCajeros: Record ControlCajeros;
                CobrosCajerosPage: Page "DSNCobros Cajeros";
            begin
                ValidateAmount();
                CobrosCajerosPage.CalcImportePendiente();
                rec.Usuario := CopyStr(UserId, 1, MaxStrLen(rec.Usuario));
                controlCajeros.Reset();
                controlCajeros.SetRange(Usuario, rec.Usuario);
                controlCajeros.SetRange(EstadoRegistro, controlCajeros.EstadoRegistro::Abierto);
                controlCajeros.FindFirst();
                rec."Codigo POS" := controlCajeros.CodigoCaja;
                rec."Codigo Turno" := controlCajeros.CodigoTurno;
            end;
        }
        field(8; "Cod. Divisa"; Code[5])
        {
            Caption = 'Cod. Divisa';
            DataClassification = CustomerContent;
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if ("Cod. Divisa" <> '') then
                    "Factor divisa" := CurrencyExchangeRateRecord.ExchangeRate(WorkDate(), "Cod. Divisa")
                else
                    "Factor divisa" := 0;
                Validate("Factor divisa");
            end;
        }
        field(9; "Tasa de cambio"; Decimal)
        {
            Caption = 'Tasa de cambio';
            DataClassification = CustomerContent;
        }
        field(10; Transferido; Boolean)
        {
            Caption = 'Transferido';
            DataClassification = CustomerContent;
        }
        field(11; "No. Registro Factura"; Code[20])
        {
            Caption = 'No. Registro Factura';
            DataClassification = CustomerContent;
        }
        field(12; "No. Autorizacion"; Integer)
        {
            Caption = 'No. Autorización';
            DataClassification = CustomerContent;

        }
        field(13; "No. Cheque"; Integer)
        {
            Caption = 'No. Cheque';
            DataClassification = CustomerContent;

        }
        field(14; Banco; Code[15])
        {
            Caption = 'Banco';
            DataClassification = CustomerContent;
        }
        field(15; "Importe($)"; Decimal)
        {
            Caption = 'Importe($)';
            Editable = false;
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                if IsHandled then
                    exit;

                if "Cod. Divisa" = '' then begin
                    Importe := "Importe($)";
                    Validate(Importe);
                end else
                    if CheckFixedCurrency() then begin
                        GetCurrency();
                        Importe := Round(
                            CurrencyExchangeRateRecord.ExchangeAmtLCYToFCY(
                              "Fecha registro", "Cod. Divisa",
                              "Importe($)", "Factor divisa"),
                            Currency."Amount Rounding Precision")
                    end else begin
                        TestField("Importe($)");
                        TestField(Importe);
                        "Factor divisa" := Importe / "Importe($)";
                    end;
            end;

        }
        field(16; Usuario; Code[50])
        {
            Caption = 'Usuario';
            DataClassification = CustomerContent;
        }

        field(17; "Codigo POS"; Code[10])
        {
            Caption = 'Codigo POS';
            DataClassification = CustomerContent;
            TableRelation = PuntosDeVenta;
        }
        field(18; "No. Batch"; Integer)
        {
            Caption = 'No. Batch';
            DataClassification = CustomerContent;
        }
        field(19; "Factor divisa"; Decimal)
        {
            Caption = 'Factor divisa';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if ("Cod. Divisa" = '') and ("Factor divisa" <> 0) then
                    FieldError("Factor divisa", StrSubStNo(Text002Lbl, FieldCaption("Cod. Divisa")));
                Validate(Importe);
            end;
        }
        field(20; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Cod. dim. acceso dir. 1';
            DataClassification = CustomerContent;
        }
        field(21; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Cod. dim. acceso dir. 2';
            DataClassification = CustomerContent;
        }
        field(22; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
        }

        field(25; "ID Agrupacion"; Integer)
        {
            Caption = 'ID Agrupacion';
            DataClassification = CustomerContent;
        }
        field(26; "Devuelta efectivo"; Boolean)
        {
            Caption = 'Devuelta efectivo';
            DataClassification = CustomerContent;
        }
        field(27; "Forma de pago DGII"; Enum DSNFormaDePagoDGII)
        {
            Caption = 'Forma de pago DGII';
            DataClassification = CustomerContent;
        }
        field(28; Status; Option)
        {
            Caption = 'Estado';
            OptionMembers = Abierto,Cerrado;
            DataClassification = CustomerContent;
        }
        field(29; "Codigo Turno"; Code[7])
        {
            Caption = 'Codigo Turno';
            DataClassification = CustomerContent;
        }
        field(30; NoAceptaDevuelta; Boolean)
        {
            Caption = 'No acepta Devuelta';
            DataClassification = CustomerContent;
        }
        field(31; "No. Información"; code[25])
        {
            Caption = 'No. Información / CK';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                DSNCobrosCajeros: Record "Cobros Cajeros";
                NoInfErr: Label 'Este número de información ya existe.';
            begin
                DSNCobrosCajeros.Reset();
                DSNCobrosCajeros.SetRange("No. Información", rec."No. Información");
                if DSNCobrosCajeros.FindFirst() and ("No. Información" <> '') then
                    Error(NoInfErr);
            end;
        }
    }


    keys
    {
        key(PK; "Tipo documento", "No. Documento", "Cod. Medio de pago")
        {
            Clustered = true;
        }
        key(Cobros; "No. Batch", Usuario, "Codigo POS", "Codigo Turno")
        { }
    }
    var
        CurrencyExchangeRateRecord: Record "Currency Exchange Rate";
        Currency: Record Currency;
        Text002Lbl: Label 'Cannot be specified without %1', Comment = '%1 = Cod Divisa';


    trigger OnModify()
    begin
        ValidaUsuarioDocumento();
    end;

    trigger OnInsert()
    begin
        ValidaUsuarioDocumento();
    end;

    trigger OnRename()
    begin
        ValidaUsuarioDocumento();
    end;

    procedure CheckFixedCurrency(): Boolean
    begin
        CurrencyExchangeRateRecord.SetRange("Currency Code", "Cod. Divisa");
        CurrencyExchangeRateRecord.SetRange("Starting Date", 0D, "Fecha registro");

        if not CurrencyExchangeRateRecord.FindLast() then
            exit(false);

        if CurrencyExchangeRateRecord."Relational Currency Code" = '' then
            exit(
              CurrencyExchangeRateRecord."Fix Exchange Rate Amount" =
              CurrencyExchangeRateRecord."Fix Exchange Rate Amount"::Both);

        if CurrencyExchangeRateRecord."Fix Exchange Rate Amount" <>
           CurrencyExchangeRateRecord."Fix Exchange Rate Amount"::Both
        then
            exit(false);

        CurrencyExchangeRateRecord.SetRange("Currency Code", CurrencyExchangeRateRecord."Relational Currency Code");
        if CurrencyExchangeRateRecord.FindLast() then
            exit(
              CurrencyExchangeRateRecord."Fix Exchange Rate Amount" =
              CurrencyExchangeRateRecord."Fix Exchange Rate Amount"::Both);

        exit(false);
    end;

    procedure GetCurrency()
    begin
        if "Cod. Divisa" = '' then begin
            Clear(Currency);
            Currency.InitRoundingPrecision()
        end else
            if "Cod. Divisa" <> Currency.Code then begin
                Currency.Get("Cod. Divisa");
                Currency.TestField("Amount Rounding Precision");
            end;
    end;

    procedure ValidateAmount()
    begin
        GetCurrency();
        if "Cod. Divisa" = '' then
            "Importe($)" := Importe
        else
            "Importe($)" := Round(
                CurrencyExchangeRateRecord.ExchangeAmtFCYToLCY("Fecha registro", "Cod. Divisa", Importe, "Factor divisa"));
        OnValidateAmountOnAfterAssignAmountLCY("Importe($)");

        Importe := Round(Importe, Currency."Amount Rounding Precision");
    end;

    local procedure OnValidateAmountOnAfterAssignAmountLCY(var AmountLCY: Decimal)
    begin
    end;

    procedure ValidaUsuarioDocumento()
    var
        ErrorUsuarioDocLbl: label 'No puede modificar este documento ya que pertenece a %1.';
        DSNCobrosCajeros: record "Cobros Cajeros";
        UserSetup: record "User Setup";
        DSNCobrosCajeros2: record "Cobros Cajeros";
    begin
        DSNCobrosCajeros.reset;
        DSNCobrosCajeros.SetRange("Tipo documento", rec."Tipo documento");
        DSNCobrosCajeros.SetRange("No. Documento", rec."No. Documento");
        DSNCobrosCajeros.SetFilter(Usuario, '<>%1', UserId);
        if DSNCobrosCajeros.FindFirst() then
            if (DSNCobrosCajeros.Usuario <> '') and (DSNCobrosCajeros.Usuario <> UserId) then
                Error(ErrorUsuarioDocLbl, DSNCobrosCajeros.Usuario);
    end;
}