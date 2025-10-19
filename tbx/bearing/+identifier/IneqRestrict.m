
classdef IneqRestrict ...
    < identifier.Verifiables

    methods
        function this = IneqRestrict(options)
            arguments
                options.FileName (1, :) string = ""
            end
            table = tablex.readIneqRestrict(options.FileName);
            this@identifier.Verifiables( ...
                IneqRestrictTable=table ...
            );
        end%
    end

end

