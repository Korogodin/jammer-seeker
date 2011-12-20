function MapClick(hObject,~)

globals;
pos=get(hObject,'CurrentPoint');
pos_a = get(h_fig_main.axes_Map,'Position');
X = (pos(1) - pos_a(1))*x_masht - Image_x_0_m;
Y = (pos(2) - pos_a(2))*y_masht - Image_y_0_m;
% disp(['You clicked X:',num2str(X),', Y:',num2str(Y)]);

if (MapBounds(1) > X)||(MapBounds(2) < X)||(MapBounds(3) > Y)||(MapBounds(4) < Y)
    return
end

Jammer.X = X;
Jammer.Y = Y;
Jammer.Z = 0;

hold(h_fig_main.axes_Map, 'on');
plot(h_fig_main.axes_Map, Jammer.X, Jammer.Y, '*', 'MarkerSize', 10)
hold(h_fig_main.axes_Map, 'off');


t_jam = Td:Td:(Nmod*Td);

dF_jam = mod(Jam_FreqRate*t_jam, Jam_FreqDev) - Jam_FreqDev/2;
Phase_jam = nan(1, Nmod);
Phase_jam(1) = 0;
for jj = 2:Nmod
    Phase_jam(jj) = Phase_jam(jj-1) + 2*pi*(dF_jam(jj-1) + f0_if)*Td;
end
Signal_jam = cos(Phase_jam);

load filter_NII.mat

DoFilter = 1;
for n_rec = 1:N_RecPoi
    RecPoi(n_rec).R = sqrt ( (Jammer.X -  RecPoi(n_rec).X)^2 + ...
                (Jammer.Y -  RecPoi(n_rec).Y)^2 + ...
                (Jammer.Z -  RecPoi(n_rec).Z)^2 );
    t_rec = t_jam - RecPoi(n_rec).R/c_light;        
    dF_rec = mod(Jam_FreqRate*t_rec, Jam_FreqDev) - Jam_FreqDev/2;
    Phase_rec = nan(1, Nmod);
    Phase_rec(1) = rand(1,1)*2*pi; % Nocoherent Oscillator
    dIF_rec = randn(1,1)*2*pi*300;
    for jj = 2:Nmod
        Phase_rec(jj) = Phase_rec(jj-1) + 2*pi*(dF_rec(jj-1) + f0_if + dIF_rec)*Td;
    end
    
    P_jam_dBm = P_jammer_dBm + 20*log10(c_light/f0 / (4*pi*RecPoi(n_rec).R) );
    RecPoi(n_rec).qjno = P_jam_dBm - N0 - 30;
%     P_jam = 10^(P_jam_dBm/10) / 1000; % W
    A = sqrt(4*10^(RecPoi(n_rec).qjno/10)*sigma_n^2 * Td);
    RecPoi(n_rec).Signal = A*cos(Phase_rec) + sigma_n*randn(1, length(Phase_rec));
    if DoFilter
        RecPoi(n_rec).Signal = filter(Hd, RecPoi(n_rec).Signal);
    end
        
end

[a b] = max([RecPoi(1).qjno RecPoi(2).qjno RecPoi(3).qjno]);
BasePoint = b;

N_shift = 100;    
dRshft = (-N_shift:1:N_shift)*Td*c_light;
hA = 0;
for n_rec = 1:N_RecPoi
    if BasePoint == n_rec % If base point
        continue;
    end
    C = nan(1, N_shift*2 + 1);
    for shft = -N_shift:1:N_shift
        C(shft+N_shift+1) = RecPoi(n_rec).Signal( (N_shift+1):(N_shift+1+Ncorr) ) ...
                            *(RecPoi(BasePoint).Signal( (N_shift+1+shft):(N_shift+1+Ncorr+shft) ))';
    end
    
    if hA == 0
        hA = h_fig_main.axes_Corr1;
    else
        hA = h_fig_main.axes_Corr2;
    end
    plot(hA, dRshft, abs(C))
    if n_rec == 2
        set(hA, 'XTickLabel', []);
    end
    grid(hA, 'on');
    xlabel(hA, '\Delta R, m')
    [a b] = max(abs(C));
    RecPoi(n_rec).CorrAmp = a;
    RecPoi(n_rec).dR_est = (N_shift + 1 - b)*Td*c_light;
    RecPoi(n_rec).dR_real = RecPoi(n_rec).R - RecPoi(BasePoint).R;
%     fprintf('dR%.0f %f : %f  -> %f\n', n_rec, RecPoi(n_rec).dR_est, RecPoi(n_rec).dR_real, RecPoi(n_rec).dR_est-RecPoi(n_rec).dR_real);
end


% hF = 0;
% hF = figure(hF + 1);
N_ro = Nmod;
ff = (-(N_ro/2 - 1):1:N_ro/2)/(Td*1e6)/N_ro;
plot(h_fig_main.axes_Spectr, ff, abs(fftshift(fft(RecPoi(1).Signal))), ...
        ff, abs(fftshift(fft(RecPoi(2).Signal))), ...
        ff, abs(fftshift(fft(RecPoi(3).Signal))))
xlabel(h_fig_main.axes_Spectr,'f, MHz')
xlim(h_fig_main.axes_Spectr,[0 max(ff)])


x0 = [50; -5; -5];

% options=optimset('Display','iter');   % Option to display output
options = optimset('Display','off');  % Turn off display
[x,fval] = fsolve(@Solve_Nev, x0, options);

hold(h_fig_main.axes_Map, 'on');
plot(h_fig_main.axes_Map, x(2), x(3), '*g', 'MarkerSize', 10)
hold(h_fig_main.axes_Map, 'off');

for i = 1:3
    if i == 1
        hT = h_fig_main.txt_qjno1;
    elseif i == 2
        hT = h_fig_main.txt_qjno2;
    elseif i == 3
        hT = h_fig_main.txt_qjno3;
    end
    set(hT, 'String', sprintf('Qjno = %.1f dBHz', RecPoi(i).qjno));
end
set(h_fig_main.txt_X, 'String', sprintf('X = %.1f m', x(2)));
set(h_fig_main.txt_Y, 'String', sprintf('Y = %.1f m', x(3)));
set(h_fig_main.txt_R, 'String', sprintf('R = %.1f m', x(1)));
set(h_fig_main.txt_BasePoint, 'String', sprintf('Base %.0f', BasePoint));
    
function F = Solve_Nev(x)

globals;
F = nan(3, 1);
F(1) = (RecPoi(BasePoint).Z - 0).^2 + (RecPoi(BasePoint).X - x(2)).^2 + (RecPoi(BasePoint).Y - x(3)).^2 - x(1).^2; % To BasePoint
jj = 1;
for i = 1:3
    if i == BasePoint
        continue;
    end
    jj = jj + 1;
    F(jj) = (RecPoi(jj).Z - 0).^2 + (RecPoi(jj).X - x(2)).^2 + (RecPoi(jj).Y - x(3)).^2 - (x(1) + RecPoi(jj).dR_est).^2;
end




