table 51106 "Config. denominaciones"
{
    DataClassification = ToBeClassified;
    Caption = 'Config. denominaciones';
    fields
    {
        field(1; "Tipo moneda"; Code[10])
        {
            Caption = 'Tipo moneda';
            DataClassification = ToBeClassified;
            TableRelation = Currency;
        }

        field(2; Denominacion; Integer)
        {
            Caption = 'Denominacion';
            DataClassification = ToBeClassified;
        }
        field(3; Cantidad; Integer)
        {
            Caption = 'Cantidad';
            DataClassification = ToBeClassified;
        }
        field(4; "No. Batch"; Integer)
        {
            Caption = 'No. Batch';
            DataClassification = ToBeClassified;
        }


    }

    keys
    {/*
        key(PK; "MyField")
        {
            Clustered = true;
        }*/
    }

}