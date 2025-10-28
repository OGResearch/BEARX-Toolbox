classdef Meta < factorTwostep.Meta

    properties (Constant, Access=private)
        % Fixed single reducible block name
        FIXED_BLOCK_NAME (1,1) string = "main"
        % Fixed block type
        FIXED_BLOCK_TYPE (1,1) string = "blocks"
    end

    methods
        function this = update(this, options)
            arguments
                options.endogenousConcepts (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) datetime {mustBeNonempty}

                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.units (1, :) string = ""
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = true
                options.shockConcepts (1, :) string = string.empty(1, 0)
                options.shocks (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0

                % User may only supply reducibleNames and integer numFactors
                options.reducibleNames (1, :) string = string.empty(1, 0)
                options.numFactors (1,1) double {mustBePositive, mustBeInteger} = 1
            end

            % Fixed values
            fixedBlockName = this.FIXED_BLOCK_NAME;
            fixedBlockType = this.FIXED_BLOCK_TYPE;

            % Convert scalar integer into struct required by superclass
            numFactorsStruct = struct(fixedBlockName, options.numFactors);

            % Call superclass update with forced values
            this = update@factorTwostep.Meta(this, struct( ...
                'endogenousConcepts', options.endogenousConcepts, ...
                'estimationSpan', options.estimationSpan, ...
                'exogenousNames', options.exogenousNames, ...
                'order', options.order, ...
                'intercept', options.intercept, ...
                'shockConcepts', options.shockConcepts, ...
                'shocks', options.shocks, ...
                'identificationHorizon', options.identificationHorizon, ...
                'reducibleNames', options.reducibleNames, ...
                'reducibleBlocks', repmat(fixedBlockName, size(options.reducibleNames)), ...
                'blockType', fixedBlockType, ...
                'numFactors', numFactorsStruct ...
            ));
        end
    end
end