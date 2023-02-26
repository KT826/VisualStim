function [OUTPUT] = Looming_main(Params,stim,OptParams)

disp('Press any key to start'); 
pause
%%
global do
global monitor
global grid
global expWin
global path_save

%%% preset %%%
OUTPUT = [];
OnStimDispTime =[];
TotalTrial = stim.rep;
k = 1;
trig_tag ={};
trig_globaltime_onset =[];
trig_globaltime_offset = [];
T_global= tic;

flipSecs_ON = 0.25;
waitframes_ON = round(flipSecs_ON / monitor.ifi);

%% Baseline recording 
if Params.baseline.on == 1
    [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = baseline_pre(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params);
end

%% main loop
try 
    for rep = 1 : TotalTrial
        %% load parameters
        loomingsize = stim.trial_order_LMframeInfo{rep}(:,2); %monitor frame����size������
        total_frame = numel(loomingsize);
        lmcolor = stim.trial_order{1,rep}.LMcolor;
        n_frame = 1;
        time = 0 ;
        vbl = Screen('Flip', expWin);            
        
        %% PreStim(trigger-ON)
        outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
        T = tic;
        trig_globaltime_onset(end+1,1) = toc(T_global);
        
        %{
        %%%%%% Start Opt Stim(optional) %%%%%%
        if OG == 1
            while toc(T) < OptParams.onset
            end
        end
        %outputSingleScan(do.TTL.nVoke_OG,[OG,OG])% Opt stim start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %}
        while toc(T)< Params.time_pre_on 
        end
        
        %% Visual stim
        %%%%%% visual stim ON %%%%%%
        disp(['Looming...Swp:' num2str(rep), '/', num2str(TotalTrial)])
          
        outputSingleScan(do.TTL.StimTiming,[1,1])
        tic
        while n_frame <= total_frame
            %%% Prepare Visual stim %%%
            baserect = [0 0 loomingsize(n_frame) loomingsize(n_frame)];
            centeredRect = CenterRectOnPointd(baserect,stim.LM_centroid(1),stim.LM_centroid(2));
            Screen(stim.feature, expWin, lmcolor, centeredRect);
            %%% Disp %%%
            vbl_on = Screen('Flip', expWin, vbl + (waitframes_ON - 0.5) * monitor.ifi); % Spot
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
        trig_tag{end+1,1} = 'looming';
        
        %% Inter-Trial-Interval
        T = tic;
        %%%% temporaly save %%%%        
        Counter(k,1) = k;
        StimCenterX(k,1) = double(stim.LM_centroid(1));
        StimCenterY(k,1) = double(stim.LM_centroid(2));
        StimSizeFirst(k,1) = stim.trial_order{k}.initial_deg;
        StimSizeLast(k,1) = stim.trial_order{k}.final_deg;
        OnStimDispTime(k,1) = time; %stim_on time
        StimColor(k,1) = lmcolor;
        file_dt = datevec(datetime);
        filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
        DATETIME(k,1) = str2num(filename_date);

        %%%% temporaly save %%%%
        matfiles=what(path_save);
        matfiles_n = num2str(numel(matfiles.mat) + 1);
        OUTPUT = table(Counter,StimCenterX,StimCenterY,StimSizeFirst,StimSizeLast,OnStimDispTime,StimColor,DATETIME);
        filename_temp = [path_save '/temp/' matfiles_n,'_Looming_TempSave'];
        save([filename_temp '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor','OptParams')
        %%%%%%%%%%%%%%%%%%%%%
        
        k = k + 1;
        if k<=TotalTrial
            disp('ISI')
            while toc(T)< Params.time_ITI %duration_post = 3
            end
        end
            
    end
catch
    disp('error@running')
    func.change_BG(monitor.color.BG, monitor.rect,expWin)
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])
    outputSingleScan(do.TTL.StimTiming,[0,0]) % reset TTL
    outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim stop
end

%% Baseline recording (post)
if Params.baseline.on == 1
    [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = ...
    baseline_post(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params)
end
%% save
clear OUTPUT
OUTPUT = table(Counter,StimCenterX,StimCenterY,StimSizeFirst,StimSizeLast, OnStimDispTime,StimColor,DATETIME);
TriggerOnGlobalTime = table(trig_tag,trig_globaltime_onset,trig_globaltime_offset);

matfiles=what(path_save); matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime); filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
filename = [path_save '/' matfiles_n '_Looming_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor','TriggerOnGlobalTime','OptParams')

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
