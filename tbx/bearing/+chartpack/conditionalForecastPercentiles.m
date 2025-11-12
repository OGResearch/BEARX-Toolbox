
function figureHandles = conditionalForecastPercentiles(tt, model, varargin)

    meta = model.getMeta();
    chartGroups = meta.getConditionalForecastChartGroups();

    maxNumNames = max(cellfun(@numel, chartGroups));
    tiling = chartpack.getAutoTiling(maxNumNames);

    chartFunc = @tablex.plotPercentiles;

    figureHandles = cell.empty(1,0);
    for i = 1 : numel(chartGroups) 
        currentFigureHandles = chartpack.framework( ...
            chartFunc, tt, chartGroups{i} ...
            , "tiling", tiling ...
            , "numFiguresSoFar", numel(figureHandles) ...
            , varargin{:} ...
        );
        figureHandles = [figureHandles, currentFigureHandles]; %#ok<AGROW>
    end

end%

