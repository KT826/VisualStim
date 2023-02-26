%Psychotoolbox 
%DAQ box (e.g. National Instrruments)

%% setup
clc; clear all; close all
global path_save
global monitor
global expWin
global windowRect
global screenNumber
global do 
global ao

%%%%%%% INPUT HERE - basic information of monitor display %%%%%%%
path_base = cd;
screenNumber = 1; %screen number in PTB
monitor.color.BG = [120;120;120]; %background color as RGB from 0-255
monitor.pixpitch = 0.0275; %pixell pitch; cm
monitor.dist = 35; %distance between animal eye and monitor; cm
TTLMode = true; %true or false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%  initialization / get screen information  %%%%%%%%%%%%
cd(path_base)
mkdir MAT
mkdir('MAT/temp')
path_save = [path_base '/MAT'];
func.Initialization;

%%%%%%%%%%%% TTL set %%%%%%%%%%%%
if TTLMode
    func.TTL_setting;
    func.change_BG(monitor.color.BG, monitor.rect,expWin)
    try 
        func.change_BG(sub_monitor.color.BG, monitor.rect,sub_expWin)
    catch
    end
end

%%%%%%%%%%%% Make Stimulus Grid %%%%%%%%%%%%
%+add : grid number , size 
func.change_BG(monitor.color.BG, monitor.rect,expWin)
stimsize = 10; %5; %deg  
[grid, Pix, Deg] = func.GenerateMonitorGrid(stimsize);

%% MAIN
%%%%%%%%%%%%%%%%%% Visual stimuli %%%%%%%%%%%%%%%%%%
%% Receptive field mapping (grid stim.)
Params = RFMap.RF_params;
[stim] = RFMap.RF_preset(Params);
ERROR = func.TrialDesigner(Params,stim);
if ~ERROR
    if TTLMode
        [OUTPUT] = RFMap.RF_main(Params,stim);clc
    else
        [OUTPUT] = RFMap.RF_main_NoTTL(Params,stim);
    end
end
func.change_BG(monitor.color.BG, monitor.rect,expWin)

%% Movingbar
Params = MovingBar.MovBar_params;
[stim] = MovingBar.MovBar_preset(Params);
ERROR = func.TrialDesigner(Params,stim);
if ~ERROR
    if TTLMode
        [OUTPUT] = MovingBar.MovBar_main(Params,stim);clc
    else
        [OUTPUT] = MovingBar.MovBar_main_NoTTL(Params,stim);clc
    end
end
func.change_BG(monitor.color.BG, monitor.rect,expWin)

%% Visual Looming
StimCenter= 10;
[Params,OptParams] = Looming.Looming_params(StimCenter);
[stim] = Looming.Looming_preset(Params,OptParams);
ERROR = func.TrialDesigner(Params,stim,OptParams);
if ~ERROR
    if TTLMode
        [OUTPUT] = Looming.Looming_main(Params,stim,OptParams);clc
    else
        [OUTPUT] = Looming.Looming_main_NoTTL(Params,stim,OptParams);clc
    end 
end
func.change_BG(monitor.color.BG, monitor.rect,expWin)

%% Recending white disc
[Params,OptParams] = RecendDisc.RWD_params(StimCenter);
[stim] = RecendDisc.RWD_preset(Params,OptParams);
ERROR = func.TrialDesigner(Params,stim,OptParams);
if ~ERROR
    if TTLMode
        [OUTPUT] = RecendDisc.RWD_main(Params,stim,OptParams);clc
    else
        [OUTPUT] = RecendDisc.RWD_main_NoTTL(Params,stim,OptParams)
    end
end
func.change_BG(monitor.color.BG, monitor.rect,expWin)

%% Chirp
Params = Chirp.Chirp_params(StimCenter);
[stim] = Chirp.Chirp_Presert(Params);
ERROR = func.TrialDesigner(Params,stim);
if ~ERROR
    if TTLMode
        Chirp.Chirp_main(Params,stim);clc
    else
        Chirp.Chirp_main_NoTTL(Params,stim)
    end
end
func.change_BG(monitor.color.BG, monitor.rect,expWin)

%% Color-Preference
[Params,OptParams] = ColPref.Col_params(StimCenter);
[stim] = ColPref.Col_preset(Params);
ERROR = func.TrialDesigner(Params,stim,OptParams);
if ~ERROR
    if TTLMode
        [OUTPUT] = ColPref.Col_main(Params,stim);
    else
        [OUTPUT] = ColPref.Col_main_NoTTL(Params,stim);
    end
end
func.change_BG(monitor.color.BG, monitor.rect,expWin)

%% Size tuning
[Params,OptParams] = SzTuning.Sz_params(StimCenter);
[stim] = SzTuning.Sz_preset(Params,OptParams);
ERROR = func.TrialDesigner(Params,stim,OptParams);
if ~ERROR
    if TTLMode
        OUTPUT = SzTuning.Sz_main(Params,stim,OptParams); clc
    else
        OUTPUT = SzTuning.Sz_main_NoTTL(Params,stim,OptParams); clc
    end
end
func.change_BG(monitor.color.BG, monitor.rect,expWin)

%% Sound noise
soundfile ='Sin_k15Hz_19kHz5000Fs_2sec';
%Sin_k15Hz_19kHz5000Fs_2sec
Params = Sound.SoundOut_params(soundfile,path_base);
Sound.SoundOut_main(Params);

%% Baseline recording
[Params] = BL.BL_params(monitor.color.BG);
BL.BL_main(Params);