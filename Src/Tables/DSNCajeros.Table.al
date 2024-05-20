table 51102 Cajeros
{
    DataClassification = ToBeClassified;
    Permissions =
        tabledata User = R;
    Caption = 'Cajeros';
    fields
    {
        field(1; Cajero; Code[50])
        {
            Caption = 'ID Usuario';
            TableRelation = User."User Name";
            DataClassification = CustomerContent;
            NotBlank = true;
            ValidateTableRelation = false;


            trigger OnLookup()
            var
                user: Record user;
            begin
                if Page.RunModal(Page::Users, user) = Action::LookupOK then begin
                    Validate(Cajero, User."User Name");
                    Cajero := user."User Name";
                    Nombre := user."Full Name";
                end;
            end;

            trigger OnValidate()
            var
                user: Record User;
            begin
                if Cajero <> '' then begin
                    user.Reset();
                    user.SetRange("User Name", Cajero);
                    user.FindFirst();
                end;
            end;
        }
        field(2; Nombre; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Nombre completo';
            Editable = false;
        }
        field(3; FondoCaja; Decimal)
        {
            Caption = 'Fondo de caja';
            DataClassification = CustomerContent;
        }
        field(4; Turno; Code[7])
        {
            DataClassification = CustomerContent;
            Caption = 'Turno';
            TableRelation = Turnos;
        }
        field(5; "Global Dimension Code 1 "; Code[10])
        {
            Caption = 'Cod. dimension global 1';
            DataClassification = ToBeClassified;
        }
        field(6; "Global Dimension Code 2 "; Code[10])
        {
            Caption = 'Cod. dimension global 2';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Cajero")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Cajero, Nombre)
        { }
        fieldgroup(Brick; Cajero, Nombre)
        { }
    }
    trigger OnInsert()
    var
        ConfigUsuario: record "User Setup";
        ErrorSupervisor: Label 'Este usuario es supervisor de cajeros, no puede crearse como cajero.';
    begin
        ConfigUsuario.Get(rec.Cajero);
        if ConfigUsuario."Supervisor Cajeros" then
            Error(ErrorSupervisor);
    end;
}