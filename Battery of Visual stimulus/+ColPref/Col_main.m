function [OUTPUT] = Col_main(Params,stim)
disp('Press any key to start'); 
pause
%%
global do
global monitor
global grid
global expWin
global path_save
%%% preset %%%
OUTPUT =[];
OnStimDispTime =[];
trig_tag ={}; 
trig_globaltime_onset =[];
trig_globaltime_offset = [];
T_global= tic;
DATETIME =[];
TotalTrial = numel(stim.trial_order)*size(stim.trial_order{1},1);

TTL_find = stim.trial_frameInfo.TTL_tag;
TTL_find(:,2) = [0;diff(TTL_find(:,1))];
TTL_ONframe = find(TTL_find(:,2)== 1);
TTL_OFFframe = find(TTL_find(:,2)== -1);
%%%%%%%

%% Baseline recording 
if Params.baseline.on == 1
    [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = baseline_pre(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params);
end

%% main loop
try 
    for swp = 1 : TotalTrial
        %% load parameters
        stim_deg = stim.trial_order{swp}.DegSize;
        stim_pix = double(stim.trial_order{swp}.PixSize);
        baserect = [0, 0, stim_pix, stim_pix];
        centeredRect = CenterRectOnPointd(baserect,...
            double(stim.trial_order{swp}.CenterCoordinate(1)),...
            double(stim.trial_order{swp}.CenterCoordinate(2)));
        
        total_frame = size(stim.trial_frameInfo,1);
        n_frame = 1;
        time = 0 ;
        vbl = Screen('Flip', expWin); 
        
        %% PreStim(trigger-ON)
        outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
        T = tic;
        trig_globaltime_onset(end+1,1) = toc(T_global);
        
        %%%%%% Start Opt Stim(optional) %%%%%%
        %{
        if OG == 1
            while toc(T) < OptParams.onset
            end
        end
        %}
        %outputSingleScan(do.TTL.nVoke_OG,[OG,OG])% Opt stim start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        while toc(T)< Params.time_pre_on 
        end
        
        %% Visual stim
        tic
        disp(['Color Preference...Swp:' num2str(swp), '/', num2str(TotalTrial)])
        outputSingleScan(do.TTL.StimTiming,[1,1])
        while n_frame <= total_frame
            %%% Prepare Visual stim %%%
            Col = stim.trial_frameInfo.Col_rgb{n_frame};
            Screen(stim.feature, expWin, Col, centeredRect);
            %%% TTL %%%
            if ismember(n_frame,TTL_ONframe)
                outputSingleScan(do.TTL.StimTiming_sub,[1,1]) % TTL-1
            elseif ismember(n_frame,TTL_OFFframe)
                outputSingleScan(do.TTL.StimTiming_sub,[0,0]) % TTL-0
            end
            %%% Disp %%%
            vbl_on = Screen('Flip', expWin, vbl * monitor.ifi); % Spot
            time = time + monitor.ifi;
            n_frame = n_frame + 1;
        end
        
        outputSingleScan(do.TTL.StimTiming,[0,0])
        func.change_BG(monitor.color.BG, monitor.rect,expWin)
        toc

        %% PostStim(trigger-OFF)
        T = tic;
        %while toc(T) < OptParams.Offset
        %end
        
        %outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim stop
        while toc(T)< Params.time_post_on 
        end
        outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop.
        trig_globaltime_offset(end+1,1) = toc(T_global);
        trig_tag{end+1,1} = 'size tuning';
        
        %% Inter-Trial-Interval
        T = tic;
        
        %%%%%%%%%% record %%%%%%%%%%
        StimCenterX(swp,1) = double(stim.trial_order{swp}.CenterCoordinate(1));
        StimCenterY(swp,1) = double(stim.trial_order{swp}.CenterCoordinate(2));
        Sweep(swp,1) = swp;
        StimSize(swp,1) = stim_deg;
        file_dt = datevec(datetime);
        filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
        DATETIME(swp,1) = str2num(filename_date);
        OnStimDispTime(swp,1) = time; %stim_on time
        %%%% temporaly save %%%%
        matfiles=what(path_save);
        matfiles_n = num2str(numel(matfiles.mat) + 1);
        OUTPUT = table(Sweep, StimCenterX,StimCenterY,StimSize,OnStimDispTime,DATETIME);
        filename_temp = [path_save '/temp/' matfiles_n,'_ColPref_TempSave'];
        save([filename_temp '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor')
        %%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if swp<TotalTrial
            while toc(T)< Params.time_ITI %duration_post = 3
            end
        end
    end
 
catch
    disp('error@running')
    change_BG(monitor.color.BG, monitor.rect,expWin)
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])
    outputSingleScan(do.TTL.StimTiming,[0,0]) % reset TTL
    outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim stop
end
%%
%% Baseline recording (post)
if Params.baseline.on == 1
    [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = ...
    baseline_post(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params)
end

%% save
clear OUTPUT
OUTPUT = table(Sweep, StimCenterX,StimCenterY,StimSize,OnStimDispTime,DATETIME);
TriggerOnGlobalTime = table(trig_tag,trig_globaltime_onset,trig_globaltime_offset);

matfiles=what(path_save); matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime); filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
filename = [path_save '/' matfiles_n '_ColPref_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor','TriggerOnGlobalTime')
end

%% local functions
function [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = ...
    baseline_pre(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params)

outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
trig_globaltime_onset(end+1,1) = toc(T_global);
disp(['Rec. Baseline for ' num2str(Params.baseline.rec), ' sec']); 
while toc(T_global)< Params.baseline.rec
end
outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec started.
trig_tag{end+1,1} = 'BL-Pre';
trig_globaltime_offset(end+1,1) = toc(T_global);
T= tic;
disp(['Recovery from baseline Rec for ' num2str(Params.baseline.rec), ' sec']); 
while toc(T)< Params.baseline.recovery
end
end


function [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = ...
    baseline_post(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params)

    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    T= tic; 
    trig_globaltime_onset(end+1,1) = toc(T_global);
    disp(['Rec. Baseline for ' num2str(Params.baseline.rec), ' sec']);
    while toc(T)< Params.baseline.rec
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop
    trig_globaltime_offset(end+1,1) = toc(T_global);
    trig_tag{end+1,1} = 'BL-Post';
end
