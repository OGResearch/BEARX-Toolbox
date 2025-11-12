
function figureHandles = contributionsMedian(tt, model, varargin)

    meta = model.getMeta();
    chartGroups = meta.getContributionsChartGroups();

    maxNumNames = max(cellfun(@numel, chartGroups));
    tiling = chartpack.getAutoTiling(maxNumNames);

    chartFunc = @tablex.bar;

    higherDims = tablex.getHigherDims(tt);
    figureLegend = higherDims{1};

    figureHandles = cell.empty(1,0);
    for i = 1 : numel(chartGroups) 
        currentFigureHandles = chartpack.framework( ...
            chartFunc, tt, chartGroups{i} ...
            , "tiling", tiling ...
            , "numFiguresSoFar", numel(figureHandles) ...
            , "figureLegend", figureLegend ...
            , varargin{:} ...
        );
        figureHandles = [figureHandles, currentFigureHandles]; %#ok<AGROW>
    end

end%

