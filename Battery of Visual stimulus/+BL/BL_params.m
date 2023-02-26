function Params = BL_params(BackGroundColor)
clear Params OptParams stim
global monitor
%%
Params.rep = 8; %Repetition
Params.monitorcolor = BackGroundColor;
Params.time_on = 10; %trigger-on
Params.time_ITI = 10; %Inter-Trial-Interval(sec).

end