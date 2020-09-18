%% Fluid domain HTF
classdef htf
    properties
        rho
        Cp
        mu
        k
        u %Average velocity
        D
        T_in %Inlet temperature
    end
    properties (Dependent)
        mdot
        Re
        Pr
    end
    methods
        function value = get.mdot(obj) %mass flow rate
            value = obj.u * pi() * (obj.D/2)^2 * obj.rho;
        end
        function value = get.Re(obj) %Reynolds number with diameter
            value = obj.rho * obj.u * obj.D / obj.mu;
        end
        function value = get.Pr(obj) %Prandtl number
            value = obj.Cp * obj.mu / obj.k;
        end
    end
end

