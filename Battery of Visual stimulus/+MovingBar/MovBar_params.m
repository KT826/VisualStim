function Params = MovBar_params
clear Params OptParams stim
global monitor
%% Moving bar
Params.type = 'MovingBar';

%BarWidth
Params.BarWidth_deg = 5; 
[Pix] = func.deg2pix(Params.BarWidth_deg,monitor.dist,monitor.pixpitch);
Params.BarWidth = Pix.n_pixel;

%PixPerFrame
Params.PixPerFrame_DegPerSec = 50;
[Pix] = func.deg2pix(Params.PixPerFrame_DegPerSec,monitor.dist,monitor.pixpitch);
Params.PixPerFrame =Pix.n_pixel/monitor.fps;

Params.direction = [0:30:330];
Params.rep = 8; %Repetition
Params.stim_color = monitor.color.black;
Params.time_pre_on = 3.5; %trigger-on in advance to visual stim (sec).
Params.time_post_on = 3.5; %trigger-off after visual stim (sec).
Params.time_ITI = 7.5; %Inter-Trial-Interval(sec).
Params.baseline.on = false; %true or false
Params.baseline.rec = 10; %sec.
Params.baseline.recovery = 10; %sec.



end

