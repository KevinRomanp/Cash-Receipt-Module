pageextension 51105 "DSNPosted sales Invoices" extends "Posted Sales Invoices"
{
    layout
    {
        addbefore("Remaining Amount")
        {
            field(DSNBatchNo; Rec.BatchNo)
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the Batch No field.';
                Caption = 'Batch No';
            }
            field("User ID"; Rec."User ID")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the User ID field.';
                Caption = 'User ID';
            }
        }
    }
}
