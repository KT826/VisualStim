function  [OUTPUT] = nVoke_run_checkerboard(VS_info,stim,OptParams);

clear swp rep
global do
global monitor
global grid
global expWin
global path_save

OUTPUT =[]; disp_time =[]; rep = 1;
trig_tag ={}; trig_globaltime_onset =[]; 
flipSecs_ON = stim.time.ON;
waitframes_ON = round(flipSecs_ON / monitor.ifi);
T_global= tic;
filterMode = 0;

%dstRect = [0 0 s1 s2] .* 90;
[xCenter, yCenter] = RectCenter(monitor.rect);
dstRect = CenterRectOnPointd(monitor.rect, xCenter, yCenter);

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


%%
try 
    while rep <= numel(stim.trial_order)
        %% parameter setting 
        checkerboard_1 = stim.trial_order{rep}.CKB_1{1};
        checkerboard_2  = stim.trial_order{rep}.CKB_2{1};
        checkerTexture_1 = Screen('MakeTexture', expWin, checkerboard_1);
        checkerTexture_2 = Screen('MakeTexture', expWin, checkerboard_2);
        OG = stim.trial_order{rep}.OG;

        %% pre stim 
        outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
        T = tic;
        trig_globaltime_onset(end+1,1) = toc(T_global);
        trig_tag{end+1,1} = 'Ex-on';
        clc
        disp(['Rep.' num2str(rep),'/' num2str(numel(stim.trial_order)),' - <Pre Stim.> ']) 
        
        %% Opt start
        if OG == 1
            while toc(T) < OptParams.onset
            end
            outputSingleScan(do.TTL.nVoke_OG,[OG,OG])% Opt stim start
            trig_globaltime_onset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'OG-start';
        end
        
        while toc(T)< VS_info.preon %duration_prestim = 1
        end
        
        %% Start CKB flipping
        swp = 1;
        %Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % BackGround Screenn
        
        while swp <=  stim.rep*2
            switch rem(swp,2)
                case 1
                    Screen('DrawTextures', expWin, checkerTexture_1, [],dstRect, 0, filterMode);
                case 0
                    Screen('DrawTextures', expWin, checkerTexture_2, [],dstRect, 0, filterMode);
            end
            %Flip to the screen
            switch swp == 1
                case 0
                    vbl_on = Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi);
                case 1
                    vbl_on = Screen('Flip', expWin); % Spot
            end
            outputSingleScan(do.TTL.StimTiming,[1,1]) % TTL output
            trig_globaltime_onset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'CKB flip';
            outputSingleScan(do.TTL.StimTiming,[0,0]) % TTL output
            todisp= ['Contrast ' num2str(stim.trial_order{rep}.StimColor_Contrast),'% - Opt' ,num2str(OG)];
            disp(['Swp.' num2str(swp),'/' num2str(stim.rep*2),...
                ' - Rep.' num2str(rep),'/' num2str(numel(stim.trial_order)),' - <' todisp, '>']) 
            swp = swp + 1;
        end
        
        
        %% Post stim & Opt OFF
        vbl_off  = Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % BackGround Screenn
        T = tic;
        if OG == 1
            while toc(T) < OptParams.offset
            end
            outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim stop
            trig_globaltime_onset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'OG-end';
        end
        
        while toc(T)< VS_info.poston %duration_post = 3
        end
        outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop.
        trig_globaltime_onset(end+1,1) = toc(T_global);
        trig_tag{end+1,1} = 'Ex-off';
        
        %% recovery (Inter-Stim-Iterval) %%%%
        T = tic;
        %%%%%%%%%% record %%%%%%%%%%
        StimContrast(rep,1) = stim.trial_order{rep}.StimColor_Contrast;
        CKB_1{rep,1} = stim.trial_order{rep}.CKB_1{1};
        CKB_2{rep,1} = stim.trial_order{rep}.CKB_2{1};
        StimSize(rep,1) = stim.trial_order{rep}.DegSize;
        Counter(rep,1) = rep;
        Sweep(rep,1) = swp-1;
        OG_LED(rep,1) = OG;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('ITI')
        switch rep == numel(stim.trial_order)
            case 0
                while toc(T)< VS_info.ITI %duration_post = 3
                end
            case 1
                %go to baseline post
        end
        rep = rep+1;
    end

catch
    disp('error@running')
    change_BG(monitor.color.BG, monitor.rect,expWin)
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])
    outputSingleScan(do.TTL.StimTiming,[0,0]) % reset TTL
    outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim stop
end

%% Baseline recording (post)
if VS_info.baseline.on == 1
    
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    trig_globaltime_onset(end+1,1) = toc(T_global);
    trig_tag{end+1,1} = 'BL-Post';
    disp(['Rec. Baseline for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T_global)< VS_info.baseline.rec
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec started.
end
%% save

clear OUTPUT
OUTPUT = table(Counter,StimSize,StimContrast,CKB_1,CKB_2,Sweep,OG_LED);
ExOnGlobalTime = table(trig_tag,trig_globaltime_onset);

matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_CKB_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor','ExOnGlobalTime','OptParams')

end




