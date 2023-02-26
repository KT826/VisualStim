function [grid, Pix, Deg] = GenerateMonitorGrid(stimsize)

global grid
global monitor
global screenNumber
%% 入力した degが 刺激正方形の1辺に最も近くなる divmonitorの値を探す
[Pix] = func.deg2pix(stimsize,monitor.dist,monitor.pixpitch);
divmonitor = round(monitor.rect(4)/Pix.n_pixel);
[grid] = func.grid_position(monitor.rect(3),monitor.rect(4),divmonitor);
[Deg] = func.pix2deg(grid.ls,monitor.dist,monitor.pixpitch); %ピクセルをdegにする. grid1辺のdegを求める
grid.ls_deg = Deg.deg;
disp(['Single grid size =  ', num2str(grid.ls_deg), ' deg'])

%%% たまに 1が入ることがある.
if monitor.color.white == 1
    monitor.color.white =   WhiteIndex(screenNumber);
end
end