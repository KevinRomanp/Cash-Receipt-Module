table 51107 "Hist. Denominaciones"
{
    DataClassification = ToBeClassified;
    Caption = 'Hist. Denominaciones';
    fields
    {
        field(1; Usuario; Code[50])
        {
            Caption = 'Usuairo';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        field(2; Fecha; Date)
        {
            Caption = 'Fecha';
            DataClassification = ToBeClassified;
        }
        field(3; "Tipo Moneda"; Code[10])
        {
            Caption = 'Tipo Moneda';
            DataClassification = ToBeClassified;
            TableRelation = Currency;
        }
        field(4; Denominacion; Integer)
        {
            Caption = 'Denominacion';
            DataClassification = ToBeClassified;
        }
        field(5; Cantidad; Integer)
        {
            Caption = 'Cantidad';
            DataClassification = ToBeClassified;
        }
        field(6; "No. Batch"; Integer)
        {
            Caption = 'No. Batch';
            DataClassification = ToBeClassified;
        }
        field(7; POS; Code[10])
        {
            Caption = 'POS';
            DataClassification = ToBeClassified;
            TableRelation = PuntosDeVenta;
        }


    }

    keys
    {
        key(PK; Usuario)
        {
            Clustered = true;
        }
    }

}