function [Params,OptParams] = Looming_params(StimCenterPosi)
clear Params OptParams stim
global monitor
%% Looming
Params.type = 'Looming';
Params.rep = 8; %Repetition
Params.stim_color = monitor.color.black; %VS_info.stim_color = monitor.color.white; 
Params.loom_initial_size = 2; %deg
Params.loom_final_size = 60; %deg
Params.loom_velocity = 60; % deg/sec
Params.loom_pausetime = 0.25; % after-pausing(sec)
Params.time_pre_on = 3.5; %trigger-on in advance to visual stim (sec).
Params.time_post_on = 3.5; %trigger-off after visual stim (sec).
Params.time_ITI = 15; %Inter-Trial-Interval(sec).
Params.loom_feature = 'FillOval' ; % 'FillRect', 'FillOval'
Params.stim_PosiCenter = StimCenterPosi;

Params.baseline.on = false; %true or false
Params.baseline.rec = 10; %sec.
Params.baseline.recovery = 10; %sec.

OptParams.Opt  = false; % true or false
OptParams.Onset = 1; %Xsec after VS_info.preon
OptParams.Offset = 1; %Xsec after VS_info.off
end