function load_Map( MapName )

globals;
if strcmp(MapName, 'MPEI')
    BackMap = imread('Maps/MPEI/MPEI.png');
    Image_x_px = 400; x_masht = 1/0.75;
    Image_y_px = 400; y_masht = 1/0.75;
    Image_x_m = Image_x_px * x_masht;
    Image_y_m = Image_y_px * y_masht;
    Image_x_0_px = 180; Image_x_0_m = Image_x_0_px * x_masht;
    Image_y_0_px = 171; Image_y_0_m = Image_y_0_px * y_masht;
end

min_x = 0 - Image_x_0_m;
max_x = Image_x_m - Image_x_0_m;
min_y = 0 - Image_y_0_m;
max_y = Image_y_m - Image_y_0_m;
Img = imagesc([min_x max_x], [min_y max_y], flipdim(BackMap,1), 'Parent', h_fig_main.axes_Map);
MapBounds = [min_x max_x min_y max_y];
set(h_fig_main.axes_Map,'ydir','normal'); 


end

