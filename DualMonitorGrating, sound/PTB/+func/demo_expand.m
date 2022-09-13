sca;
close all;
clearvars;


Screen('Preference', 'SkipSyncTests', 1);
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% Draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen. When only one screen is attached to the monitor we will draw to
% this.
screenNumber = max(screens);


%%

% Define black and white (white will be 1 and black 0).
white = [255 255 255]; %WhiteIndex(screenNumber);
black = [0 0 0]; %'BlackIndex(screenNumber);
gray = [120 120 120];


% Open an on screen window and color it black
[expWin, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);

%%
% Get the size of the on screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', expWin);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

% Enable alpha blending for anti-aliasing
Screen('BlendFunction', expWin, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Query the frame duration
ifi = Screen('GetFlipInterval', expWin);
%%


waitframes = 1;
initial_px = 0;
final_px = 800;
vel = 1600; %pix/s

%1frameごとにサイズを指定していく。
ifi = 0.0167;
total_frame =round((final_px/vel)/ifi);


sz = linspace(initial_px,final_px,total_frame);
time = 0;
n_frame = 1;
vbl = Screen('Flip', expWin);

while n_frame <= total_frame
    
    stim_pix = sz(n_frame);
    baserect = [0 0 stim_pix stim_pix];
    centeredRect = CenterRectOnPointd(baserect,xCenter,yCenter);
    Screen('FillOval', expWin, black, centeredRect);
    
    % Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);

    
    % Increment the time
    time = time + ifi;
    stim_pix = stim_pix + 10;
    
    n_frame = n_frame + 1;
    if n_frame == total_frame
        pause(1)
    end
    
end
time
Screen('FillRect', expWin, gray, [0 0 screenXpixels screenYpixels]);
Screen('Flip', expWin);