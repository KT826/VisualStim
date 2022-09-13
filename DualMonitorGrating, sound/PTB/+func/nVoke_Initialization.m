function nVoke_Initialization(sub_screenNumber)
    
    global monitor 
    global expWin
    global windowRect
    global screenNumber
    
    if nargin == 1
        submonitor = true;
    else
        submonitor = false;
    end
        
    %% PTB initialization
    Screen('Preference', 'SkipSyncTests', 1);
    PsychDefaultSetup(2);
    %AssertOpenGL; % Make sure the script is running on Psychtoolbox-3:
    KbName('UnifyKeyNames'); % need
    GetSecs; %need
    WaitSecs(.1);
    rand('state', sum(100*clock)); 
    disp('PTB Initialized')
       
    %% get screen information 
    %%%%%%% main display %%%%%%%
    Screen('Screens');
    monitor.rect = Screen('Rect', screenNumber);
    monitor.color.white = 255;%WhiteIndex(screenNumber);
    monitor.color.black = 0;%BlackIndex(screenNumber);
    [expWin, windowRect] = Screen('OpenWindow', screenNumber,monitor.color.BG);
    disp('Got Screen info- monitor info')
    
    % refresh rate (frame-per-second)
    Screen('Preference', 'SkipSyncTests', 0);
    monitor.fps = Screen('FrameRate',expWin); % frames per second
    monitor.ifi = Screen('GetFlipInterval', expWin); %inter-frame-interval
    disp('Got Screen info- refresh rate')
    func.change_BG(monitor.color.BG, monitor.rect,expWin)
    
    %%
    %%%%%%% sub display for binocular grating %%%%%%% 
    if submonitor
        global sub_monitor
        global sub_expWin
        global sub_windowRect
        sub_monitor.rect = Screen('Rect', sub_screenNumber);
        sub_monitor.color.white = monitor.color.white;%WhiteIndex(sub_screenNumber);
        sub_monitor.color.black = monitor.color.black;%BlackIndex(sub_screenNumber);
        [sub_expWin, sub_windowRect] = Screen('OpenWindow', sub_screenNumber,sub_monitor.color.BG);
        disp('Got Screen info- sub monitor info')
    
        % refresh rate (frame-per-second)
        Screen('Preference', 'SkipSyncTests', 0);
        sub_monitor.fps = Screen('FrameRate',sub_expWin); % frames per second
        sub_monitor.ifi = Screen('GetFlipInterval', sub_expWin); %inter-frame-interval
        disp('Got Screen info- refresh rate of sub monitor')
        func.change_BG(sub_monitor.color.BG, monitor.rect,sub_expWin)
    end

    %%
    
end