page 51101 DSNPuntosDeVenta
{
    Caption = 'Lista de puntos de venta';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = PuntosDeVenta;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field(Codigo; Rec.Codigo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codigo field.';
                    Caption = 'Codigo';
                }
                field(Descripcion; Rec.Descripcion)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Descripcion field.';
                    Caption = 'Descripcion';
                }
                field(DimCentroCosto; Rec.DimCentroCosto)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the DimCentroCosto field.';
                    Caption = 'DimCentroCosto';
                }
                field(DimIngresos; Rec.DimIngresos)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the DimIngresos field.';
                    Caption = 'DimIngresos';
                }
                field(DimCaja; Rec.DimCaja)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Dimension caja field.';
                    Caption = 'Dimension caja';
                }
            }
        }
        area(Factboxes)
        {

        }
    }
}