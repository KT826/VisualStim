function [OUTPUT] = nVoke_run_grating(VS_info,stim,OptParams, Dualmode)

clear swp rep
global do
global monitor
global expWin
global path_save
OUTPUT =[]; disp_time =[]; rep = 1; ri = 1;
trig_tag ={}; trig_globaltime_onset =[]; 
T_global= tic;
filterMode = 0;

if Dualmode == 1 %dual monitor mode
    global sub_monitor
    global sub_expWin
end


%% Baseline recording 
if VS_info.baseline.on == 1
    
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    trig_globaltime_onset(end+1,1) = toc(T_global);
    trig_tag{end+1,1} = 'BL-Pre';
    disp(['Rec. Baseline for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T_global)< VS_info.baseline.rec
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec started.
    %recovering
    T= tic;
    disp(['Recovery from baseline Rec for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T)< VS_info.baseline.recovery
    end
end


%% run
try 
    while rep <= numel(stim.trial_order)
        swp = 1;
        while swp <=  size(stim.trial_order{rep},1) 
            
            %% initial parameter set
            direction = stim.trial_order{1,rep}.direction(swp);
            cyclespersecond = stim.trial_order{1,rep}.TempFreq(swp); %Hz(temporal frequency)
            f = stim.trial_order{1,rep}.SpaFreq_cpp(swp); %c/pixel (spatial frequency)
            duration = stim.trial_order{1,rep}.Duration(swp); %duration of stimulus
            contrast = stim.trial_order{1,rep}.StimColor_Contrast(swp);%
            OG = stim.trial_order{1,rep}.OG(swp);
            
            if Dualmode
                direction_sub = stim.trial_order_sub{1,rep}.direction_sub(swp);
                cyclespersecond_sub = stim.trial_order_sub{1,rep}.TempFreq_sub(swp); %Hz(temporal frequency)
                f_sub = stim.trial_order_sub{1,rep}.SpaFreq_cpp_sub(swp); %c/pixel (spatial frequency)
                contrast_sub = stim.trial_order_sub{1,rep}.StimColor_Contrast_sub(swp);%
                duration_sub = stim.trial_order_sub{1,rep}.Duration_sub(swp);
            end
            
            %% pre stim 
            outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
            T = tic;
            trig_globaltime_onset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'Ex-start';
            
            disp(['Swp.' num2str(swp),'/' num2str(size(stim.trial_order{rep},1)),...
                ' - Rep.' num2str(rep),'/' num2str(numel(stim.trial_order)),' - <Ex start.> ']) 
            
            
            %% Opt start
            
            if OG == 1
                while toc(T) < OptParams.onset
                end
                outputSingleScan(do.TTL.nVoke_OG,[1,1])% Opt stim start
                trig_globaltime_onset(end+1,1) = toc(T_global);
                trig_tag{end+1,1} = 'OG-start';
            end
            
            while toc(T)< VS_info.preon %duration_prestim = 1
            end
            
            %% visual stim ON 
            outputSingleScan(do.TTL.StimTiming,[1,1]) % TTL output
            trig_globaltime_onset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'Grating-start';
            
            switch Dualmode
                case 0
                    [W,K] = nVoke_run_grating_grainting(direction, cyclespersecond, f, duration, contrast);
                case 1
                    [W,K] = nVoke_run_grating_grainting_dualmoce(direction, cyclespersecond, f, duration, contrast,...
                         direction_sub, cyclespersecond_sub, f_sub, duration_sub, contrast_sub);
            end
            
            outputSingleScan(do.TTL.StimTiming,[0,0]) % TTL output
            trig_globaltime_onset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'Grating-stop';
 
            
            %% post stim & Opt off
            T = tic;
            if OG == 1
                while toc(T) < OptParams.offset
                end
                outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim start
                trig_globaltime_onset(end+1,1) = toc(T_global);
                trig_tag{end+1,1} = 'OG-stop';
            end
            
            while toc(T)< VS_info.poston 
            end
            %disp('pause')
            %pause(0.5)
            outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop.
            trig_globaltime_onset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'Ex-Stop';
            %disp('pause- off')
            %pause(0.5)

            
            %% recovery (Inter-Stim-Iterval) %%%%
            T = tic;
            
            %%%%%%%%%% record %%%%%%%%%%
            Direction(ri,1) = direction;
            Contrast(ri,1) = contrast;
            Contrast_ColInd(ri,:) = [W,K];
            TemFreq(ri,1) = cyclespersecond;
            SpacialFreq_cpp(ri,1) = f;
            SpacialFreq_cpd(ri,1) = stim.trial_order{1,rep}.SpaFreq_cpd(swp);
            OG_LED(ri,1) = OG;
            Rep(ri,1) = rep;
            Sweep(ri,1) = swp;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%temporary save
            filename = [path_save '/tempsave_grating.mat'];
            save([filename '.mat'], 'stim', 'monitor','Rep','Sweep')
            %%%%

            disp('ITI')
            switch rep == numel(stim.trial_order) && swp == size(stim.trial_order{1},1)
                case 0
                    while toc(T)< VS_info.recovery %duration_post = 3
                    end
                case 1
                    %go to baseline post
            end
            ri = ri + 1;
            swp = swp + 1;
        end
        rep = rep+1;
    end
 
catch
    disp('error@running')
    func.change_BG(monitor.color.BG, monitor.rect,expWin)
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])
    outputSingleScan(do.TTL.StimTiming,[0,0]) % reset TTL
    outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim stop
    try 
        change_BG(sub_monitor.color.BG, sub_monitor.rect, sub_expWin)
    catch
    end
end


%% Baseline recording 
if VS_info.baseline.on == 1
    
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    trig_globaltime_onset(end+1,1) = toc(T_global);
    trig_tag{end+1,1} = 'BL-Pre';
    disp(['Rec. Baseline for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T_global)< VS_info.baseline.rec
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec started.
    %recovering
    T= tic;
    disp(['Recovery from baseline Rec for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T)< VS_info.baseline.recovery
    end
end

%% save
clear OUTPUT
OUTPUT = table(Rep,Sweep, Direction,Contrast,TemFreq,SpacialFreq_cpp,SpacialFreq_cpd,OG_LED);
ExOnGlobalTime = table(trig_tag,trig_globaltime_onset);

matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_SinGrating_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'monitor','ExOnGlobalTime','OptParams')

end


%%
function [white,black] = nVoke_run_grating_grainting(direction, cyclespersecond, f, duration, contrast)

%direction: angle of grating; 0-360
%cyclespersecond: Hz(temporal frequency)
%f: cycle per pixel (spatial frequency)
%duration: display time of grating stimulus
%contrast: contrast of grating; 1-100%. 100= Black0 & White255 

global monitor
global expWin

%%
drawmask=0;
gratingsize=2000;
texsize=gratingsize / 2;
contrast = 127*(1-contrast/100);
white = monitor.color.white - contrast;
black = monitor.color.black + contrast;
gray=round((white+black)/2);
inc=white-gray;


% Calculate parameters of the grating:
% First we compute pixels per cycle, rounded up to full pixels, as we
% need this to create a grating of proper size below:
p=ceil(1/f);
% Also need frequency in radians:
fr=f*2*pi;
    
% This is the visible size of the grating. It is twice the half-width
% of the texture plus one pixel to make sure it has an odd number of
% pixels and is therefore symmetric around the center of the texture:
visiblesize=2*texsize+1;

% Create one single static grating image:
%
% We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
% define the whole grating! If the 'srcRect' in the 'Drawtexture' call
% below is "higher" than that (i.e. visibleSize >> 1), the GPU will
% automatically replicate pixel rows. This 1 pixel height saves memory
% and memory bandwith, ie. it is potentially faster on some GPUs.
%
% However it does need 2 * texsize + p columns, i.e. the visible size
% of the grating extended by the length of 1 period (repetition) of the
% sine-wave in pixels 'p':
x = meshgrid(-texsize:texsize + p, 1);
% Compute actual cosine grating:
grating=gray + inc*cos(fr*x);

% Store 1-D single row grating in texture:
gratingtex=Screen('MakeTexture', expWin, grating);

% Create a single gaussian transparency mask and store it to a texture:
% The mask must have the same size as the visible size of the grating
% to fully cover it. Here we must define it in 2 dimensions and can't
% get easily away with one single row of pixels.
%
% We create a  two-layer texture: One unused luminance channel which we
% just fill with the same color as the background color of the screen
% 'gray'. The transparency (aka alpha) channel is filled with a
% gaussian (exp()) aperture mask:
mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
[x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
mask(:, :, 2)= round(white * (1 - exp(-((x/90).^2)-((y/90).^2))));
masktex=Screen('MakeTexture', expWin, mask);

% Query maximum useable priorityLevel on this system:
priorityLevel=MaxPriority(expWin); 

% We don't use Priority() in order to not accidentally overload older
% machines that can't handle a redraw every 40 ms. If your machine is
% fast enough, uncomment this to get more accurate timing.
%Priority(priorityLevel);

% Definition of the drawn rectangle on the screen:
% Compute it to  be the visible size of the grating, centered on the
% screen:
dstRect=[0 0 visiblesize visiblesize];
dstRect=CenterRect(dstRect, monitor.rect);

% Query duration of one monitor refresh interval:
%ifi=Screen('GetFlipInterval', expWin);
ifi = monitor.ifi;

% Translate that into the amount of seconds to wait between screen
% redraws/updates:

% waitframes = 1 means: Redraw every monitor refresh. If your GPU is
% not fast enough to do this, you can increment this to only redraw
% every n'th refresh. All animation paramters will adapt to still
% provide the proper grating. However, if you have a fine grating
% drifting at a high speed, the refresh rate must exceed that
% "effective" grating speed to avoid aliasing artifacts in time, i.e.,
% to make sure to satisfy the constraints of the sampling theorem
% (See Wikipedia: "Nyquist?Shannon sampling theorem" for a starter, if
% you don't know what this means):
waitframes = 1;

% Translate frames into seconds for screen update interval:
waitduration = waitframes * ifi;

% Recompute p, this time without the ceil() operation from above.
% Otherwise we will get wrong drift speed due to rounding errors!
p=1/f;  % pixels/cycle    

shiftperframe= cyclespersecond * p * waitduration;
vbl=Screen('Flip', expWin);

i=0;
Tt = tic;
% Animationloop:
while toc(Tt)< duration
    xoffset = mod(i*shiftperframe,p);
    i=i+1;
    srcRect=[xoffset 0 xoffset + visiblesize visiblesize];

    % Draw grating texture, rotated by "angle":
    Screen('DrawTexture', expWin, gratingtex, srcRect, dstRect, direction);
    vbl = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
end
func.change_BG(monitor.color.BG, monitor.rect,expWin)

end


%%
function [white,black] = nVoke_run_grating_grainting_dualmoce(direction, cyclespersecond, f, duration, contrast,direction_sub, cyclespersecond_sub, f_sub, duration_sub,contrast_sub)

global monitor
global expWin
global sub_monitor
global sub_expWin


drawmask=0;
gratingsize=2000;
texsize=gratingsize / 2;

%%%% main monitor %%%% 
if ~isnan(f)
    contrast = 127*(1-contrast/100);
    white = monitor.color.white - contrast;
    black = monitor.color.black + contrast;
    gray=round((white+black)/2);
    inc=white-gray;
    p=ceil(1/f);
    fr=f*2*pi;
    visiblesize=2*texsize+1;
    x = meshgrid(-texsize:texsize + p, 1);
    grating=gray + inc*cos(fr*x);
    gratingtex=Screen('MakeTexture', expWin, grating);
    mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
    [x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
    mask(:, :, 2)= round(white * (1 - exp(-((x/90).^2)-((y/90).^2))));
    masktex=Screen('MakeTexture', expWin, mask);
    priorityLevel=MaxPriority(expWin); 
    dstRect=[0 0 visiblesize visiblesize];
    dstRect=CenterRect(dstRect, monitor.rect);
    ifi = monitor.ifi;
    waitframes = 1;
    waitduration = waitframes * ifi;
    p=1/f;  % pixels/cycle    
    shiftperframe= cyclespersecond * p * waitduration;
end

%%%% sub monitor %%%% 
if ~isnan(f_sub)
    sub.contrast = 127*(1-contrast_sub/100);
    sub.white = sub_monitor.color.white - sub.contrast;
    sub.black = sub_monitor.color.black + sub.contrast;
    sub.gray=round((sub.white+sub.black)/2);
    sub.inc=sub.white-sub.gray;
    sub.p=ceil(1/f_sub);
    sub.fr=f_sub*2*pi;
    sub.visiblesize = 2*texsize+1;
    sub.x = meshgrid(-texsize:texsize + sub.p, 1);
    sub.grating=sub.gray + sub.inc*cos(sub.fr*sub.x);
    sub.gratingtex=Screen('MakeTexture', sub_expWin, sub.grating);
    sub.mask=ones(2*texsize+1, 2*texsize+1, 2) * sub.gray;
    [sub.x,sub.y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
    sub.mask(:, :, 2)= round(sub.white * (1 - exp(-((sub.x/90).^2)-((sub.y/90).^2))));
    sub.masktex=Screen('MakeTexture', sub_expWin, sub.mask);
    sub.priorityLevel=MaxPriority(sub_expWin); 
    sub.dstRect=[0 0 sub.visiblesize sub.visiblesize];
    sub.dstRect=CenterRect(sub.dstRect, sub_monitor.rect);
    sub.ifi = sub_monitor.ifi;
    sub.waitframes = 1;
    sub.waitduration = sub.waitframes * sub.ifi;
    sub.p=1/f_sub;  % pixels/cycle    
    sub.shiftperframe= cyclespersecond_sub * sub.p * sub.waitduration;
    
    white = nan;
    black = nan;
end

change_BG(monitor.color.BG, monitor.rect,expWin)
change_BG(sub_monitor.color.BG, sub_monitor.rect,sub_expWin)
i=0;
Tt = tic;    
if ~isnan(f) && isnan(f_sub) % mainmonitor 
    vbl=Screen('Flip', expWin);
    while toc(Tt)< duration
        xoffset = mod(i*shiftperframe,p);
        i=i+1;
        srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
        % Draw grating texture, rotated by "angle":
        Screen('DrawTexture', expWin, gratingtex, srcRect, dstRect, direction);
        vbl = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
    end
    
elseif isnan(f) && ~isnan(f_sub) % submonitor 
    sub.vbl=Screen('Flip', sub_expWin);
    while toc(Tt)< duration_sub
        sub.xoffset = mod(i*sub.shiftperframe,sub.p);
        i=i+1;
        sub.srcRect=[sub.xoffset 0 sub.xoffset + sub.visiblesize sub.visiblesize];
        Screen('DrawTexture', sub_expWin, sub.gratingtex, sub.srcRect, sub.dstRect, direction_sub); 
        sub.vbl = Screen('Flip', sub_expWin, sub.vbl + (sub.waitframes - 0.5) * sub.ifi);
    end
    
elseif  ~isnan(f) && ~isnan(f_sub) % dual
    vbl=Screen('Flip', expWin);
    while toc(Tt)< duration
        xoffset = mod(i*shiftperframe,p);
        sub.xoffset = mod(i*sub.shiftperframe,sub.p);
        i=i+1;
        srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
        sub.srcRect=[sub.xoffset 0 sub.xoffset + sub.visiblesize sub.visiblesize];
        
        Screen('DrawTexture', expWin, gratingtex, srcRect, dstRect, direction);
        Screen('DrawTexture', sub_expWin, sub.gratingtex, sub.srcRect, sub.dstRect, direction_sub);
        vbl = Screen('Flip', expWin, vbl + (waitframes - 0.5) * ifi);
        Screen('Flip', sub_expWin, vbl + (sub.waitframes - 0.5) * sub.ifi);
    end
end


change_BG(monitor.color.BG, monitor.rect,expWin)
change_BG(sub_monitor.color.BG, sub_monitor.rect,sub_expWin)
clear sub
end


