
classdef InstantZeros ...
    < base.Identifier ...
    & base.identifier.InstantMixin

    properties
        RestrictionsTable = []
        RestrictionsMatrix (:, :) double = []
    end


    properties (Dependent)
        NumRestrictions
    end


    methods
        function this = InstantZeros(options)
            arguments
                options.FileName (1, 1) string = ""
                options.Table table = []
                options.Matrix (:, :) double = []
            end
            %
            if options.FileName ~= ""
                this.RestrictionsTable = tablex.readtable(options.FileName);
                return
            end
            %
            if ~isempty(options.Table)
                this.RestrictionsTable = options.Table;
                return
            end
            %
            if ~isempty(options.Matrix)
                this.RestrictionsMatrix = options.Matrix;
                return
            end
        end%

        function populateRestrictionsMatrix(this)
            if isempty(this.RestrictionsTable)
                return
            end
            R = this.RestrictionsTable{this.SeparableEndogenousNames, this.SeparableShockNames};
            %
            % Transpose the restriction matrix so that the rows correspond to
            % shocks and columns to endogenous variables; this is consistent
            % with the row-oriented VAR system representation in BEAR
            this.RestrictionsMatrix = transpose(R);
        end%

        function choleskator = getCholeskator(this)
            choleskator = @chol;
        end%

        function candidator = getCandidator(this)
            if this.NumRestrictions > 0
                R = this.RestrictionsMatrix;
                candidator = @(P) base.identifier.candidateFromFactorConstrained(P, R);
            else
                candidator = @base.identifier.candidateFromFactorUnconstrained;
            end
        end%

        function whenPairedWithModel(this, modelS)
            meta = modelS.Meta;
            this.populateSeparableNames(meta);
            this.checkTable(this.RestrictionsTable, meta);
            this.populateRestrictionsMatrix();
        end%
    end


    methods
        function n = get.NumRestrictions(this)
            n = nnz(~isnan(this.RestrictionsMatrix));
        end%
    end


    methods (Static)
        function checkTable(restrictionsTable, meta)
            arguments
                restrictionsTable (:, :) table
                meta (1, 1) base.Meta
            end
            if isempty(restrictionsTable)
                return
            end
            %
            base.identifier.checkEndogenousAndShocksInTable(restrictionsTable, meta);
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

