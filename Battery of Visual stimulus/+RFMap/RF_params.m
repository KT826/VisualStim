function Params = RF_params
clear Params OptParams stim
global monitor
%% Receptive field mapping
Params.type = 'mapping_order'; %'mapping_order' or 'sparse'
Params.rep = 3; %Repetition
Params.stim_color = monitor.color.black;
Params.stim_feature = 'FillRect' ; % 'FillRect' or'FillOval'
Params.time_on = 0.5; %on duration (sec)
Params.time_pre_on = 2.5; %trigger-on in advance to visual stim (sec).
Params.time_post_on = 3; %trigger-off after visual stim (sec).
Params.time_ITI = 0; %Inter-Trial-Interval(sec).
Params.baseline.on = false; %true or false
Params.baseline.rec = 10; %sec.
Params.baseline.recovery = 10; %sec.

Params.TTL_TrigMode = 'continuous'; % 'continuous' or 'momentary'
% 'continuous': Trigger is on all time the session.
% 'momentary': Trigger is off at each ITI.

end

