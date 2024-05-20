
table 51104 "Conf. Medios de Pagos"
{
    DataClassification = CustomerContent;
    LookupPageId = DSNConfMediosDePagos;
    Caption = 'Conf. Medios de Pagos';
    fields
    {
        field(1; "Cod. med. pago"; Code[10])
        {
            Caption = 'Cod. med. pago';
            DataClassification = CustomerContent;
        }
        field(2; Credito; Boolean)
        {
            Caption = 'Crédito';
            DataClassification = CustomerContent;
        }
        field(3; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Tipo de cuenta';
            DataClassification = CustomerContent;
        }
        field(4; "Account No."; Code[20])
        {
            Caption = 'No. Cuenta';
            DataClassification = CustomerContent;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account" Where("Account Type" = const(Posting),
                                                                                          Blocked = const(false))
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("G/L Account")) "G/L Account";
        }
        field(5; Descripcion; Text[60])
        {
            Caption = 'Descripcion';
            DataClassification = CustomerContent;
        }
        field(6; "Cod. Forma Pago"; Code[20])
        {
            Caption = 'Cod. Forma Pago';
            DataClassification = CustomerContent;
            TableRelation = "Payment method";
            trigger OnValidate()
            var
                PaymentMethod: Record "Payment Method";
            begin
                PaymentMethod.Reset();
                PaymentMethod.SetRange(Code, "Cod. Forma Pago");
                if PaymentMethod.FindFirst() then begin
                    Rec.Descripcion := PaymentMethod.Description;
                    Rec."Forma de pago DGII" := PaymentMethod."DSNForma de pago DGII";
                end;
            end;
        }
        field(7; "ID Agrupacion"; Integer)
        {
            Caption = 'ID Agrupacion';
            DataClassification = CustomerContent;
        }
        field(8; "Forma de pago DGII"; Enum DSNFormaDePagoDGII)
        {
            Caption = 'Forma de pago DGII';
            DataClassification = CustomerContent;

        }
        field(9; "Usar para facturacion"; Boolean)
        {
            Caption = 'Usar para facturacion';
            DataClassification = CustomerContent;
        }
        field(10; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
        }
        field(11; "Req. No. Autorizacion"; Boolean)
        {
            Caption = 'Req. No. Autorizacion';
            DataClassification = CustomerContent;
        }
        field(12; "Req. No. Cheque"; Boolean)
        {
            Caption = 'Req. No. Cheque';
            DataClassification = CustomerContent;
        }
        field(13; "Devuelta efectivo"; Boolean)
        {
            Caption = 'Devuelta efectivo';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ConfMedioPagos: Record "Conf. Medios de Pagos";
                errorDevueltaLbl: Label 'No puede tener mas de un metodo de pago para devuelta de efectivo.';
            begin
                if rec."Devuelta efectivo" = true then begin
                    ConfMedioPagos.Reset();
                    ConfMedioPagos.SetFilter("Cod. med. pago", '<>%1', rec."Cod. med. pago");
                    ConfMedioPagos.SetRange("Devuelta efectivo", true);
                    if ConfMedioPagos.FindFirst() then
                        Error(errorDevueltaLbl);
                end;
            end;
        }
        field(14; "No acepta devuelta"; Boolean)
        {
            Caption = 'No acepta devuelta';
            DataClassification = CustomerContent;
        }
        field(15; "Req. Información"; Boolean)
        {
            Caption = 'Req. Información';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Cod. med. pago")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Cod. med. Pago", Descripcion, "Account Type", "Account No.", "Cod. Forma Pago")
        { }
        fieldgroup(Brick; "Cod. med. Pago", Descripcion, "Account Type", "Account No.", "Cod. Forma Pago")
        { }
    }
    var
        CobrosCajeros: record "Cobros Cajeros";
        ErrorDeleteLbl: Label 'Debe registrar o borrar el documento %1 antes de borrar este medio de pago.';
        ErrorModify: Label 'Si cambia la configuracion de este medio de pago, puede crear incosistencias y/o errores. ¿Desea continuar?';

    trigger OnDelete()
    begin
        CobrosCajeros.Reset();
        CobrosCajeros.SetRange("Cod. Medio de pago", rec."Cod. med. pago");
        CobrosCajeros.SetRange(Status, CobrosCajeros.Status::Abierto);
        if CobrosCajeros.FindFirst() then
            Error(ErrorDeleteLbl, CobrosCajeros."No. Documento");
    end;

    trigger OnModify()
    begin
        CobrosCajeros.Reset();
        CobrosCajeros.SetRange("Cod. Medio de pago", rec."Cod. med. pago");
        CobrosCajeros.SetRange(Status, CobrosCajeros.Status::Abierto);
        if CobrosCajeros.FindFirst() then
            if not Confirm(ErrorModify, false) then
                Error('');
    end;
}