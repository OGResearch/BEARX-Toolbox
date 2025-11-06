
function updateIneqRestrictTable(meta)

    FORM = {"identification", "IneqRestrict"};
    TITLE = "Inequality (sign) restrictions";

    form = gui.readFormsFile(FORM);
    meta = gui.getCurrentMetaObj();
    endogenousNames = meta.EndogenousNames;
    shockNames = meta.SeparableShockNames;

    gui.updateTableWhenNecessary( ...
        rowNames=endogenousNames, ...
        columnNames=shockNames, ...
        fileName=string(form.FileName.value), ...
        title=TITLE ...
    );

end%

