
function [fcastTbl, contribsTbl] = conditionalForecast(this, fcastSpan, options)

    arguments
        this
        fcastSpan (1, :) datetime

        options.Conditions (:, :) timetable
        options.Plan = []
        options.IncludeInitial (1, 1) logical = true

        options.Contributions (1, 1) logical = false
        options.Precontributions = []
        options.ExogenousFrom (1, 1) string = "inputData"
    end

    VARIANT_DIM = 3;
    CONTRIB_DIM = 3;

    meta = this.Meta;
    numY = meta.NumPseudoEndogenousNames;
    order = meta.Order;
    numL = numY * order;
    shortFcastSpan = datex.ensureSpan(fcastSpan);
    fcastStart = shortFcastSpan(1);
    longFcastSpan = datex.longSpanFromShortSpan(shortFcastSpan, meta.Order);
    fcastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
    fcastHorizon = numel(shortFcastSpan);
    longYX = this.getSomeYX(longFcastSpan);
    [longY, longX] = longYX{:};

    if lower(options.ExogenousFrom) == lower("inputData")
        fcastX = this.getSomeX(shortFcastSpan);
    elseif lower(options.ExogenousFrom) == lower("conditions")
        fcastX = tablex.retrieveData(options.Conditions, meta.ExogenousNames, shortFcastSpan);
    else
        error("Invalid source of exogenous data: %s.", options.ExogenousFrom);
    end

    cfconds = conditional.createConditionsCF(meta, options.Plan, options.Conditions, shortFcastSpan);
    cfshocks = conditional.createShocksCF(meta, options.Plan, shortFcastSpan);
    cfblocks = conditional.createBlocksCF(cfconds, cfshocks);
    numShockConcepts = meta.NumShockConcepts;

    internalOptions = struct();
    internalOptions.hasIntercept = meta.HasIntercept;
    internalOptions.order = meta.Order;
    internalOptions.cfconds = [];
    internalOptions.cfblocks = [];
    internalOptions.cfshocks = [];

    numPresampled = this.NumPresampled;
    progressMessage = sprintf("Conditional forecast [%g]", numPresampled);

    numSeparableUnits = meta.NumSeparableUnits;
    if numSeparableUnits > 1
        if ~isempty(cfconds)
            cfconds = reshape(cfconds, size(cfconds, 1), [], numSeparableUnits);
        end
        if ~isempty(cfshocks)
            cfshocks = reshape(cfshocks, size(cfshocks, 1), [], numSeparableUnits);
        end
        if ~isempty(cfblocks)
            cfblocks = reshape(cfblocks, size(cfblocks, 1), [], numSeparableUnits);
        end
    end
    fcastY = cell(1, numPresampled);
    fcastE = cell(1, numPresampled);

    if options.Contributions
        [contributor, precontribs] = this.prepareContributor(shortFcastSpan, options.Precontributions);
        contribs = cell(1, numPresampled);
    end

    progressBar = progress.Bar(progressMessage, numPresampled*numSeparableUnits);
    for i = 1 : numPresampled
        sample = this.Presampled{i};
        initY = this.ReducedForm.getInitY(longY, internalOptions.order, sample, fcastStartIndex);
        draw = this.ConditionalDrawer(sample, fcastStartIndex, fcastHorizon);
        EXTRA_DIM = 3;
        for unit = 1 : numSeparableUnits
            if ~isempty(cfconds)
                internalOptions.cfconds = cfconds(:, :, unit);
            end
            if ~isempty(cfshocks)
                internalOptions.cfshocks = cfshocks(:, :, unit);
                for k = 1 : numel(internalOptions.cfshocks)
                    internalOptions.cfshocks{k} = internalOptions.cfshocks{k} - (unit-1)*numShockConcepts;
                end
            end
            if ~isempty(cfblocks)
                internalOptions.cfblocks = cfblocks(:, :, unit);
            end
            unitInitY = initY(:, :, unit);
            unitD = sample.D(:, :, unit);
            if numSeparableUnits == 1
                unitBeta = draw.beta;
            else
                unitBeta = system.extractUnitFromCellArray(draw.beta, unit, EXTRA_DIM);
            end
            %
            %
            % Run the core conditional forecast function
            [unitY, unitE] = conditional.forecast( ...
                transpose(unitD) ...
                , [unitBeta{:}] ...
                , unitInitY ...
                , fcastX ...
                , fcastHorizon ...
                , internalOptions ...
            );
            %
            %
            fcastY{i} = [fcastY{i}, unitY];
            fcastE{i} = [fcastE{i}, unitE];

            if options.Contributions
                unitA = cell(1, fcastHorizon);
                unitC = cell(1, fcastHorizon);
                for k = 1 : fcastHorizon
                    unitB = reshape(unitBeta{k}, [], numY);
                    unitA{k} = unitB(1:numL, :);
                    unitC{k} = unitB(numL+1:end, :);
                end
                unitContribs = contributor(unitA, unitC, unitD, unitE, fcastX, unitInitY, precontribs(:, :, :, i));
                contribs{i} = [contribs{i}, unitContribs];
            end

            progressBar.increment();
        end
    end

    % Concatenate the individual variants
    fcastY = cat(VARIANT_DIM, fcastY{:});
    fcastE = cat(VARIANT_DIM, fcastE{:});

    outNames = [meta.PseudoEndogenousNames, meta.ShockNames];
    outData = [fcastY, fcastE];
    outSpan = shortFcastSpan;
    if options.IncludeInitial
        outSpan = longFcastSpan;
        initData = [repmat(initY(:, :), 1, 1, numPresampled), zeros(order, numY, numPresampled)];
        outData = [initData; outData];
    end

    fcastTbl = tablex.fromNumericArray(outData, outNames, outSpan, variantDim=VARIANT_DIM);

    contribsTbl = [];
    if options.Contributions
        contribsTbl = this.tabulateContributions(contribs, shortFcastSpan);
    end

end%

