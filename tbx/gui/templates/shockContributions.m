
%% Calculate shock contributions to historical paths 

% Calculate the contributions
fevdTbl = structModel.calculateContributions( ...
    includeInitial=?INCLUDE_INITIAL? ...
);

% Condense the results to percentiles and flatten the 3D table to 2D table
fevdPercentilesTbl = tablex.apply(fevdTbl, prctilesFunc);
fevdPercentilesTbl = tablex.flatten(fevdPercentilesTbl);
printTable(fevdPercentilesTbl);

% Save the results
outputPath__ = fullfile(outputFolder, "fevdPercentiles");
?SAVE_MAT?save(outputPath__ + ".mat", "fevdPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(fevdPercentilesTbl, outputPath__ + ".csv");
?SAVE_XLS?tablex.writetimetable(fevdPercentilesTbl, outputPath__ + ".xls");

