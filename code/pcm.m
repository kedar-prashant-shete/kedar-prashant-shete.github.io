%% Fluid domain PCM
classdef pcm
    properties
        rho % all properties are of liquid pcm as that's where the convection happens.
        Cp
        mu
        k 
        L
        beta
        T_sol
        T_liq
        D_o % outer diameter of container
        D_i
        u
        T_mci %Average wall temperature for Gr
        g % gravitational acceleration
    end
    properties (Dependent)
        M %total mass of pcm
        nu
        T_mean
        D
        Re
        Pr
        Gr
        Ra
    end
    methods
        function value = get.M(obj) %Kinematic viscosity
            value = pi()*((obj.D_o^2 - obj.D_i^2)/4)*obj.L*obj.rho;
        end
        function value = get.nu(obj) %Kinematic viscosity
            value = obj.mu/obj.rho;
        end
        function value = get.T_mean(obj) %Melting Temperature
            value = (obj.T_sol + obj.T_liq)/2;
        end
        function value = get.D(obj) %Characteristic length
            value = (obj.D_o - obj.D_i);
        end
        function value = get.Re(obj) %Reynolds number with diameter
            value = obj.rho * obj.u * obj.D_t / obj.mu;
        end
        function value = get.Pr(obj) %Prandtl number
            value = obj.Cp * obj.mu / obj.k;
        end
        function value = get.Gr(obj) %Grashof number
            value = obj.g * obj.beta * obj.D^3 * (obj.T_mci - obj.T_mean)/obj.nu^2;
        end
        function value = get.Ra(obj) %Rayleigh number
            value = obj.Gr * obj.Pr;
        end
    end
end

