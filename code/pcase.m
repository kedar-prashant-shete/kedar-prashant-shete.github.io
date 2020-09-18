%Class that has htf and pcm properties and non-dimensional numbers,
%basically case preprocessing class
classdef pcase
    properties
        tsteps = 1;
        g = 9.81; %Gravitational accleration
        
        %%HTF creation and properties
        h_rho ;
        h_Cp ;        
        h_mu ;
        h_k ;
        h_u ;
        h_D ;
        h_Tin ;
        %These are here just for completeness, they are not used in the simulation and do not have physical values
        h_beta ;
        h_L ;
        h_Tsol ;
        h_Tliq ;
        
        %%PCM creation and properties
        p_rho ;
        p_Cp ;
        p_mu ;
        p_k ;
        p_lc ;
        p_beta ;
        p_Tsol ;
        p_Tliq ;
        p_Do ;
        p_Di ;
        p_u ;
        p_L ; %Latent heat capacity
        
        %Time series
        h_Tf ; %Mean HTF Temperature, volume average
        h_wflux ; %Wall heat flux htf tube wall
        p_tempD; %
        p_tempAvg;
        p_meltfrac;
        p_Tmci; %Mean surface temperature of PCM container, which is also outer surface of HTF tube
        p_wflux ; % Wall heat flux pcm tube wall
    end
    properties(Dependent)
        %Htf properties
        h_mdot
        h_Re
        h_Pr
        
        %Pcm properties
        p_M %total mass of pcm
        p_alpha
        p_nu
        p_Tmean
        p_D
        p_Re
        p_Pr
        p_Gr
        p_Ra
    end
    
    methods
        function obj = pcase(arg) %class constructor
            if(arg>0)
                obj.tsteps = arg; %set number of time steps
                obj.p_tempD = zeros(arg,2);
                obj.p_tempAvg = zeros(arg,2);
                obj.p_meltfrac = zeros(arg,2);
                obj.p_Tmci = zeros(arg,2);
                obj.h_Tf = zeros(arg,2);
                obj.h_wflux = zeros(arg,2);
                obj.p_wflux = zeros(arg,2);
            end
        end
        
        %Htf dependent variables
        function value = get.h_mdot(obj) %mass flow rate
            value = obj.h_u * pi() * (obj.h_D/2)^2 * obj.h_rho;
        end
        function value = get.h_Re(obj) %Reynolds number with diameter
            value = obj.h_rho * obj.h_u * obj.h_D / obj.h_mu;
        end
        function value = get.h_Pr(obj) %Prandtl number
            value = obj.h_Cp * obj.h_mu / obj.h_k;
        end
        
        %Pcm dependent variables
        function value = get.p_M(obj) %Mass of PCM
            value = pi()*((obj.p_Do^2 - obj.p_Di^2)/4)*obj.p_lc*obj.p_rho;
        end
        function value = get.p_alpha(obj) %Thermal diffusivity
            value = obj.p_k/(obj.p_rho * obj.p_Cp);
        end
        function value = get.p_nu(obj) %Kinematic viscosity
            value = obj.p_mu/obj.p_rho;
        end
        function value = get.p_Tmean(obj) %Melting Temperature
            value = (obj.p_Tsol + obj.p_Tliq)/2;
        end
        function value = get.p_D(obj) %Characteristic length
            value = (obj.p_Do - obj.p_Di);
        end
        function value = get.p_Re(obj) %Reynolds number with diameter
            value = obj.p_rho * obj.p_u * obj.p_D / obj.p_mu;
        end
        function value = get.p_Pr(obj) %Prandtl number
            value = obj.p_Cp * obj.p_mu / obj.p_k;
        end
        function value = get.p_Gr(obj) % Nominal Grashof number
            value = obj.g * obj.p_beta * obj.p_D^3 * (obj.h_Tin - obj.p_Tmean)/obj.p_nu^2;
        end
        function value = get.p_Ra(obj) %Rayleigh number
            value = obj.p_Gr * obj.p_Pr;
        end
    end
end
