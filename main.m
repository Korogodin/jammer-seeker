try close(h_fig_main.fig_main) % Закрытие старого окна
catch
end
clc
clear 
close all

globals;

if (ispc) % if system is Win
    h_fig_main = guihandles(fig_main);
elseif (isunix)
    h_fig_main = guihandles(fig_main);
end

Tmod = 0.0012;
Tcorr = 0.001;
Fd = 44.2e6;
Td = 1/Fd;
Nmod = fix(Tmod/Td);
Ncorr = fix(Tcorr/Td);
c_light = 3e8;
Jam_FreqRate = 1e12; % Hz/s
Jam_FreqDev = 10e6;
f0_if = 10.8e6; % promeg
f0 = 1575.42e6; % carrier

sigma_n = 3;
P_jammer_dBm = -15; %dBm
N0 = -200; %dBW/Hz

load_Map('MPEI'); % Open and draw map
load_rec_points( 1 ); % Draw receiver-points

set(h_fig_main.fig_main,'WindowButtonDownFcn',@MapClick)




% hF = figure(hF + 1);
% plot(t_jam*1e6, RecPoi(1).Signal, ...
%         t_jam*1e6, RecPoi(2).Signal, ...
%         t_jam*1e6, RecPoi(3).Signal)
% xlabel('t, \mu{s}')
