pageextension 51106 "DSNCash Receipt Journals" extends "Cash Receipt Journal"
{
    //001+
    //Este boton no se va autilizar, se debe colocar el id del informe del recibo en libros diario 
    //general, libro Recepcion de efectivo ID informe cliente.
    //FES: Adicionar boton para registrar e impirimir recibo de ingreso
    //001-
    actions
    {
        addlast("P&osting")
        {
            Action("Post and Print Receipt")
            {
                Caption = 'Registrar e Imprimir Recibo';
                ApplicationArea = Basic, Suite;
                Image = PostPrint;
                Promoted = true;
                Visible = false;  //001+-
                PromotedCategory = Process;
                ToolTip = 'Executes the Registrar e Imprimir Recibo action.';
                trigger OnAction()
                begin
                    Rec.SendToPosting(Codeunit::"Gen. Jnl.-Post");
                    CurrPage.Update(false);
                end;

            }
        }
    }

}