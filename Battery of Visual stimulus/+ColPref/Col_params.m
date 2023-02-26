function [Params,OptParams]  = Col_params(StimCenterPosi)
clear Params OptParams stim
global monitor
%% Color Preference
%K(1s)-B(3s)-K(4s)-G(3s)-K(3s), 10x10 square, Li&Meister, Biorxiv,2022
monitor.color.blue = [0;0;255];
monitor.color.green = [0;255;0];

Params.type = 'Col_Preference';
Params.rep = 8; %Repetition
Params.stim_PosiCenter = StimCenterPosi;%[12];
Params.stim_size = 10;
Params.stim_contrast = [100];% Percent Contrast against background. (0 is same as background).
Params.stim_feature = 'FillRect' ; % 'FillRect' or'FillOval'
Params.time_on = [1,3,4,3,3]; %on duration (sec)
Params.ColOrder = {[0,0,0],[0,0,255],[0,0,0],[0,255,0],[0,0,0]}; %RGB
Params.time_pre_on = 3.5; %trigger-on in advance to visual stim (sec). Gray-background
Params.time_post_on = 3.5; %trigger-off after visual stim (sec). Gray-background
Params.time_ITI = 10; %Inter-Trial-Interval(sec).
Params.baseline.on = false; %true or false
Params.baseline.rec = 10; %sec.
Params.baseline.recovery = 10; %sec.

OptParams.Opt  = false; % true or false
OptParams.Onset = 1; %Xsec after VS_info.preon
OptParams.Offset = 1; %Xsec after VS_info.off

end
