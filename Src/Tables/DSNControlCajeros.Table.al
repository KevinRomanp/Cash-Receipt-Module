table 51103 ControlCajeros
{
    DataClassification = ToBeClassified;
    Caption = 'ControlCajeros';
    fields
    {
        field(1; Usuario; Code[50])
        {
            Caption = 'Usuario';
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = Cajeros.Cajero;

            trigger OnLookup()
            var
                Cajero: Record Cajeros;
            begin
                if Page.RunModal(Page::DSNCajeros, Cajero) = Action::LookupOK then begin
                    Usuario := Cajero.Cajero;
                    CodigoTurno := Cajero.Turno;

                    Cajero.Get(Usuario);
                    "Fondo efectivo" := Cajero.FondoCaja;
                    EstadoRegistro := EstadoRegistro::Espera
                end;
            end;

            trigger OnValidate()
            var
                user: Record User;

            begin
                if Usuario <> '' then begin
                    user.Reset();
                    user.SetRange("User Name", Usuario);
                    user.FindFirst();
                end;

            end;
        }
        field(2; CodigoCaja; Code[6])
        {
            Caption = 'Código caja';
            NotBlank = true;
            TableRelation = PuntosDeVenta.Codigo;
        }
        field(3; CodigoTurno; Code[7])
        {
            Caption = 'Código turno';
            NotBlank = true;
            Editable = true;
            TableRelation = Turnos;
        }
        field(4; FechaInicio; Date)
        {
            Caption = 'Fecha de inicio';
            Editable = false;
        }

        field(5; ImporteCobrado; Decimal)
        {
            Caption = 'Saldo cierre';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Cobros Cajeros".importe Where("No. Batch" = field(BatchNo),
                                                            Status = const(Cerrado),
                                                            Usuario = field(Usuario)));
        }
        field(6; EstadoRegistro; Enum DSNEstadoRegistroEnum)
        {
            Caption = 'Estado de Registro';
            InitValue = Espera;
            Editable = false;
        }
        field(7; HoraInicio; Time)
        {
            Caption = 'Hora de inicio';
            Editable = false;
        }
        field(8; HoraFin; Time)
        {
            Caption = 'Hora de cierre';
            Editable = false;
        }
        field(9; BatchNo; Integer)
        {
            Caption = 'No. Batch';
            Editable = false;
        }
        field(10; SaldoPendienteCierre; Decimal)
        {
            Caption = 'Saldo pte. Cierre';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Cobros Cajeros"."Importe($)" Where("No. Batch" = field(BatchNo),
                                                                Usuario = field(Usuario),
                                                                "Codigo POS" = field(CodigoCaja),
                                                                Status = const(Abierto)));
        }
        field(11; FechaFin; Date)
        {
            Caption = 'Fecha de cerrado';
            Editable = false;
        }
        field(12; "Fondo efectivo"; Decimal)
        {
            Caption = 'Fondo efectivo';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Usuario", CodigoCaja, CodigoTurno, FechaInicio, HoraInicio)
        {
            Clustered = true;
        }

        key(BatchNo; BatchNo)
        { }

        key(EstadoRegistro; EstadoRegistro)
        { }
    }
    trigger OnDelete()
    var
        error01Lbl: Label 'No puede borrar el récord después de haber hecho alguna modificación.';
    begin
        if (rec.EstadoRegistro <> rec.EstadoRegistro::Espera) and (rec.ImporteCobrado <> 0) or (rec.SaldoPendienteCierre <> 0) then
            Error(error01Lbl);
    end;



}