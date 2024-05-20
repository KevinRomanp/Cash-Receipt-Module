tableextension 51101 "DSNSales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(51100; BatchNo; Integer)
        {
            Caption = 'Batch No';
            DataClassification = CustomerContent;
        }
    }
}
