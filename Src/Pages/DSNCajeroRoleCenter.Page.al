page 51106 DSNCajeroRoleCenter
{
    ApplicationArea = All;
    Caption = 'DSNCajeroRoleCenter';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        { }
    }
    actions
    {
        area(Processing)
        {
            Action(FacturaVentas)
            {
                ApplicationArea = all;
                Caption = 'Factura venta';
                RunObject = Page "Sales Invoice list";
                ToolTip = 'Executes the Factura venta action.';
            }
            Action(PedidoVentas)
            {
                ApplicationArea = all;
                Caption = 'Pedidos venta';
                RunObject = Page "sales order list";
                ToolTip = 'Executes the Pedidos venta action.';
            }
            Action(Clientes)
            {
                ApplicationArea = all;
                Caption = 'Clientes';
                RunObject = Page "Customer list";
                ToolTip = 'Executes the Clientes action.';
            }
            Action(Cotizaciones)
            {
                ApplicationArea = all;
                Caption = 'Cotizaciones venta';
                RunObject = Page "Sales quote";
                ToolTip = 'Executes the Cotizaciones venta action.';
            }
            Action(DiaRecepcionEfectivo)
            {
                ApplicationArea = all;
                Caption = 'Diario Recepción de Efectivo';
                RunObject = Page "payment journal";
                ToolTip = 'Executes the Diario Recepción de Efectivo action.';
            }
            Action(MovBanco)
            {
                ApplicationArea = all;
                Caption = 'Mov. Banco';
                RunObject = Page "Bank Account Ledger Entries";
                ToolTip = 'Executes the Mov. Banco action.';
            }
            Action(MovCliente)
            {
                ApplicationArea = all;
                Caption = 'Mov. Cliente';
                RunObject = Page "Customer Ledger Entries";
                ToolTip = 'Executes the Mov. Cliente action.';
            }
            /*Action(EstadoCuentaCliente)
            {
                ApplicationArea = all;
                Caption = 'Estado de Cuenta de Clientes';
                ToolTip = 'Executes the Estado de Cuenta de Clientes action.';
                //RunObject = page "Bank Account Ledger Entries";
            }*/


        }
    }
}
