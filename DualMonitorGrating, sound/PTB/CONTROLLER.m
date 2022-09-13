clc; clear all; close all
global path_save
global monitor
global expWin
global windowRect
global screenNumber
global do 
global ao

%%%%%%% INPUT - basic information %%%%%%%
path_base = pwd;
screenNumber = 1;
monitor.color.BG = [120;120;120];
monitor.pixpitch = 0.0248; %cm
monitor.dist = 30; %monitore distance between eye and monitor; cm


%%%%%%%%%% option for dual-display %%%%%%%%%%
%{ 
%If going on single monitor mode, make commemt out here
 
global sub_monitor
global sub_screenNumber
global sub_expWin
global sub_windowRect
sub_screenNumber = 1; %display numvber of subscreen which is only used for binopcular grating.
sub_monitor.color.BG = [120;120;120];
sub_monitor.pixpitch = 0.0265; %cm
sub_monitor.dist = 30; %monitore distance between eye and monitor; cm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

%% setup of PTB and TTL
%%%%%%%%%%%%  initialization / get screen information  %%%%%%%%%%%%
cd(path_base)
mkdir MAT
path_save = [path_base '/MAT'];
switch exist('sub_screenNumber')
    case false
        func.nVoke_Initialization;        
    case true
        func.nVoke_Initialization(sub_screenNumber);
end

%%%%%%%%%%%% TTL set %%%%%%%%%%%%
func.TTL_setting;
func.change_BG(monitor.color.BG, monitor.rect,expWin)
try 
    func.change_BG(sub_monitor.color.BG, monitor.rect,sub_expWin)
catch
end

%%
%%%%%%%%%%%% Make Stimulus Grid %%%%%%%%%%%%
func.change_BG(monitor.color.BG, monitor.rect,expWin)
clear grid stim; close; clc
global grid
stimsize = 10; %5; %deg  
func.nVoke_MakeMonitorGrid(stimsize)


%%
%%%%%%%%%%%%%%%%%% Visual stimuli %%%%%%%%%%%%%%%%%%

%% Size-tuning
%update: 2022/01/14: add contrast parameter
clear OUTPUT VS_info stim; clc
%%%%%%%% Parameter %%%%%%%%
VS_info.rep = 1;
VS_info.stim_size =[5,20]; %deg
VS_info.stim_contrast = [50];% percent of back ground. 0 is same as the BG color (maybe 120).
VS_info.type = 'Sz_tuning' ;
VS_info.feature = 'FillOval' ; % 'FillRect', 'FillOval'
VS_info.preon = .5; %sec. trigger-ON
VS_info.on = 1;
VS_info.off = .5; %sec. trigger-ON
VS_info.recovery= 1; %sec. trigger-OFF
VS_info.center = [12];

VS_info.baseline.on = false; %true or false
VS_info.baseline.rec = 10; %sec.
VS_info.baseline.recovery = 10; %sec.

Opt  = false; % true or false
OptParams.onset = 1; %Xsec after VS_info.preon
OptParams.offset = 1; %Xsec after VS_info.off
%%%%%%%%%%%%%%%%%%%%%%%%%%

[stim] = func.nVoke_visual_stim_info_Sz(VS_info,Opt);
ERROR= func.nVoke_TrialDesigner(VS_info,stim,OptParams);

if ~ERROR
    tic
    [~] = func.nVoke_run_size_tuning(VS_info,stim,OptParams);
    clc
    toc
    disp('DONE')
    func.change_BG(monitor.color.BG, monitor.rect,expWin)
end

%% Cheaker board 
clear OUTPUT VS_info stim; clc
%%%%%%%% Parameter %%%%%%%%
VS_info.type = 'CKB';
VS_info.rep = 2;
VS_info.preon = 2; %sec. trigger-ON
VS_info.on = 1; %
VS_info.poston = 2; %sec. trigger-ON
VS_info.stim_size = [2.5]; %deg, single value only
VS_info.stim_contrast = [50];% 100: 0&255, 50: 63&192
VS_info.ITI = 5;

VS_info.baseline.on = false; %true or false
VS_info.baseline.rec = 3; %sec.
VS_info.baseline.recovery = 3; %sec.

Opt  = false; % true or false
OptParams.onset = 1; %Xsec after VS_info.preon
OptParams.offset = 1; %Xsec after VS_info.poston
%%%%%%%%%%%%%%%%%%%%%%%%%%

[stim] = func.nVoke_visual_stim_info_CKB(VS_info,Opt);
ERROR= func.nVoke_TrialDesigner(VS_info,stim,OptParams);

if ~ERROR
    WaitSecs(1);
    tic 
    [OUTPUT] = func.nVoke_run_checkerboard(VS_info,stim,OptParams);
    disp('DONE')
    func.change_BG(monitor.color.BG, monitor.rect,expWin)
    toc
end

%% Full-filed sinusoidal grating
clear OUTPUT VS_info stim; clc

%%%%%%%% Parameter %%%%%%%%
VS_info.type = 'Grating' ;
VS_info.rep = 2;
VS_info.grating.SpatialFreq= [0.03];%[0.02,0.04,0.08,0.16,0.32,0.64,1.28]; %cycle/degree
VS_info.grating.angle = [180,0]; %Tilt angle of the grating: 0/180 - move forward/backword
VS_info.grating.contrast = [100];% 100: 0&255, 50: 63&192
VS_info.grating.TempFreq = [4];%[4,2]; % Hz
VS_info.grating.duration = 1; % sec. Basically only single value is available.
VS_info.preon = 2; %sec. background screen
VS_info.poston = 1; %sec. background screen
VS_info.recovery= 2; %sec. interval

VS_info.baseline.on = false; %true or false
VS_info.baseline.rec = 10; %sec.
VS_info.baseline.recovery = 10; %sec.

Opt  = false; % true or false
OptParams.onset = VS_info.preon; %Xsec after VS_info.preon
OptParams.offset = 1; %Xsec after grating off

%%%%%%%%%%%%% Dualmode %%%
%true or false. When true, the order of stimuli are fixed, be same as Rune 2021 Currnt Biology.
%parameters are re-set in 'nVoke_visual_stim_info_Grating_DualMode'
Dualmode = false; % true or false
if ~exist('sub_screenNumber') && Dualmode == 1
    disp('ERROR@Dualmode')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

switch Dualmode 
    case 0
        [stim] = func.nVoke_visual_stim_info_Grating(VS_info,Opt);
    case 1
        [stim] = func.nVoke_visual_stim_info_Grating_DualMode(VS_info,Opt);
end
ERROR= func.nVoke_TrialDesigner(VS_info,stim,OptParams);
%%
if ~ERROR
    tic
    [OUTPUT] = func.nVoke_run_grating(VS_info,stim,OptParams, Dualmode);
    toc
    disp('DONE')
    func.change_BG(monitor.color.BG, monitor.rect,expWin)
end

%{
%%%%refference%%%%
1) Grating parameter in SC: "Ito et.al., JNS, 2017 (Segregation of~)"

%}

%% Grid-mapping
clear OUTPUT VS_info stim; clc

%%%%%%%% Parameter %%%%%%%%
VS_info.rep = 1; %times
VS_info.preon = .1; %sec. trigger-ON
VS_info.on = .3; %sec. trigger-ON
VS_info.off = .1; %sec. trigger-ON
VS_info.recovery= .1; %sec. trigger-OFF
VS_info.type = 'sparse'; % 'mapping_order' or 'sparse'
VS_info.feature = 'FillRect'; % 'FillRect' or 'FillOval'

VS_info.baseline.on = false; %true or false
VS_info.baseline.rec = 10; %sec.
VS_info.baseline.recovery = 10; %sec.
%%%%%%%%%%%%%%%%%%%%%%%%

[stim] = func.nVoke_visual_stim_info_RF(VS_info,grid.wide,grid.hight,monitor);
ERROR= func.nVoke_TrialDesigner(VS_info,stim);

if ~ERROR
    tic
    [OUTPUT] = func.nVoke_run_mapping(VS_info, stim, do, monitor, grid, expWin);
    toc
    disp('DONE')
    func.change_BG(monitor.color.BG, monitor.rect,expWin)
end

%% Audio stim only(No visual stim)
clear AUD_info stim stim OUTPUT Opt AUD_info
clc

repetitions = 0; 
%%%%%%%% Parameter %%%%%%%%
AUD_info.audiofile = ["YOURPATH",'/Tiago_NN_2021_1.wav']; 
[AUD_info.wavedata, AUD_info.freq] = psychwavread(AUD_info.audiofile);
AUD_info.rep = 5; %If 10, w/- and w/o- audio trial is 10 each.
AUD_info.preon = 2; %sec. trigger-ON
AUD_info.on = 3; 
AUD_info.off = 7; %sec. trigger-ON
AUD_info.recovery= 60; %sec. trigger-OFF; inter-stimulus-interval

AUD_info.baseline.on = false; %true or false
AUD_info.baseline.rec = 10; %sec.
AUD_info.baseline.recovery = 10; %sec.
%%%%%%%%%%%%%%%%%%%%%%%%

%[stim] = nVoke_AudioOnly_stim_info(AUD_info);
t = (AUD_info.rep*(AUD_info.preon+AUD_info.on+AUD_info.off)+(AUD_info.rep-1)*(AUD_info.recovery));%sec
disp(['scan time: ', num2str((t)/60) ' min']); 
clear t*

WaitSecs(1);
tic 
nVoke_run_AudioOutOnly(do, AUD_info);
disp('DONE')
toc


%%
outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])
outputSingleScan(do.TTL.StimTiming,[0,0]) % reset TTL
outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim stop
change_BG(monitor.color.BG, monitor.rect,expWin)
try 
    func.change_BG(sub_monitor.color.BG, monitor.rect,sub_expWin)
catch
end

