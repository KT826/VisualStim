function [OUTPUT] = RWD_main(Params,stim,OptParams)
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
k = 1; %counter of trial
rep = 1;
trig_tag ={}; 
trig_globaltime_onset =[];
trig_globaltime_offset = [];
T_global= tic;
DATETIME =[];
TotalTrial = numel(stim.trial_order)*size(stim.trial_order{1},1);
MovingBarInfo = {};
%%%%%%%


%% Baseline recording 
if Params.baseline.on == 1
    [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = baseline_pre(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params);
end


%% main loop
try 
    while rep <= stim.rep
        swp = 1;
        
        while swp <=  size(stim.trial_order{rep},1) 
            %% load parameters
            stim_direction = stim.trial_order{rep}.Direction(swp);
            
            %% PreStim(trigger-ON)
            outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
            T = tic;
            trig_globaltime_onset(end+1,1) = toc(T_global);
                      
            while toc(T)< Params.time_pre_on 
            end
            
            %% Visual stim
            %%%%%% visual stim ON %%%%%% 
            outputSingleScan(do.TTL.StimTiming,[1,1]) % TTL output
            todisp= [num2str(stim_direction),'deg'];          
            disp(['Swp.' num2str(swp),'/' num2str(size(stim.trial_order{rep},1)),...
                ' - Rep.' num2str(rep),'/' num2str(stim.rep),' - <' todisp, '>']) 
            MBinfo = MovingBar.MovBarDir(stim_direction,Params.BarWidth,Params.PixPerFrame,monitor.rect(3), monitor.rect(4),expWin,monitor.ifi);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%% visual stim OFF %%%%%%
            outputSingleScan(do.TTL.StimTiming,[0,0]) % TTL output
            OnStimDispTime(k,1) = MBinfo(end,1); 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% PostStim(trigger-OFF)
            T = tic;
            %outputSingleScan(do.TTL.nVoke_OG,[0,0])% Opt stim stop
            while toc(T)< Params.time_post_on 
            end
            outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop.            
            trig_globaltime_offset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'Moving Bar';
            
            %% Inter-Trial-Interval
            T = tic;
            
            %%%%%%%%%% record %%%%%%%%%%
            Counter(k,1) = k;
            Sweep(k,1) = swp;
            Rep(k,1) = rep;
            StimDirection(k,1) = stim_direction;
            file_dt = datevec(datetime);
            filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
            DATETIME(k,1) = str2num(filename_date);
            
            %%%% temporaly save %%%%
            matfiles=what(path_save);
            matfiles_n = num2str(numel(matfiles.mat) + 1);
            OUTPUT = table(Counter,Rep,Sweep,StimDirection,OnStimDispTime,DATETIME);
            MovingBarInfo{k,1} = MBinfo;
            filename_temp = [path_save '/temp/' matfiles_n,'_MovingBar_TempSave'];
            save([filename_temp '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor','Params','MovingBarInfo')
            %%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            k = k + 1;
            swp = swp + 1;
            if k<=TotalTrial
                while toc(T)< Params.time_ITI %duration_post = 3
                end
            end
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
if Params.baseline.on == 1
    [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = ...
    baseline_post(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params)
end
%% save
clear OUTPUT
OUTPUT = table(Counter,Rep,Sweep,StimDirection,OnStimDispTime,DATETIME);
TriggerOnGlobalTime = table(trig_tag,trig_globaltime_onset,trig_globaltime_offset);

matfiles=what(path_save); matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime); filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
filename = [path_save '/' matfiles_n '_MovingBar_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor','Params','MovingBarInfo')

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
