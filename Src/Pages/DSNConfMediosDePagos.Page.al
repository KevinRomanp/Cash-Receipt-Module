page 51105 DSNConfMediosDePagos
{
    Caption = 'Conf. Medios de pagos';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Conf. Medios de Pagos";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Cod. med. pago"; Rec."Cod. med. pago")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cod. med. pago field.';
                    Caption = 'Cod. med. pago';
                }
                field("Tipo Cuenta"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tipo de cuenta field.';
                    Caption = 'Tipo de cuenta';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Cuenta field.';
                    Caption = 'No. Cuenta';
                }
                field("Cod. Forma Pago"; Rec."Cod. Forma Pago")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cod. Forma Pago field.';
                    Caption = 'Cod. Forma Pago';
                }
                field(Descripcion; Rec.Descripcion)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Descripcion field.';
                    Caption = 'Descripcion';
                }

                field("ID Agrupacion"; Rec."ID Agrupacion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID Agrupacion field.';
                    Caption = 'ID Agrupacion';
                }
                field("Forma de pago DGII"; Rec."Forma de pago DGII")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Forma de pago DGII field.';
                    Caption = 'Forma de pago DGII';
                }
                field("Usar para facturacion"; Rec."Usar para facturacion")
                {
                    //ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Usar para facturacion field.';
                    Caption = 'Usar para facturacion';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default field.';
                    Caption = 'Default';
                }
                field(Credito; Rec.Credito)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Crédito field.';
                    Caption = 'Crédito';
                }

                field("Req. Información"; rec."Req. Información")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Req. Información field.';
                    Caption = 'Req. No. Autorización / CK';
                }
                field("Devuelta efectivo"; Rec."Devuelta efectivo")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Devuelta efectivo field.';
                    Caption = 'Devuelta efectivo';
                }
                field("Acepta devuelta"; Rec."No acepta devuelta")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the No acepta devuelta field.';
                    Caption = 'No acepta devuelta';
                }
            }

        }
        area(Factboxes)
        {

        }
    }
}