
%% Simulate shock responses 

% Simulate the responses to shocks over the shock response horizon
responseTbl = structModel.simulateResponses( ...
    includeInitial=?INCLUDE_INITIAL? ...
);

% Condense the results to percentiles and flatten the 3D table to 2D table
responsePercentilesTbl = tablex.apply(responseTbl, prctilesFunc);
responsePercentilesTbl = tablex.flatten(responsePercentilesTbl);
printTable(responsePercentilesTbl);

% Save the results
outputPath__ = fullfile(outputFolder, "responsePercentiles");
?SAVE_MAT?save(outputPath__ + ".mat", "responsePercentilesTbl");
?SAVE_CSV?tablex.writetimetable(responsePercentilesTbl, outputPath__ + ".csv");
?SAVE_XLS?tablex.writetimetable(responsePercentilesTbl, outputPath__ + ".xlsx");

