tableextension 51102 "DSNSales Header" extends "Sales Header"
{
    fields
    {
        field(72000; "DSNPOSExt"; Boolean)
        {
            Caption = 'Sic POS';
            DataClassification = CustomerContent;
        }
    }
    trigger OnDelete()
    var
        DSNCobrosCajeros: Record "Cobros Cajeros";
    begin
        DSNCobrosCajeros.Reset();
        DSNCobrosCajeros.SetRange("Tipo documento", rec."Document Type");
        DSNCobrosCajeros.SetRange("No. Documento", rec."No.");
        if DSNCobrosCajeros.FindSet() then
            repeat
                DSNCobrosCajeros.Delete();
            until DSNCobrosCajeros.Next() = 0;
    end;
}
