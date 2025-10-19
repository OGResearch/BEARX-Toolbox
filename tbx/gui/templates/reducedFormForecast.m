
%% Run unconditional forecast using reduced-form model

% Run an unconditional forecast using the structural model
redForecastTbl = redModel.forecast( ...
    ?FORECAST_SPAN? ...
    , stochasticResiduals=?STOCHASTIC_RESIDUALS? ...
    , includeInitial=?INCLUDE_INITIAL? ...
);

% Condense the forecast to percentiles
redForecastPercentilesTbl = tablex.apply(redForecastTbl, prctilesFunc);
printTable(redForecastPercentilesTbl);

% Save the percentiles of the forecast
outputPath__ = fullfile(outputFolder, "redForecastPercentiles");
?SAVE_MAT?save(outputPath__ + ".mat", "redForecastPercentilesTbl");
?SAVE_CSV?tablex.writetimetable(redForecastPercentilesTbl, outputPath__ + ".csv");
?SAVE_XLS?tablex.writetimetable(redForecastPercentilesTbl, outputPath__ + ".xls");

