clear all;
%% --Write data to file for GNUPlot---
x = linspace(-pi(),pi(),100);
dat1 = [x;sin(x);cos(x);tan(x)]; dat1_name = 'data1'; %name and vector containing data
datformat = repmat('%.16e ',1,size(dat1,1));
fid = fopen([dat1_name,'.txt'] ,'w');
fprintf(fid,[datformat '\n'],dat1); clear datformat; fclose(fid);

%% ---GNUPlot---
fid = fopen([dat1_name,'.gp'],'w');
fprintf(fid,['set encoding utf8\n','set terminal epslatex color\n','set output "', dat1_name, '.tex"\n']);
fprintf(fid,['set xlabel "$x$"\n']);
fprintf(fid,['set ylabel "$f(x)$"\n']);
fprintf(fid,['set key top left\n']); % legend position
fprintf(fid,['set ytics nomirror\n','set y2tics nomirror\n','set autoscale y\n','set autoscale y2\n']); %if there is a secondary y axis
%Plot statements
fprintf(fid,['plot ']);
fprintf(fid,['"' dat1_name '.txt" using 1:2 with lines dt 1 lc 1 lw 2 title "$sin(x)$", ']);
fprintf(fid,['"' dat1_name '.txt" using 1:3 with lines dt 2 lc 2 lw 2 title "$cos(x)$", ']);
fprintf(fid,['"' dat1_name '.txt" using 1:4 with lines dt 1 lc 3 lw 2 axes x1y2 title "$tan(x)$"\n']);
%end Plot statements
fprintf(fid,['exit']); fclose(fid); %close file and finish plot

command = ['gnuplot ',dat1_name,'.gp']; [status,cmdout] = system(command,'-echo'); %run gnuplot
delete([dat1_name,'.txt'], [dat1_name,'.gp']); %delete intermediate files