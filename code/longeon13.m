clear all;
u_f = linspace(0.01,0.01*14,2);
k_f = linspace(0.1,0.8,2);
k_p = linspace(0.1,1,4);
T_in = linspace(308.1250 + 2,308.1250 + 16,4);
tsteps = 1200; %10 sec timestep files
sumfid = fopen('parameters.txt','w');
fprintf(sumfid,'u_f \t\t k_f \t\t k_p \t\t T_in \n');
caseflag = 0;
nprocsmax = 6; %Maximum number of processes
for iu=1:numel(u_f)
    for ikf=1:numel(k_f)
        for ikp=1:numel(k_p)
            for iTin=1:numel(T_in)
                %Print current parameters to parameters.txt file
                fprintf(sumfid,'\n%g \t\t %g \t\t %g \t\t %g',u_f(iu),k_f(ikf),k_p(ikp),T_in(iTin));
                
                directory = ['Re' num2str(iu) 'Prf' num2str(ikf) 'Prp' num2str(ikp) 'Gr' num2str(iTin)];
                if exist(directory,'dir')
                    cd(directory);
                    dirc = dir("*.dat"); %create list of data files
                    if (numel(dirc)>=tsteps) 
						cd .. %IMPORTANT to return back to home directory
						continue; %stop execution if timesteps are done
                    else
						datevec = zeros(numel(dirc),1);
						for i=1:numel(dirc) datevec(i) = dirc(i).datenum; end %get datenum to find most recent file
						[m,i] = max(datevec);
						datfile = dirc(i).name;
                    
						dirc = dir("*.cas"); %create list of data files
						datevec = zeros(numel(dirc),1);
						for i=1:numel(dirc) datevec(i) = dirc(i).datenum; end %get datenum to find most recent file
						[m,i] = max(datevec);
						casfile = dirc(i).name;
                    
						fid = fopen("longeon13continue.jou",'w');
						fprintf(fid,"; read in case and data in the current directory\n");
						command = convertCharsToStrings(['\n/file/read-case ' casfile]);
						fprintf(fid,command);
						command = convertCharsToStrings(['\n/file/read-data ' datfile]);
						fprintf(fid,command);
						fprintf(fid,"\n; iterate");
						temp = abs(sscanf(datfile,'%d',[1 2]));
						command = convertCharsToStrings(['\n/solve/dual-time-iterate ' num2str(1200000 - temp(2)*100) ' 200']);
						fprintf(fid,command);
						fprintf(fid,"\nexit");
						fclose(fid);
                    
						if (caseflag>=nprocsmax) %Set maximum number of processes
							command = ['fluent 2ddp -g -hidden -i longeon13continue.jou']; [status,cmdout] = system(command,'-echo');
							caseflag = 0;
						else
							command = ['fluent 2ddp -g -hidden -i longeon13continue.jou &']; [status,cmdout] = system(command,'-echo');
							caseflag = caseflag +1;
						end
					end
                    
                else
					command = ['mkdir ' directory]; [status,cmdout] = system(command,'-echo');
					command = ['copy longeon13.jou ' directory]; [status,cmdout] = system(command,'-echo');
					command = ['copy longeon13.cas ' directory]; [status,cmdout] = system(command,'-echo');
					cd(directory);
					
					%k_f
					s1 = '/define/materials/change-create water-liquid water-liquid no no yes constant ';
					s2 = ' no no no no no no no';
					command = ['sed421 -i "s;' s1 '.*' s2 ';' s1 num2str(k_f(ikf)) s2 ';" longeon13.jou' ];
					[status,cmdout] = system(command,'-echo');
				
					%k_p
					s1 = '/define/materials/change-create rt35-rubitherm rt35-rubitherm no no yes constant ';
					s2 = ' no no no no no no no';
					command = ['sed421 -i "s;' s1 '.*' s2 ';' s1 num2str(k_p(ikp)) s2 ';" longeon13.jou' ];
					[status,cmdout] = system(command,'-echo');
					
					%u_f and T_in
					s1 = '/define/boundary-conditions/velocity-inlet sf_inlet no no yes yes no ';
					s2 = ' no 0 no ';
					command = ['sed421 -i "s;' s1 '.*' s2 '.*' ';' s1 num2str(u_f(iu)) s2 num2str(T_in(iTin)) ';" longeon13.jou' ];
					[status,cmdout] = system(command,'-echo');
					
					%Run Case
					if (caseflag>=nprocsmax) %Set maximum number of processes
						command = ['fluent 2ddp -g -i longeon13.jou']; [status,cmdout] = system(command,'-echo');
						caseflag = 0;
					else
						command = ['fluent 2ddp -g -i longeon13.jou &']; [status,cmdout] = system(command,'-echo');
						caseflag = caseflag +1;
					end
                end
                cd .. %IMPORTANT to return back to home directory

            %fluent 2ddp -hidden -i journal.jou
            end
        end
    end
end
fclose(sumfid);