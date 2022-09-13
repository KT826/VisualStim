% Clear the workspace and the screen
%sca;
%close all;
%clearvars;

% Here we call some default settings for setting up Psychtoolbox
%PsychDefaultSetup(2);

% Get the screen numbers
%screens = Screen('Screens');

% Draw to the external screen if avaliable
%screenNumber = max(screens);

% Define black and white
%white = WhiteIndex(screenNumber);
%black = BlackIndex(screenNumber);
%grey = white / 2;
%inc = white - grey;

% Open an on screen window
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
%[screenXpixels, screenYpixels] = Screen('WindowSize', expWin);

% Query the frame duration
%ifi = Screen('GetFlipInterval', expWin);

% Get the centre coordinate of the expWin
[xCenter, yCenter] = RectCenter(monitor.rect);

% Set up alpha-blending for smooth (anti-aliased) lines
%Screen('BlendFunction', expWin, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Define a simple 4 by 4 checker board
checkerboard_1 = repmat(eye(2), 5, 5)*255;
checkerboard_2 = abs(checkerboard_1 - 255);

% Make the checkerboard into a texure (4 x 4 pixels)
checkerTexture_1 = Screen('MakeTexture', expWin, checkerboard_1);
checkerTexture_2 = Screen('MakeTexture', expWin, checkerboard_2);


% We will scale our texure up to 90 times its current size be defining a
% larger screen destination rectangle
[s1, s2] = size(checkerboard_1);
dstRect = [0 0 s1 s2] .* 90;
dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);

% Draw the checkerboard texture to the screen. By default bilinear
% filtering is used. For this example we don't want that, we want nearest
% neighbour so we change the filter mode to zero
filterMode = 0;

tic 
for i = 1 : 300
    switch rem(i,2)
        case 1
            Screen('DrawTextures', expWin, checkerTexture_1, [],dstRect, 0, filterMode);
        case 0
            Screen('DrawTextures', expWin, checkerTexture_2, [],dstRect, 0, filterMode);
    end       
    % Flip to the screen
    Screen('Flip', expWin);
    WaitSecs(0.5)
end
toc

% Wait for a key press
KbStrokeWait;

% Clear the screen
sca;