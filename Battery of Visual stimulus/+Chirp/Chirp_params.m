function [Params] = Chirp_params(StimCenterPosi)
clear Params OptParams stim
%% Chirp
%three patterns of visual stimuli.
%%% common parameters %%%
Params.type = 'Chirp';
Params.stim_feature ='FIllRect';
Params.rep = 8;%8; %Repetition
Params.time_ITI = 15%15; %Inter-Trial-Interval(sec).
Params.stim_PosiCenter = StimCenterPosi;%[12];
Params.stim_size =[10]; %Diamter of Stimulus Size in degree.
Params.time_pre_on = 3.5; %trigger-on in advance to visual stim (sec).
Params.time_post_on = 3.5; %trigger-off after visual stim (sec).

%%
%%%1: Light increent and decrement... BG-Black-White-Black-BG %%%
Params.Stim_LDAI.time_on = 3; %on duration (sec)

%%%2: Frequency modulation %%%
Params.Stim_FM.time_on = 8; %on duration (sec)
Params.Stim_FM.SF= [0.5,1,3,6];%Spatial freq, in Hz

%%%3: Amplitude modulation %%%
Params.Stim_AM.time_on = 8; %on duration (sec)
Params.Stim_AM.amp= [5,25,50,100]/2;%Spatial freq, in Hz
%コントラスト0~100%を0.4Hz for 8 secで移り変わるような設定となっている(Same as Li and Meister, 2022)
end
