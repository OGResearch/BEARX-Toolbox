
classdef Verifiables ...
    < identifier.Base

    properties (Constant)
        DEFAULT_MAX_CANDIDATES = 100
        DEFAULT_TRY_FLIP_SIGNS = true
    end


    properties (SetAccess = protected)
        VerifiableTests
        InstantZeros = identifier.InstantZeros()
        IneqRestrictTable (:, :) table
        %
        MaxCandidates (1, 1) double {mustBePositive} = identifier.Verifiables.DEFAULT_MAX_CANDIDATES
        TryFlipSigns (1, 1) logical = identifier.Verifiables.DEFAULT_TRY_FLIP_SIGNS
        TestStrings (:, 1) string = string.empty(0, 1)
    end


    methods
        function this = Verifiables(testStrings, inputs, options)
            arguments
                testStrings (:, 1) string = string.empty(0, 1)
                %
                inputs.IneqRestrictTable = []
                inputs.InstantZeros = []
                inputs.InstantZerosTable = []
                %
                options.MaxCandidates (1, 1) double = identifier.Verifiables.DEFAULT_MAX_CANDIDATES
                options.TryFlipSigns (1, 1) logical = identifier.Verifiables.DEFAULT_TRY_FLIP_SIGNS
                options.FileName (1, 1) string = ""
                % options.ShortCircuit (1, 1) logical = identifier.VerifiableTests.DEFAULT_SHORT_CIRCUIT
            end
            %
            if options.FileName ~= ""
                this.TestStrings = identifier.testStringsFromMarkdown(options.FileName);
            else
                this.TestStrings = testStrings;
            end
            this.MaxCandidates = options.MaxCandidates;
            this.TryFlipSigns = options.TryFlipSigns;
            this.IneqRestrictTable = inputs.IneqRestrictTable;
            this.addInstantZeros(inputs);
            %
        end%

        function whenPairedWithModel(this, modelS)
            if ~isempty(this.InstantZeros)
                this.InstantZeros.whenPairedWithModel(modelS);
            end
            this.populateSeparableNames(modelS.Meta);
            this.addSignRestrictions(modelS);
            this.VerifiableTests = identifier.VerifiableTests(this.TestStrings);
        end%

        function initializeSampler(this, modelS)
            %[
            reducedFormSampler = modelS.ReducedForm.Estimator.Sampler;
            identificationDrawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
            historyDrawer = modelS.ReducedForm.Estimator.HistoryDrawer;
            meta = modelS.Meta;
            numShocks = modelS.Meta.NumShockNames;
            order = meta.Order;
            hasIntercept = meta.HasIntercept;
            longYX = modelS.getLongYX();
            [longY, longX] = longYX{:};
            %
            [testFunc, occurrence] = this.VerifiableTests.buildTestEnvironment(modelS.Meta);
            has = struct();
            for n = ["SHKRESP", "FEVD", "SHKEST", "SHKCONT"]
                has.(n) = isfield(occurrence, n);
            end
            %
            % Initialize the InstantZeros object without a warning
            this.InstantZeros.deinitialize();
            this.InstantZeros.initialize(modelS);
            candidator = this.InstantZeros.getCandidator();
            %
            %
            function sample = samplerS()
                % Loop until a valid sample-candidate is found
                while true
                    sample = reducedFormSampler();
                    identificationDraw = identificationDrawer(sample);
                    sample.IdentificationDraw = identificationDraw;
                    if has.SHKEST
                        historyDraw = historyDrawer(sample);
                        residuals = system.calculateResiduals( ...
                            historyDraw.A, historyDraw.C, longY, longX ...
                            , hasIntercept=hasIntercept ...
                            , order=meta.Order ...
                        );
                    end

                    this.SampleCounter = this.SampleCounter + 1;
                    %
                    Sigma = identificationDraw.Sigma;
                    Sigma = (Sigma + Sigma')/2;
                    P = chol(Sigma);
                    %
                    propertyValues = struct();
                    initCandidateCounter = this.CandidateCounter;
                    while (this.CandidateCounter - initCandidateCounter) < this.MaxCandidates
                        %
                        % Generate a candidate D based on the factor matrix P
                        sample.D = candidator(P);
                        this.CandidateCounter = this.CandidateCounter + 1;


                        if has.SHKRESP
                            propertyValues.SHKRESP = system.filterPulses(identificationDraw.A, sample.D);
                        end
                        %
                        if has.FEVD
                            propertyValues.FEVD = system.finiteFEVD(propertyValues.SHKRESP);
                        end
                        %
                        if has.SHKEST
                            % residuals = shocks * D => shocks = residuals / D
                            propertyValues.SHKEST = residuals / sample.D;
                        end
                        %
                        if has.SHKCONT
                            propertyValues.SHKCONT = system.contributionsShocks(historyDraw.A, sample.D, propertyValues.SHKEST);
                        end


                        success = testFunc(propertyValues);
                        if all(success)
                            return
                        end
                        %
                        % Try flipping signs of shocks one by one
                        numSuccess = nnz(success);
                        for i = 1 : numShocks
                            %
                            % Store copies of the current state for a possible
                            % reversal
                            numSuccess0 = numSuccess;
                            D0 = sample.D;
                            propertyValues0 = propertyValues;
                            %
                            %
                            % Flip sign for the i-th shock
                            % The cost of ANY abstraction here is extremely
                            % high. Inline everything for quasi-optimal
                            % performance.
                            sample.D(i, :) = -sample.D(i, :);
                            %
                            if has.SHKRESP
                                propertyValues.SHKRESP(:, :, i) = -propertyValues.SHKRESP(:, :, i);
                            end
                            %
                            if has.SHKEST
                                propertyValues.SHKEST(:, i) = -propertyValues.SHKEST(:, i);
                            end
                            %
                            %
                            % Evaluate the tests again with a flipped sign for
                            % the i-th shock
                            success = testFunc(propertyValues);
                            if all(success)
                                return
                            end
                            %
                            numSuccess = nnz(success);
                            %
                            % Keep the flipped sign only if it improves the number of
                            % successful tests; otherwise, revert to the
                            % original sign in the i-th shock
                            if numSuccess > numSuccess0
                                % Keep the flipped sign if improvement
                                % Do nothing
                            else
                                % Revert to the original sign if no improvement
                                numSuccess = numSuccess0;
                                sample.D = D0;
                                propertyValues = propertyValues0;
                            end
                        end
                    end
                end
            end%
            %
            this.Sampler = @samplerS;
            %]
        end%

        function addInstantZeros(this, inputs)
            if ~isempty(inputs.InstantZeros)
                this.InstantZeros = inputs.InstantZeros;
                return
            end
            if ~isempty(inputs.InstantZerosTable)
                this.InstantZeros = identifier.InstantZeros(inputs.InstantZerosTable);
                return
            end
        end%

        function testStrings = addSignRestrictions(this, model)
            tbl = this.IneqRestrictTable;
            if isempty(tbl)
                return
            end
            tablex.validateSignRestrictions(tbl, model=model);
            addTestStrings = identifier.testStringsFromIneqRestrictTable(tbl, model);
            addTestStrings = reshape(unique(string(addTestStrings), "stable"), [], 1);
            this.TestStrings = [this.TestStrings; addTestStrings];
        end%

    end

end

