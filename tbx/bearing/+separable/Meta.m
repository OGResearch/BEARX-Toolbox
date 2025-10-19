
classdef Meta < cross.Meta

    methods
        function populateSeparablePseudoDependents(this)
            this.NumSeparableUnits = this.NumUnits;
            this.SeparableEndogenousNames = this.EndogenousConcepts;
            this.SeparableResidualNames = this.ResidualConcepts;
            this.SeparableShockNames = this.ShockConcepts;
        end%
    end

end

