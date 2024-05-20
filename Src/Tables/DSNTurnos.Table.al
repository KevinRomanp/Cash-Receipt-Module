table 51100 Turnos
{
    DataClassification = ToBeClassified;
    Caption = 'Turnos';
    fields
    {
        field(1; Codigo; Code[7])
        {
            Caption = 'Código';
            DataClassification = ToBeClassified;

        }
        field(2; Descripcion; Text[25])
        {
            Caption = 'Descripción';
            DataClassification = ToBeClassified;
        }
        field(3; HoraInicio; Time)
        {
            Caption = 'Hora inicio';
            DataClassification = ToBeClassified;
        }
        field(4; HoraFin; Time)
        {
            Caption = 'Hora fin';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Codigo")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Codigo, Descripcion, HoraInicio, HoraFin)
        { }
        fieldgroup(Brick; Codigo, Descripcion, HoraInicio, HoraFin)
        { }
    }

}