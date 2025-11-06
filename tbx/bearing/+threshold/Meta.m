
% model.Meta  Meta information about reduced-form and structural models

classdef Meta < base.Meta

    % Reduced-form model meta information
    properties (SetAccess=protected)
        %
        % ThresholdVarName  Name of variable identifying the regime
        ThresholdVarName (1, 1) string 
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
                options.shockNames (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
        
                options.thresholdVarName (1, :) string = string.empty(1, 0)
            end

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

            this.ThresholdVarName = options.thresholdVarName;

            this.populatePseudoDependents();
            this.populateSeparablePseudoDependents();
            this.catchDuplicateNames();

        end% 

    end
end

