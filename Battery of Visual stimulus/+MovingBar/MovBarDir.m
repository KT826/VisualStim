function MBinfo = MovBarDir(MovingDirection,BarWidth,PixPerFrame,MonitorWidth, MonitorHeight,expWin,ifi)

%{ 
###discription###
*PTB for displaying a moving bar
*direction: 0:30:330 + 45:45:315

<INPUT>
MovingDirection: range of 0-330
BarWidth: ...as pixel
PixPerFrame: ...as pixel (velocity)
MonitorWidth: MonitorWidth;
MonitorHeight: monitor.rect(4);
ifi: inter frame interval of monitor using (ifi)
%}

eval(['MBinfo = MovBarDir_',num2str(MovingDirection),'(BarWidth,PixPerFrame,expWin,ifi);'])

%%
%%%%%%%%%%%local functuons %%%%%%%%%%%
%% Direction: 0
function MBinfo = MovBarDir_0(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 0;
x_posi1 = BarWidth*-1;
x_posi2 = x_posi1 + BarWidth;
y_posi1 = 0; %fix
y_posi2 =  MonitorHeight; %fix
k = 1; MBinfo =[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi1 < MonitorWidth %刺激がmonitor幅より短い時にON

    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k+ 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 + PixPerFrame;
    x_posi2 = x_posi1 + BarWidth; 
end
%toc
end

%% Direction: 30
function MBinfo = MovBarDir_30(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 30;
z = (MonitorHeight*2)/sqrt(3); %斜辺 %z = abs(MonitorHeight/sin(60)); %斜辺
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = -z/2;
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi1 < MonitorWidth+(z/2) 
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 + PixPerFrame*(2/sqrt(3));
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

%% Direction: 45
function MBinfo = MovBarDir_45(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 45;
z = abs(MonitorHeight/sin(45)); %斜辺
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = -(cos(45)*z);
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi1 < MonitorWidth+(cos(45)*z) 
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    % Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 + PixPerFrame*sqrt(2);
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

%% Direction: 60
function MBinfo = MovBarDir_60(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 60;
z = MonitorHeight*2;
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = -2*(MonitorHeight*sqrt(3) - MonitorWidth);
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi1 < MonitorWidth+(cos(45)*z)
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 + PixPerFrame*2;
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

%% Direction: 90
function MBinfo = MovBarDir_90(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 0;
x_posi1 = 0;%fix
x_posi2 = MonitorWidth;%fix
y_posi1 = -BarWidth; %fix
y_posi2 = y_posi1 + BarWidth; %fix
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while y_posi1 < MonitorHeight    
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    y_posi1 = y_posi1 + PixPerFrame;
    y_posi2 = y_posi1 + BarWidth;
end
%toc
end

%% Direction: 300
function MBinfo = MovBarDir_300(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 120;
z = MonitorHeight*2;
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = -z/2;
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1;
tic
while x_posi1 < MonitorWidth+z/2
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save 
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 + PixPerFrame*2;
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

%% Direction: 315
function MBinfo = MovBarDir_315(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 135;
z = abs(MonitorHeight/sin(45));
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = -(cos(45)*z);
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi1 < MonitorWidth+(cos(45)*z)
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 + PixPerFrame*sqrt(2);
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

%% Direction: 330
function MBinfo = MovBarDir_330(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 150;
z = (MonitorHeight*2)/sqrt(3); %斜辺
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = z/-2;
x_posi2 = x_posi1;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi1 < MonitorWidth+(z/2)     
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 + PixPerFrame*(2/sqrt(3));
    x_posi2 = x_posi1 + BarWidth;    
end
%toc
end

%% Direction: 180
function MBinfo = MovBarDir_180(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 180;
x_posi1 = MonitorWidth;
x_posi2 = MonitorWidth+BarWidth;
y_posi1 = 0; %fix
y_posi2 =  MonitorHeight; %fix
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi2 > 0 
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 - PixPerFrame;
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

%% Direction: 210
function MBinfo = MovBarDir_210(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 210;
z = (MonitorHeight*2)/sqrt(3);
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = MonitorWidth + (z/2);
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi1 > -(z/2)
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 - PixPerFrame*(2/sqrt(3));
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

%% Direction: 225
function MBinfo = MovBarDir_225(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 225;
z = abs(MonitorHeight/sin(45));
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = MonitorWidth+(cos(45)*z);
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while  x_posi2 > -(cos(45)*z)
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save    
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 - PixPerFrame*sqrt(2);
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

%% Direction: 240
function MBinfo = MovBarDir_240(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 240;
z = MonitorHeight*2;
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = MonitorWidth+z/2;
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi2 > -(z/2)
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 - PixPerFrame*2;
    x_posi2 = x_posi1 + BarWidth; 
end
%toc
end

%% Direction: 270
function MBinfo = MovBarDir_270(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 0;
x_posi1 = 0;%fix
x_posi2 = MonitorWidth;%fix
y_posi1 = MonitorHeight; %fix
y_posi2 = y_posi1 + BarWidth; %fix
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while y_posi2 > 0 
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    y_posi1 = y_posi1 - PixPerFrame;
    y_posi2 = y_posi1 + BarWidth;
end
%toc
end

%% Direction: 120
function MBinfo = MovBarDir_120(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 300;
z = MonitorHeight*2;
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = MonitorWidth*sqrt(3);
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi2 > -(z/2) 
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar on next frame
    x_posi1 = x_posi1 - PixPerFrame*2;
    x_posi2 = x_posi1 + BarWidth;    
end
%toc
end

%% Direction: 135
function MBinfo = MovBarDir_135(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 315;
z = abs(MonitorHeight/sin(45)); %斜辺
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = MonitorWidth+(cos(45)*z);
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi2 > -(cos(45)*z) 
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar next frame
    x_posi1 = x_posi1 - PixPerFrame*sqrt(2);
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

%% Direction: 150
function MBinfo = MovBarDir_150(BarWidth,PixPerFrame,expWin,ifi)
RotationAngle = 330;
z = (MonitorHeight*2)/sqrt(3); %斜辺
y_center = MonitorHeight/2;
y_posi1 = y_center - z;%fix
y_posi2 = y_center + z;%fix
x_posi1 = MonitorWidth + z/2;
x_posi2 = x_posi1 + BarWidth;
k = 1; MBinfo=[];
% Sync us and get a time stamp
vbl = Screen('Flip', expWin); waitframes = 1; 
tic
while x_posi2 > -(z/2)
    %Draw the bar to the screen
    tex = Screen('MakeTexture', expWin, ones(1000,50));
    Screen('DrawTexture', expWin, tex,[], [x_posi1, y_posi1, x_posi2, y_posi2], RotationAngle)
    %Flip to the screen
    vbl  = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    %Save
    MBinfo(k,1) =toc;
    MBinfo(k,[2:6]) = [RotationAngle,x_posi1,x_posi2,y_posi1,y_posi2];
    k = k + 1;
    %Position of the bar at next frame
    x_posi1 = x_posi1 - PixPerFrame*(2/sqrt(3));
    x_posi2 = x_posi1 + BarWidth;
end
%toc
end

end