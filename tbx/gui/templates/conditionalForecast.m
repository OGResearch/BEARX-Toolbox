
%% Run conditional forecast 

% Read table with custom conditioning data
inputPath__ = fullfile("tables", "ConditioningData.xlsx");
conditioningData = tablex.readConditioningData( ...
    inputPath__, ...
    timeColumn="Conditioning data" ...
);
printTable(conditioningData);

?PLAN?

% Run a conditional forecast
[condForecastTbl, condForecastContribsTbl] = structModel.conditionalForecast( ...
    ?FORECAST_SPAN? ...
    , conditions=conditioningData ...
    , plan=conditioningPlan ...
    , exogenousFrom="?EXOGENOUS_FROM?" ...
    , contributions=?CONTRIBUTIONS? ...
    , includeInitial=?INCLUDE_INITIAL?...
);

% Condense the results to percentiles
condForecastPercentilesTbl = tablex.apply(condForecastTbl, prctilesFunc);
printTable(condForecastPercentilesTbl);

% Save the results
outputPath__ = fullfile(outputFolder, "condForecastPercentiles");
?SAVE_MAT?save(outputPath__ + ".mat", "condForecastPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(condForecastPercentilesTbl, outputPath__ + ".csv");
?SAVE_XLS?tablex.writetimetable(condForecastPercentilesTbl, outputPath__ + ".xlsx");

if ~isempty(condForecastContribsTbl)
    % Condense the results to percentiles
    condForecastContribsPercentilesTbl = tablex.apply(condForecastContribsTbl, prctilesFunc);
    % Flatten the 3D contributions table to 2D contributions table
    condForecastContribsPercentilesTbl = tablex.flatten(condForecastContribsPercentilesTbl);

    % Save the results
    outputPath__ = fullfile(outputFolder, "condForecastContribsPercentiles");
    ?SAVE_MAT?save(outputPath__ + ".mat", "condForecastContribsPercentilesTbl");
    ?SAVE_CSV?tablex.writetimetable(condForecastContribsPercentilesTbl, outputPath__ + ".csv");
    ?SAVE_XLS?tablex.writetimetable(condForecastContribsPercentilesTbl, outputPath__ + ".xlsx");
end

