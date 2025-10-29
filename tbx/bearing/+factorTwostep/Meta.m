
% model.Meta  Meta information about reduced-form and structural models

classdef Meta < base.Meta

    % Reduced-form model meta information
    properties (SetAccess=protected)
        %
        % ReducibleNames  Names of reducible variables in factor models
        ReducibleNames (1, :) string 

        % ReducibleBlocks  Names of blocks the corresponding reducibles
        % belong to
        ReducibleBlocks (1, :) string

        % Blocktype for FAVARS
        BlockType (1,:) string

        % NumFactors  Number of factors to be formed from reducibles
        NumFactors struct 

    end


    properties (Dependent)
    
        FactorNames
        NumFactorNames
        NumReducibleNames

    end


    methods        
    
        function this = update(this, options)

            arguments
                this
                options.endogenousNames (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) datetime {mustBeNonempty}
        
                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = true
                options.shockConcepts (1, :) string = string.empty(1, 0)
                options.shockNames (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
        
                options.reducibleNames (1, :) string = string.empty(1, 0)
                options.reducibleBlocks (1, :) string = string.empty(1, 0)
                options.blockType (1,1) string {mustBeMember(options.blockType, ["blocks", "slowfast"])} = "blocks"
                options.numFactors struct = struct()
            end%

            this.EndogenousConcepts = options.endogenousNames;
            this.ShortSpan = datex.span(options.estimationSpan(1), options.estimationSpan(end));
            if isempty(this.ShortSpan)
                error("Estimation span must be non-empty");
            end
            this.ExogenousNames = options.exogenousNames;
            this.ShockConcepts = options.shockNames;
            this.HasIntercept = options.intercept;
            this.Order = options.order;
            this.IdentificationHorizon = options.identificationHorizon;
    
            this.ReducibleNames = options.reducibleNames;
            this.ReducibleBlocks = options.reducibleBlocks;
            this.BlockType = options.blockType; 
            this.NumFactors = options.numFactors;
    
            this.populatePseudoDependents();
            this.populateSeparablePseudoDependents();
            this.catchDuplicateNames();

        end%


        function populatePseudoDependents(this)
            this.NumUnits = 1;
            %
            this.EndogenousNames = this.EndogenousConcepts;
            %
            this.ResidualConcepts = [this.FactorNames this.EndogenousConcepts] + this.SEPARATOR + this.ResidualSuffix;
            this.ResidualNames = this.ResidualConcepts;
            %
            if isempty(this.ShockConcepts) || isequal(this.ShockConcepts, "") || all(ismissing(this.ShockConcepts))
                this.ShockConcepts = this.EndogenousConcepts + this.SEPARATOR + this.ShockSuffix;
            end
            this.ShockNames = this.ShockConcepts;
        end%
    

    end

    methods (Access=protected)x0

        function catchDuplicateNames(this)
            allNames = [ ...
                this.EndogenousNames, ...
                this.ExogenousNames, ...
                this.ReducibleNames, ...
                this.ShockNames ...
            ];
            if numel(allNames) ~= numel(unique(allNames))
                nonuniques = textual.nonunique(allNames);
                error("Duplicate model name(s): " + join(nonuniques, ", "));
            end
        end%


    end


    % Reduced-form dependent properties
    methods

        function out = get.FactorNames(this)
            out = strings(1,0);
            bnames = sort(unique(this.ReducibleBlocks));
            for ii = 1:numel(bnames)
                out = [out, bnames(ii) + "_Factor" + string(1:this.NumFactors.(bnames(ii)))];
            end
        end%

        function num = get.NumReducibleNames(this)
            num = numel(this.ReducibleNames);
        end%

        function num = get.NumFactorNames(this)
            num = numel(this.FactorNames);
        end%


    end

end

