permissionset 51100 CashReceiptModSUPER
{
    Assignable = true;
    Permissions = tabledata Cajeros = RIMD,
        tabledata "Cobros Cajeros" = RIMD,
        tabledata "Conf. Medios de Pagos" = RIMD,
        tabledata "Config. Denominaciones" = RIMD,
        tabledata ControlCajeros = RIMD,
        tabledata "Hist. Denominaciones" = RIMD,
        tabledata PuntosDeVenta = RIMD,
        tabledata Turnos = RIMD,
        table Cajeros = X,
        table "Cobros Cajeros" = X,
        table "Conf. Medios de Pagos" = X,
        table "Config. Denominaciones" = X,
        table ControlCajeros = X,
        table "Hist. Denominaciones" = X,
        table PuntosDeVenta = X,
        table Turnos = X,

        Codeunit "DSNFunciones Cobros" = X,

        Codeunit "DSNRegistrar cobros" = X,
        Page DSNCajeros = X,
        Page "DSNCobros Cajeros" = X,
        Page DSNConfMediosDePagos = X,
        Page DSNControlCajeros = X,
        Page DSNCajeroRoleCenter = X,
        Page DSNPuntosDeVenta = X,
        Page DSNTurnos = X;
}