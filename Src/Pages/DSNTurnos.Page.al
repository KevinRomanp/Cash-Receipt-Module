page 51100 DSNTurnos
{
    Caption = 'Lista de turnos puntos de venta';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = Turnos;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field(Codigo; rec.Codigo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Código field.';
                    Caption = 'Código';
                }
                field(Descripcion; Rec.Descripcion)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Descripción field.';
                    Caption = 'Descripción';
                }
                field(HoraInicio; Rec.HoraInicio)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Hora inicio field.';
                    Caption = 'Hora inicio';
                }
                field(HoraFin; Rec.HoraFin)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Hora fin field.';
                    Caption = 'Hora fin';
                }

            }
        }
        area(Factboxes)
        {

        }
    }

}