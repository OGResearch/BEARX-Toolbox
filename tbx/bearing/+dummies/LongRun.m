
classdef (CaseInsensitiveProperties=true) LongRun ...
    < dummies.Base

    properties
        Lambda (1, 1) double = 1 %lambda8 in BEAR5, long run prior tightness
        Constraints (:, :)
    end


    methods

        function this = LongRun(varargin)
            if nargin == 0
                return
            end
            this.update(varargin{:});
        end%


        function update(this, options)
            arguments
                this
                options.Lambda (1, 1) double = 1
                options.Constraints (:, :)
            end
            this.Lambda = options.Lambda;
            this.Constraints = options.Constraints;
        end%


        function H = prepareConstraints(this)
            H = this.Constraints;
            if istable(H)
                H = H{:,:};
            end
            H = double(H);
            rankH = rank(H);
            sizeH = size(H, 1);
            if rankH < sizeH
                error("Long-run prior matrix is singular: rank=%g, size=%g.", rankH, sizeH);
            end
        end%


        function dummiesYLX = generate(this, meta, longYX)
            numY = meta.NumEndogenousNames;
            numX = double(meta.HasIntercept) + meta.NumExogenousNames;
            order = meta.Order;
            lambda = this.Lambda;
            %
            [longY] = longYX{:};
            initY = longY(1:order, :);
            %
            H = this.prepareConstraints();
            invH = inv(H);
            meanY = transpose(mean(initY, 1));
            dummiesY = [];
            for ii = 1 : numY
                add = (H(ii, :) * meanY / lambda) * invH(:, ii);
                dummiesY = [dummiesY, add];
            end
            dummiesL = repmat(dummiesY, 1, order);
            dummiesX = zeros(numY, numX);
            dummiesLX = [dummiesL, dummiesX];
            %
            dummiesYLX = {dummiesY, dummiesLX};
        end%
    end

end

