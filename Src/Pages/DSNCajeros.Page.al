page 51102 DSNCajeros
{
    Caption = 'Cajeros';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Cajeros;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field(Cajero; Rec.Cajero)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID Usuario field.';
                    Caption = 'ID Usuario';
                }
                field(Nombre; Rec.Nombre)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Nombre completo field.';
                    Caption = 'Nombre completo';
                }
                field(FondoCaja; Rec.FondoCaja)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Fondo de caja field.';
                    Caption = 'Fondo de caja';
                }
                field(Turno; Rec.Turno)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Turno field.';
                    Caption = 'Turno';
                }
            }
        }
        area(Factboxes)
        {

        }
    }
}
