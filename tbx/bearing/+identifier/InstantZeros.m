
classdef InstantZeros ...
    < identifier.Base ...
    & identifier.InstantMixin

    properties
        Table table = table.empty()
        Matrix (:, :) double = []
    end


    properties (Dependent)
        NumRestrictions
    end


    methods
        function this = InstantZeros(options)
            arguments
                options.FileName (1, 1) string = ""
                options.Table table = table.empty()
                options.Matrix (:, :) double = []
            end
            %
            if options.FileName ~= ""
                this.Table = tablex.readtable(options.FileName);
                return
            end
            %
            if ~isempty(options.Table)
                this.Table = options.Table;
                return
            end
            %
            if ~isempty(options.Matrix)
                this.Matrix = options.Matrix;
                return
            end
        end%

        function populateRestrictionsMatrix(this)
            if isempty(this.Table)
                return
            end
            R = this.Table{this.SeparableEndogenousNames, this.SeparableShockNames};
            %
            % Transpose the restriction matrix so that the rows correspond to
            % shocks and columns to endogenous variables; this is consistent
            % with the row-oriented VAR system representation in BEAR
            this.Matrix = transpose(R);
        end%

        function choleskator = getCholeskator(this)
            choleskator = @chol;
        end%

        function candidator = getCandidator(this)
            if this.NumRestrictions > 0
                R = this.Matrix;
                candidator = @(P) identifier.candidateFromFactorConstrained(P, R);
            else
                candidator = @identifier.candidateFromFactorUnconstrained;
            end
        end%

        function whenPairedWithModel(this, modelS)
            meta = modelS.Meta;
            this.populateSeparableNames(meta);
            this.checkTable(this.Table, meta);
            this.populateRestrictionsMatrix();
        end%
    end


    methods
        function n = get.NumRestrictions(this)
            n = nnz(~isnan(this.Matrix));
        end%
    end


    methods (Static)
        function checkTable(restrictionsTable, meta)
            if isempty(restrictionsTable)
                return
            end
            %
            identifier.checkEndogenousAndShocksInTable(restrictionsTable, meta);
            %
            % Table entries must be either 0 or NaN
            R = restrictionsTable{:, :};
            if ~all(isnan(R(:)) | R(:) == 0)
                error("Exact zero restriction table entries must be either 0 or NaN.");
            end
            %
            % The # of exact zero restrictions is limited by the # of variables
            numVariables = size(R, 1);
            numRestrictions = nnz(R == 0);
            maxNumRestrictions = numVariables * (numVariables - 1) / 2 - 1;
            if numRestrictions > maxNumRestrictions
                error( ...
                    "Too many exact zero restrictions for the number of variables; max %g allowed." ...
                    , maxNumRestrictions ...
                );
            end
        end%
    end

end

