
classdef Structural < base.Structural

    methods
        function this = Structural(options)
            arguments
                options.reducedForm (1, 1) cross.ReducedForm
                options.identifier (1, 1) cross.Identifier
            end
            this.ReducedForm = options.reducedForm;
            this.Identifier = options.identifier;
            this.Identifier.whenPairedWithModel(this);
        end%
    end

end

