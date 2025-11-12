
function [plotHandles, axesHandle] = drawChart(plotFunc, tt, names, options)

    arguments
        plotFunc function_handle
        tt timetable
        names (1, :) string
        %
        options.Periods = Inf
        options.AxesHandle = []
        options.Variant = ':'
        options.Dims (1, :) cell = cell.empty(1, 0)
        options.PlotSettings (1, :) cell = {}
        options.AxesSettings (1, :) cell = {}
        options.PlotSettingsFunc (1, :) cell = {}
        options.Title = ""
    end

    if isstring(options.Variant)
        options.Variant = char(options.Variant);
    end

    periods = options.Periods;
    if isequal(periods, Inf)
        periods = tablex.span(tt);
    end

    if ~isempty(options.AxesHandle)
        axesHandle = options.AxesHandle;
    else
        axesHandle = gca();
    end

    axesSettings = options.AxesSettings;
    axesSettings = [ ...
        {"xlim", [periods(1), periods(end)]} ...
        , axesSettings ...
    ];

    dataCell = tablex.retrieveDataAsCellArray( ...
        tt, names, periods, ...
        variant=options.Variant, ...
        dims=options.Dims ...
    );

    for i = 1 : numel(dataCell)
        dataCell{i} = dataCell{i}(:,:);
    end

    plotHandles = plotFunc(axesHandle, periods, [dataCell{:}]);

    if ~isempty(axesSettings)
        set(axesHandle, axesSettings{:});
    end

    chartTitle = options.Title;
    if chartTitle == ""
        chartTitle = join(names, " | ");
    end
    title(axesHandle, chartTitle, interpreter="none");

    if ~isempty(options.PlotSettings)
        set(plotHandles, options.PlotSettings{:});
    end

    if ~isempty(options.PlotSettingsFunc)
        for i = 1 : numel(options.PlotSettingsFunc)
            func = options.PlotSettingsFunc{i};
            func(axesHandle, plotHandles);
        end
    end

end%

