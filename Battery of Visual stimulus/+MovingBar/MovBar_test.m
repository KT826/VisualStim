clc; clear all; close all
global path_save
global monitor
global expWin
global windowRect
global screenNumber
global do 
global ao

%%%%%%% INPUT - basic information %%%%%%%
path_base = cd;
screenNumber = 1; %screen for dysplaying stimuli
monitor.color.BG = [120;120;120];
monitor.pixpitch = 0.0248; %cm
monitor.dist = 30; %monitore distance between eye and monitor; cm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% setup of PTB and TTL
%%%%%%%%%%%%  initialization / get screen information  %%%%%%%%%%%%
cd(path_base)
mkdir MAT
mkdir('MAT/temp')
path_save = [path_base '/MAT'];
func.Initialization;

%{
%%%%%%%%%%%% TTL set %%%%%%%%%%%%
TTL_setting;
change_BG(monitor.color.BG, monitor.rect,expWin)
try 
    change_BG(sub_monitor.color.BG, monitor.rect,sub_expWin)
catch
end
%}
%%
%%%%%%%%%%%% Make Stimulus Grid %%%%%%%%%%%%
%+add : grid number , size 
func.change_BG(monitor.color.BG, monitor.rect,expWin)
stimsize = 12; %5; %deg  
[grid, Pix, Deg] = func.GenerateMonitorGrid(stimsize);


%%

%% Movingbar

%BarWidth
[Pix] = func.deg2pix(10,monitor.dist,monitor.pixpitch);
BarWidth = Pix.n_pixel;

%PixPerFrame
[Pix] = func.deg2pix(50,monitor.dist,monitor.pixpitch);
PixPerFrame =Pix.n_pixel/monitor.fps;

D = sort([0:30:330,45:90:360]);

for i= 1 : numel(D)
MBinfo = MovingBar.MovBarDir(D(i),BarWidth,PixPerFrame,monitor.rect(3), monitor.rect(4),expWin,monitor.ifi);
end