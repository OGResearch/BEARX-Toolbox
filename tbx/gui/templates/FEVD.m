
%% Calculate forecast error variance decomposition (FEVD)

% Calculate FEVD over shock response horizon
fevdTbl = structModel.calculateFEVD( ...
    includeInitial=?INCLUDE_INITIAL? ...
);

% Condense the results to percentiles and flatten the 3D table to 2D table
fevdPercentilesTbl = tablex.apply(fevdTbl, percentilesFunc);
fevdPercentilesTbl = tablex.flatten(fevdPercentilesTbl);
?PRINT_TABLE?display(fevdPercentilesTbl);

% Define the output path for saving the results
outputPath = fullfile(outputFolder, "fevdPercentiles");

% Save the results as percentiles as MAT and/or CSV and/or XLSX files
?SAVE_MAT?save(outputPath + ".mat", "fevdPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(fevdPercentilesTbl, outputPath + ".csv");
?SAVE_XLS?tablex.writetimetable(fevdPercentilesTbl, outputPath + ".xlsx");

