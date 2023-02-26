function [Params,OptParams] = Sz_params(StimCenterPosi)
clear Params OptParams stim
%% Size-tuning
Params.type = 'Sz_tuning';
Params.rep = 8; %Repetition
Params.stim_PosiCenter = StimCenterPosi;%[12];
Params.stim_size =[2,4,8,16,32]; %diameter (degree(
Params.stim_contrast = [100];% Percent Contrast against background. (0 is same as background).
Params.stim_feature = 'FillRect' ; % 'FillRect' or'FillOval'
Params.time_on = 2; %on duration (sec)
Params.time_pre_on = 3.5; %trigger-on in advance to visual stim (sec).
Params.time_post_on = 6; %trigger-off after visual stim (sec).
Params.time_ITI = 10; %Inter-Trial-Interval(sec).
Params.baseline.on = false; %true or false
Params.baseline.rec = 10; %sec.
Params.baseline.recovery = 10; %sec.

OptParams.Opt  = false; % true or false
OptParams.Onset = 1; %Xsec after VS_info.preon
OptParams.Offset = 1; %Xsec after VS_info.off

end
