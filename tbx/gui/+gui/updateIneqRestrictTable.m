
function updateIneqRestrictTable(meta)

    INEQUALITY_XLSX = "IneqRestrict.xlsx";
    TITLE = "Inequality (sign) restrictions";

    meta = gui.getCurrentMetaObj();
    endogenousNames = meta.EndogenousNames;
    shockNames = meta.SeparableShockNames;

    gui.updateTableWhenNecessary( ...
        rowNames=endogenousNames, ...
        columnNames=shockNames, ...
        fileName=INEQUALITY_XLSX, ...
        title=TITLE ...
    );

end%

