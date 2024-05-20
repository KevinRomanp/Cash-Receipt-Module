table 51101 PuntosDeVenta
{
    DataClassification = ToBeClassified;
    Caption = 'PuntosDeVenta';
    fields
    {
        field(1; Codigo; Code[6])
        {
            Caption = 'Codigo';
            DataClassification = ToBeClassified;
        }
        field(2; Descripcion; Text[40])
        {
            Caption = 'Descripcion';
            DataClassification = ToBeClassified;
        }
        field(3; DimCentroCosto; Code[12])
        {
            Caption = 'DimCentroCosto';
            TableRelation = Dimension;
            DataClassification = ToBeClassified;
        }
        field(4; DimIngresos; Code[12])
        {
            Caption = 'DimIngresos';
            TableRelation = "Dimension Value" Where("Dimension Code" = const('SUCURSAL'));
            DataClassification = ToBeClassified;
        }
        field(5; DimCaja; Code[6])
        {
            Caption = 'Dimension caja';
            TableRelation = Dimension;
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
        fieldgroup(DropDown; Codigo, Descripcion)
        { }
        fieldgroup(Brick; Codigo, Descripcion)
        { }
    }

}