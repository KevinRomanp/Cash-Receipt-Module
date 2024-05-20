pageextension 51100 "DSNAccountant Role Center" extends "Accountant Role Center"
{
    layout
    {

    }
    actions
    {
        addafter(Action172)
        {
            group(DSNModuloCajasDSN)
            {
                Caption = 'Modulo de cajas';
                Action(ControlCajeros)
                {
                    ApplicationArea = all;
                    Caption = 'Control de cajeros';
                    RunObject = Page DSNControlCajeros;
                    ToolTip = 'Executes the Control de cajeros action.';
                }
                Action(Turnos)
                {
                    ApplicationArea = All;
                    Caption = 'Turnos';
                    RunObject = Page DSNTurnos;
                    ToolTip = 'Executes the Turnos action.';
                }
                Action(PuntosDeVenta)
                {
                    ApplicationArea = all;
                    Caption = 'Puntos de ventas';
                    RunObject = Page DSNPuntosDeVenta;
                    ToolTip = 'Executes the Puntos de ventas action.';
                }
                Action(Cajeros)
                {
                    ApplicationArea = all;
                    Caption = 'Cajeros';
                    RunObject = Page DSNCajeros;
                    ToolTip = 'Executes the Cajeros action.';
                }

                Action(MediosDePagos)
                {
                    ApplicationArea = all;
                    Caption = 'Medios de Pagos';
                    RunObject = Page DSNConfMediosDePagos;
                    ToolTip = 'Executes the Medios de Pagos action.';
                }
            }
        }
    }
}