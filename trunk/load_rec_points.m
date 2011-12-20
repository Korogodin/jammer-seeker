function load_rec_points( PType, Nmod )

globals;

RecPoi_zag.X = NaN;
RecPoi_zag.Y = NaN;
RecPoi_zag.Z = 15;
RecPoi_zag.R = NaN;
RecPoi_zag.Signal = nan(1, Nmod);
RecPoi_zag.dR_est = NaN;
RecPoi_zag.dR_real = NaN;
RecPoi_zag.CorrAmp = NaN;
RecPoi_zag.qjno = NaN;

if PType == 1
    % 3 points:
    % A, G, M
    
    N_RecPoi = 3;
    RecPoi = repmat(RecPoi_zag, N_RecPoi, 1);
    
    RecPoi(1).X = 0;
    RecPoi(1).Y = 0;

    RecPoi(2).X = -5;
    RecPoi(2).Y = -90;

    RecPoi(3).X = -145;
    RecPoi(3).Y = 55;
    
end 

hold(h_fig_main.axes_Map, 'on');
for i = 1:N_RecPoi
    plot(h_fig_main.axes_Map, RecPoi(i).X, RecPoi(i).Y, '*r', 'MarkerSize',10);
end
hold(h_fig_main.axes_Map, 'off');

end