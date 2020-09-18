%%Simulation pre-processing script for calculating design/operational
%%parameters and dimensionless numbers
clear all
%% Setting up values of properties to vary
%number of property values to try
np = zeros(4,1); %array of number of values of each property to try. Array size is number of properties
pNames = ["\multicolumn{1}{c}{$u_f$} & \multicolumn{1}{c}{$k_f$} & \multicolumn{1}{c}{$k_p$} & \multicolumn{1}{c}{$T_{in}$} & \multicolumn{1}{c}{$Re_f$} & \multicolumn{1}{c}{$Pr_f$} & \multicolumn{1}{c}{$Pr_p$} & \multicolumn{1}{c}{$Gr_p$} \\"];
np(1) = 2; htf_u = linspace(0.01,0.01*14,np(1));% STarting Re is about 150, so about 14 times would be ~2100
np(2) = 2; htf_k = linspace(0.1,0.8,np(2));
np(3) = 4; pcm_k = linspace(0.1,1,np(3));
np(4) = 4; pcm_Tmci = linspace(308.1250 + 2,308.1250 + 16,np(4));

pcase1(1:np(1),1:np(2),1:np(3),1:np(4)) = pcase(1); %see class pcase.m

%% Generating different values of Re_f, Gr_p, Ra_p and Pr_p and Pr_f
for iu=1:np(1)
    for ihk = 1:np(2)
        for ipk = 1:np(3)
            for ipT = 1:np(4)
                %Constant properties
                %HTF properties
                pcase1(iu,ihk,ipk,ipT).h_rho = 998.2;
                pcase1(iu,ihk,ipk,ipT).h_Cp = 4182;        
                pcase1(iu,ihk,ipk,ipT).h_mu = 0.001003;
                pcase1(iu,ihk,ipk,ipT).h_D = 0.015;
                %PCM properties
                pcase1(iu,ihk,ipk,ipT).p_rho = 820;
                pcase1(iu,ihk,ipk,ipT).p_Cp = 2100;
                pcase1(iu,ihk,ipk,ipT).p_mu = 0.002706;
                pcase1(iu,ihk,ipk,ipT).p_L = 157000;
                pcase1(iu,ihk,ipk,ipT).p_beta = 0.001;
                pcase1(iu,ihk,ipk,ipT).p_Tsol = 308.1;
                pcase1(iu,ihk,ipk,ipT).p_Tliq = 308.15;
                pcase1(iu,ihk,ipk,ipT).p_Do = 0.044;
                pcase1(iu,ihk,ipk,ipT).p_Di = 0.020;
                pcase1(iu,ihk,ipk,ipT).p_u = 0;
                
                pcase1(iu,ihk,ipk,ipT).g = 9.81; %Gravitational accleration 
                
                %Changing Properties
                pcase1(iu,ihk,ipk,ipT).h_k = htf_k(ihk); 
                pcase1(iu,ihk,ipk,ipT).h_u = htf_u(iu);
                
                pcase1(iu,ihk,ipk,ipT).h_Tin = pcm_Tmci(ipT);
                pcase1(iu,ihk,ipk,ipT).p_k = pcm_k(ipk);
            end
        end
    end
end

%% Writing tex file
fid = fopen('preproc.tex','w');
fprintf(fid,'%s',["\begin{tabular}{"]); 
for i=1:2*numel(np) fprintf(fid,'r'); end 
fprintf(fid,'}\n');
fprintf(fid,'%s\n',pNames);
fprintf(fid,'%s\n',["\hline"]);
for iu=[1 np(1)]
    for ihk = [1 np(2)]
        for ipk = [1 np(3)]
            for ipT = [1 np(4)]
                %Print different values of properties. Editing number of
                %properties has to be done manually
                fprintf(fid,'\n ');
                fprintf(fid,' %g &',pcase1(iu,ihk,ipk,ipT).h_u);
                fprintf(fid,' %g &',pcase1(iu,ihk,ipk,ipT).h_k);
                fprintf(fid,' %g &',pcase1(iu,ihk,ipk,ipT).p_k);
                fprintf(fid,' %g &',pcase1(iu,ihk,ipk,ipT).h_Tin);
                fprintf(fid,' %g &',round(pcase1(iu,ihk,ipk,ipT).h_Re));
                fprintf(fid,' %g &',round(pcase1(iu,ihk,ipk,ipT).h_Pr));
                fprintf(fid,' %g &',round(pcase1(iu,ihk,ipk,ipT).p_Pr));
                fprintf(fid,' %g ',round(pcase1(iu,ihk,ipk,ipT).p_Gr));
                fprintf(fid,'%s',[" \\"]);
            end
        end
    end
end
fprintf(fid,'\n%s',["\end{tabular}"]);
fclose(fid);

%List of non-dimensional numbers
fid = fopen('preproclist.tex','w');
fprintf(fid,'%s',["\begin{tabular}{"]); 
for i=1:2*numel(np) fprintf(fid,'r'); end 
fprintf(fid,'}\n');
fprintf(fid,'%s\n',"\multicolumn{2}{c}{$Re_f$} & \multicolumn{2}{c}{$Pr_f$} & \multicolumn{2}{c}{$Pr_p$} & \multicolumn{2}{c}{$Gr_p$} \\");
fprintf(fid,'%s\n',["\hline"]);
for i=1:max(np(:))
    %Print numbers and name
    fprintf(fid,'\n ');
    if(i<=np(1)) fprintf(fid,'$Re_f%g$ & %g &',i,round(pcase1(i,1,1,1).h_Re)); else fprintf(fid,'- & - &'); end
    if(i<=np(2)) fprintf(fid,'$Pr_f%g$ & %g &',i,round(pcase1(1,i,1,1).h_Pr)); else fprintf(fid,'- & - &'); end
    if(i<=np(3)) fprintf(fid,'$Pr_p%g$ & %g &',i,round(pcase1(1,1,i,1).p_Pr)); else fprintf(fid,'- & - &'); end
    if(i<=np(4)) fprintf(fid,'$Gr_p%g$ & %g ',i,round(pcase1(1,1,1,i).p_Gr)); else fprintf(fid,'- & - &'); end
    fprintf(fid,'%s',[" \\"]);
end
%fprintf(fid,'%s\n',["\hline"]);
fprintf(fid,'\n%s',["\end{tabular}"]);
fclose(fid);



                    
