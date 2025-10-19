
%% Run unconditional forecast using structural model 

% Run an unconditional forecast using the structural model
[structForecastTbl, structForecastContribsTbl] = structModel.forecast( ...
    ?FORECAST_SPAN? ...
    , stochasticResiduals=?STOCHASTIC_RESIDUALS? ...
    , includeInitial=?INCLUDE_INITIAL?...
    , contributions=?CONTRIBUTIONS? ...
);

% Condense the forecast to percentiles
structForecastPercentilesTbl = tablex.apply(structForecastTbl, prctilesFunc);
printTable(structForecastPercentilesTbl);

% Save the percentiles of the forecast
outputPath__ = fullfile(outputFolder, "structForecastPercentiles");
?SAVE_MAT?save(outputPath__ + ".mat", "structForecastPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(structForecastPercentilesTbl, outputPath__ + ".csv");
?SAVE_XLS?tablex.writetimetable(structForecastPercentilesTbl, outputPath__ + ".xls");

if ~isempty(structForecastContribsTbl)
    % Condense the forecast contributions to percentiles
    structForecastContribsPercentilesTbl = tablex.apply(structForecastContribsTbl, prctilesFunc);
    % Flatten the 3D contributions table to 2D contributions table
    structForecastContribsPercentilesTbl = tablex.flatten(structForecastContribsPercentilesTbl);

    % Save the percentiles of the forecast contributions
    outputPath__ = fullfile(outputFolder, "structForecastContribsPercentiles");
    ?SAVE_MAT?save(outputPath__ + ".mat", "structForecastContribsPercentilesTbl");
    ?SAVE_CSV?tablex.writetimetable(structForecastContribsPercentilesTbl, outputPath__ + ".csv");
    ?SAVE_XLS?tablex.writetimetable(structForecastContribsPercentilesTbl, outputPath__ + ".xls");
end

