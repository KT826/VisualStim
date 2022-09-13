function [OUTPUT] = nVoke_run_size_tuning(VS_info,stim, OptParams)

clear swp rep
global do
global monitor
global grid
global expWin
global path_save


OUTPUT =[]; disp_time =[]; ri = 1; rep = 1;
trig_tag ={}; trig_globaltime_onset =[]; trig_globaltime_offset = [];
flipSecs_ON = stim.time.ON;
waitframes_ON = round(flipSecs_ON / monitor.ifi);
T_global= tic;

%% Baseline recording 
if VS_info.baseline.on == 1
    
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    trig_globaltime_onset(end+1,1) = toc(T_global);
    disp(['Rec. Baseline for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T_global)< VS_info.baseline.rec
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec started.
    trig_tag{end+1,1} = 'BL-Pre';
    trig_globaltime_offset(end+1,1) = toc(T_global);
    %recovering
    T= tic;
    disp(['Recovery from baseline Rec for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T)< VS_info.baseline.recovery
    end
end


%% %%% %run
try 
    while rep <= stim.rep
        swp = 1;
        while swp <=  size(stim.trial_order{rep},1) 
            %% parameter setting 
            stim_deg = stim.trial_order{rep}.DegSize(swp);
            stim_pix = double(stim.trial_order{rep}.PixSize(swp));
            OG = stim.trial_order{rep}.OG(swp);
            spotcolor = repmat(stim.trial_order{rep}.StimColor(swp),1,3);
            baserect = [0, 0, stim_pix, stim_pix];
            centeredRect = CenterRectOnPointd(baserect,...
                double(stim.trial_order{rep}.CenterCoordinate(swp,1)),...
                double(stim.trial_order{rep}.CenterCoordinate(swp,2)));
            
            Screen(stim.feature, expWin, spotcolor, centeredRect);
        
            
            %% pre stim 
            outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
            T = tic;
            trig_globaltime_onset(end+1,1) = toc(T_global);
            clc
            disp(['Swp.' num2str(swp),'/' num2str(size(stim.trial_order{rep},1)),...
                ' - Rep.' num2str(rep),'/' num2str(stim.rep),' - <Pre Stim.> ']) 
            
            
            %% Opt start
            if OG == 1
                while toc(T) < OptParams.onset
                end
            end
            outputSingleScan(do.TTL.nVoke_OG,[OG,OG])% Opt stim start
            while toc(T)< VS_info.preon %duration_prestim = 1
            end
            toc(T);
            
            %% visual stim ON 
            vbl_on = Screen('Flip', expWin); % Spot
            outputSingleScan(do.TTL.StimTiming,[1,1]) % TTL output
            todisp= [num2str(stim_deg), ' deg, #', num2str(spotcolor(1)), ' color, Opt-' ,num2str(OG)];
           
            disp(['Swp.' num2str(swp),'/' num2str(size(stim.trial_order{rep},1)),...
                ' - Rep.' num2str(rep),'/' num2str(stim.rep),' - <' todisp, '>']) 

            %% visual stim OFF
            vbl_off  = Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % BackGround Screenn
            outputSingleScan(do.TTL.StimTiming,[0,0]) % TTL output
            disp_time(ri,1) = [vbl_off - vbl_on];             
            
            %% post stim & Opt off
            T = tic;
            
            disp(['Swp.' num2str(swp),'/' num2str(size(stim.trial_order{rep},1)),...
                ' - Rep.' num2str(rep),'/' num2str(stim.rep),' - <Post Stim.> ']) 
            while toc(T) < OptParams.offset
            end
            
            outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim stop
            while toc(T)< VS_info.off %duration_post = 3
            end
            outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop.            
            trig_globaltime_offset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'size tuning';
            
            %% recovery (Inter-Stim-Iterval) %%%%
            T = tic;
            
            disp(['ITI, next is... Swp.' num2str(swp),'/' num2str(size(stim.trial_order{rep},1)),...
                ' - Rep.' num2str(rep),'/' num2str(stim.rep)]) 
                        
            %%%%%%%%%% record %%%%%%%%%%
            StimCenterX(ri,1) = double(stim.trial_order{rep}.CenterCoordinate(swp,1));
            StimCenterY(ri,1) = double(stim.trial_order{rep}.CenterCoordinate(swp,2));
            Counter(ri,1) = ri;
            Sweep(ri,1) = swp;
            Rep(ri,1) = rep;
            StimSize(ri,1) = stim_deg;
            StimColor(ri,1) = spotcolor(1);
            OG_LED(ri,1) = OG;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            while toc(T)< VS_info.recovery %duration_post = 3
            end
            %vbl_off = Screen('Flip', expWin); %initial time-stamp
            ri = ri + 1;
            swp = swp + 1;
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
    T= tic; trig_globaltime_onset(end+1,1) = toc(T_global);
    disp(['Rec. Baseline for ' num2str(VS_info.baseline.rec), ' sec']);
    while toc(T)< VS_info.baseline.rec
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop
    trig_globaltime_offset(end+1,1) = toc(T_global);
    trig_tag{end+1,1} = 'BL-Post';
end

%% save
OnStimDispTime= disp_time; %stim_on time
clear OUTPUT
OUTPUT = table(Counter,Rep,Sweep, StimCenterX,StimCenterY,StimSize,StimColor,OG_LED,OnStimDispTime);
ExOnGlobalTime = table(trig_tag,trig_globaltime_onset,trig_globaltime_offset);

matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_SizeTuning_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor','ExOnGlobalTime','OptParams')

end