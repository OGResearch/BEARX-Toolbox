
function updateInstantZerosTable()

    INSTANT_ZEROS_XLSX = "InstantZeros.xlsx";
    TITLE = "Instant exact zero restrictions";

    meta = gui.getCurrentMetaObj();
    endogenousNames = meta.EndogenousNames;
    shockNames = meta.SeparableShockNames;

    gui.updateTableWhenNecessary( ...
        rowNames=endogenousNames, ...
        columnNames=shockNames, ...
        fileName=INSTANT_ZEROS_XLSX, ...
        title=TITLE ...
    );

end%

