page 51103 DSNControlCajeros
{
    Caption = 'Control de cajeros';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = ControlCajeros;
    Permissions =
        tabledata "Cobros Cajeros" = RM,
        tabledata ControlCajeros = RIMD,
        tabledata "Sales Invoice Header" = RM,
        tabledata Turnos = R;
    SourceTableView = sorting(EstadoRegistro)
                    order(ascending);
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field(Usuario; Rec.Usuario)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = CampoEditable;
                    ToolTip = 'Specifies the value of the Usuario field.';
                    Caption = 'Usuario';
                }
                field(CodigoCaja; Rec.CodigoCaja)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = CampoEditable;
                    ToolTip = 'Specifies the value of the Código caja field.';
                    Caption = 'Código caja';
                }
                field(CodigoTurno; Rec.CodigoTurno)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = CampoEditable;
                    ToolTip = 'Specifies the value of the Código turno field.';
                    Caption = 'Código turno';
                }
                field(FechaInicio; Rec.FechaInicio)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fecha de inicio field.';
                    Caption = 'Fecha de inicio';
                }
                field(FechaFin; Rec.FechaFin)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Fecha de cerrado field.';
                    Caption = 'Fecha de cerrado';
                }
                field(ImporteCobrado; Rec.ImporteCobrado)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Saldo cierre field.';
                    Caption = 'Saldo cierre';
                }
                field(SaldoPendienteCierre; Rec.SaldoPendienteCierre)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Saldo pte. Cierre field.';
                    Caption = 'Saldo pte. Cierre';
                }

                field(EstadoRegistro; Rec.EstadoRegistro)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleTxt;
                    ToolTip = 'Specifies the value of the Estado de Registro field.';
                    Caption = 'Estado de Registro';
                }
                field(HoraInicio; Rec.HoraInicio)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hora de inicio field.';
                    Caption = 'Hora de inicio';
                }
                field(HoraFin; Rec.HoraFin)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hora de cierre field.';
                    Caption = 'Hora de cierre';
                }
                field(BatchNo; Rec.BatchNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Batch field.';
                    Caption = 'No. Batch';
                }
                field("Fondo efectivo"; Rec."Fondo efectivo")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Fondo efectivo field.';
                    Caption = 'Fondo efectivo';
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(AbrirRef; AbrirCaja)
            { }
            actionref(CerrarRef; CerrarCaja)
            { }

        }
        area(Processing)
        {
            Action(AbrirCaja)
            {
                Caption = 'Abrir Caja';
                ApplicationArea = All;
                Image = Open;
                ToolTip = 'Executes the Abrir Caja action.';
                trigger OnAction();
                var
                    ErrorCajeroLbl: Label 'Este cajero ya tiene una apertura en curso.';
                    ErrorCajaLbl: Label 'Esta caja ya tiene una apertura en uso.';
                    ErrorHoraLbl: Label 'Solo puede abrir esta caja dentro del turno asignado. %1. %2 - %3', Comment = '%1 = Turno; %2 = Hora inicio; %3 = Hora fin';
                    ErrorCajaCerradaLbl: Label 'La caja está cerrada. Favor crear otra línea.';
                begin
                    if rec.BatchNo <> 0 then
                        Error(ErrorCajaCerradaLbl);
                    //Revisa si esta abriendo la caja fuera del turno asignado

                    DSNControlCajeros.Reset();
                    DSNControlCajeros.TransferFields(rec);
                    DSNTurnos.Get(DSNControlCajeros.CodigoTurno);
                    if not (DSNTurnos.HoraInicio <= Time) and (DSNTurnos.HoraFin >= Time) then
                        Error(ErrorHoraLbl, DSNTurnos.Codigo, DSNTurnos.HoraInicio, DSNTurnos.HoraFin);
                    //Revisa si el cajero ya esta en 'abierto'
                    DSNControlCajeros.Reset();
                    DSNControlCajeros.SetRange(Usuario, Rec.Usuario);
                    DSNControlCajeros.SetRange(EstadoRegistro, Rec.EstadoRegistro::Abierto);
                    if DSNControlCajeros.FindFirst() then
                        Error(ErrorCajeroLbl);
                    //Revisa si la caja esta abierta
                    DSNControlCajeros.Reset();
                    DSNControlCajeros.SetRange(CodigoCaja, rec.CodigoCaja);
                    DSNControlCajeros.SetRange(EstadoRegistro, DSNControlCajeros.EstadoRegistro::Abierto);
                    if DSNControlCajeros.FindFirst() then
                        Error(ErrorCajaLbl);

                    //TODO: cuando se necesita modificar un campo que es clave principal, se borra y se inserta el campo
                    DSNControlCajeros.Reset();
                    DSNControlCajeros.TransferFields(rec);
                    rec.Delete();
                    DSNControlCajeros.EstadoRegistro := DSNControlCajeros.EstadoRegistro::Abierto;
                    DSNControlCajeros.BatchNo := 0;
                    DSNControlCajeros.FechaInicio := Today;
                    DSNControlCajeros.HoraInicio := Time;

                    DSNControlCajeros.Insert();



                end;

            }
            Action(CerrarCaja)
            {
                Caption = 'Cerrar caja';
                ApplicationArea = all;
                Image = Close;
                ToolTip = 'Executes the Cerrar caja action.';
                trigger OnAction()
                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                    ControlCajero2: Record ControlCajeros;
                    ErrorFacturasPendientesLbl: Label 'Debe borrar o registrar el siguiente documento: "%1"', Comment = '%1 = No Doc';
                    ErrorCajaSinUsarLbl: Label 'Favor borrar esta línea sí no será utilizada.';

                begin
                    rec.FechaFin := Today;
                    ControlCajero2.Reset();
                    ControlCajero2.SetCurrentKey(BatchNo);
                    ControlCajero2.FindLast();
                    //Cerrar caja
                    if rec.EstadoRegistro = rec.EstadoRegistro::Abierto then begin

                        //No cerrar con saldo pendiente
                        DSNCobrosCajeros.Reset();
                        DSNCobrosCajeros.SetRange("No. Batch", 0);
                        DSNCobrosCajeros.SetRange(Usuario, rec.Usuario);
                        DSNCobrosCajeros.SetRange("Codigo Turno", rec.CodigoTurno);
                        DSNCobrosCajeros.SetRange("No. Registro Factura", '');
                        DSNCobrosCajeros.SetFilter(Importe, '<>%1', 0);
                        if DSNCobrosCajeros.FindFirst() then
                            Error(ErrorFacturasPendientesLbl, DSNCobrosCajeros."No. Documento");

                        //Saldo Cierre

                        DSNCobrosCajeros.Reset();
                        DSNCobrosCajeros.SetCurrentKey("No. Batch", Usuario, "Codigo POS", "Codigo Turno");
                        DSNCobrosCajeros.SetRange("No. Batch", 0);
                        DSNCobrosCajeros.SetRange("Fecha registro", 0D, rec.FechaFin);
                        DSNCobrosCajeros.SetRange(Usuario, rec.Usuario);
                        DSNCobrosCajeros.SetRange("Codigo Turno", rec.CodigoTurno);
                        DSNCobrosCajeros.SetFilter("No. Registro Factura", '<>%1', '');
                        if DSNCobrosCajeros.FindSet() then
                            repeat
                                CobrosCajeros2.Get(DSNCobrosCajeros."Tipo documento", DSNCobrosCajeros."No. Documento", DSNCobrosCajeros."Cod. Medio de pago");
                                CobrosCajeros2."No. Batch" := ControlCajero2.BatchNo + 1;
                                CobrosCajeros2.Status := CobrosCajeros2.Status::Cerrado;
                                CobrosCajeros2.Modify();
                                if (CobrosCajeros2."Forma de pago DGII" = CobrosCajeros2."Forma de pago DGII"::Efectivo) and (CobrosCajeros2.Importe > 0) then
                                    rec."Fondo efectivo" := rec."Fondo efectivo" + CobrosCajeros2.Importe;
                                if (CobrosCajeros2."Devuelta efectivo" = true) then
                                    rec."Fondo efectivo" := rec."Fondo efectivo" - ABS(CobrosCajeros2.Importe);



                                //Asignar BatchNo a SalesInvoiceHeader (facturas registradas)

                                SalesInvoiceHeader.Reset();
                                SalesInvoiceHeader.SetRange("No.", DSNCobrosCajeros."No. Registro Factura");
                                SalesInvoiceHeader.FindFirst();
                                SalesInvoiceHeader.BatchNo := CobrosCajeros2."No. Batch";
                                SalesInvoiceHeader.Modify();


                            until DSNCobrosCajeros.Next() = 0;
                        DSNControlCajeros.TransferFields(rec);
                        rec.Delete();
                        DSNControlCajeros.EstadoRegistro := DSNControlCajeros.EstadoRegistro::Cerrado;
                        DSNControlCajeros.FechaFin := Today;
                        DSNControlCajeros.HoraFin := Time;
                        DSNControlCajeros.BatchNo := ControlCajero2.BatchNo + 1;
                        DSNControlCajeros.Insert();

                        //No permitir crear la caja y borrarla, cogiendo un NoBatch
                        if (rec.ImporteCobrado = 0) and (rec.SaldoPendienteCierre = 0) then
                            Error(ErrorCajaSinUsarLbl);
                    end;
                end;
            }

        }
    }
    trigger OnOpenPage()
    begin
        CurrPage.Update();
    end;

    trigger OnAfterGetRecord()
    begin
        StatusStyleTxt := GetStatusStyleText();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CampoEdit()
    end;

    var
        DSNControlCajeros: Record ControlCajeros;
        DSNTurnos: Record Turnos;
        DSNCobrosCajeros: Record "Cobros Cajeros";
        CobrosCajeros2: Record "Cobros Cajeros";
        StatusStyleTxt: Text;
        EstadoRegistro: Enum DSNEstadoRegistroEnum;
        [InDataSet]
        CampoEditable: Boolean; //TODO: como volver un campo no editable despues de una condicion

    local procedure CampoEdit()
    begin
        if rec.EstadoRegistro <> EstadoRegistro::Espera then
            CampoEditable := false
        else
            CampoEditable := true;
    end;

    //TODO: como cambiarle el color a lineas especificas. Ver en pedidos ventas
    procedure GetStatusStyleText() StatusStyleText: Text
    begin

        if rec.EstadoRegistro = EstadoRegistro::Abierto then
            StatusStyleText := 'Favorable'
        else
            if rec.EstadoRegistro = EstadoRegistro::Cerrado then
                StatusStyleText := 'Strong';

        OnAfterGetStatusStyleText(Rec, StatusStyleText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetStatusStyleText(ControlCajeros: Record ControlCajeros; var StatusStyleText: Text)
    begin
    end;

}