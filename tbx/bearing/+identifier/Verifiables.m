
classdef Verifiables < identifier.Base

    properties (Constant)
        DEFAULT_MAX_CANDIDATES = 100
        DEFAULT_FLIP_SIGN = true
    end


    properties
        InstantZeros (1, 1) identifier.InstantZeros
        VerifiableTests identifier.VerifiableTests
        MaxCandidates (1, 1) double {mustBePositive} = identifier.Verifiables.DEFAULT_MAX_CANDIDATES
    end


    methods
        function this = Verifiables(options)
            arguments
                options.TestStrings (:, 1) string = string.empty(0, 1)
                options.InstantZeros = [] % identifier.InstantZeros()
                options.InstantZerosTable = []
                options.SignRestrictionsTable = []
                options.MaxCandidates (1, 1) double = identifier.Verifiables.DEFAULT_MAX_CANDIDATES
                options.FlipSign (1, 1) logical = identifier.Verifiables.DEFAULT_FLIP_SIGN
                options.ShortCircuit (1, 1) logical = true
            end
            %
            testStrings = options.TestStrings;
            this.addInstantZeros(options);
            addTests = this.addSignRestrictions(options);
            testStrings = [testStrings; addTests];
            this.VerifiableTests = identifier.VerifiableTests(testStrings);
            this.MaxCandidates = options.MaxCandidates;
        end%

        function whenPairedWithModel(this, modelS)
            arguments
                this
                modelS (1, 1) model.Structural
            end
            if ~isempty(this.InstantZeros)
                this.InstantZeros.whenPairedWithModel(modelS);
            end
        end%

        function initializeSampler(this, modelS)
            %[
            arguments
                this
                modelS (1, 1) model.Structural
            end
            %
            reducedFormSampler = modelS.ReducedForm.Estimator.Sampler;
            identificationDrawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
            historyDrawer = modelS.ReducedForm.Estimator.HistoryDrawer;
            meta = modelS.Meta;
            numShocks = modelS.Meta.NumShockNames;
            order = meta.Order;
            hasIntercept = meta.HasIntercept;
            longYXZ = modelS.getLongYXZ();
            %
            [testFunc, occurrence] = this.VerifiableTests.buildTestEnvironment(modelS.Meta);
            has = struct();
            for n = ["SHKRESP", "FEVD", "SHKEST", "SHKCONT"]
                has.(n) = isfield(occurrence, n);
            end
            %
            this.InstantZeros.initialize(modelS);
            candidator = this.InstantZeros.getCandidator();
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
                            historyDraw.A, historyDraw.C, longYXZ ...
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
                        numSuccess = nnz(success);
                        %
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
                            numSuccess = nnz(success);
                            % Keep the flipped sign only if it improves the number of
                            % successful tests; otherwise, revert to the
                            % original sign in the i-th shock
                            if numSuccess <= numSuccess0
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

        function addInstantZeros(this, options)
            if ~isempty(options.InstantZeros)
                this.InstantZeros = options.InstantZeros;
                return
            end
            if ~isempty(options.InstantZerosTable)
                this.InstantZeros = identifier.InstantZeros(options.InstantZerosTable);
                return
            end
        end%

        function addTestStrings = addSignRestrictions(this, options)
            tbl = options.SignRestrictionsTable;
            if isempty(tbl)
                addTestStrings = string.empty(0, 1);
                return
            end
            addTestStrings = identifier.SignRestrictions.toVerifiableTestStrings(tbl);
        end%

    end

end

