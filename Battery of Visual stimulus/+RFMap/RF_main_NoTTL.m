function [OUTPUT] = RF_main_NoTTL(Params,stim,OptParams)
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
trig_globaltime =[];
T_global= tic;
flipSecs_ON = stim.time.ON;
waitframes_ON = round(flipSecs_ON / monitor.ifi);
DATETIME =[];
TotalTrial = numel(stim.trial_order)*size(stim.trial_order{1},1);
%%%%%%%

%% Baseline recording 
if Params.baseline.on == 1
    [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = baseline_pre(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params);
end


%% main loop

if strcmp(Params.TTL_TrigMode,'continuous') 
    %outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])
end

Params.TTL_TrigMode == 'continuous'; % 'continuous' or 'momentary'
try 
    while rep <= stim.rep
        swp = 1;
        
        while swp <=  size(stim.trial_order{rep},1) 
            %% load parameters
            posiX = grid.position.w_column(stim.trial_order{rep}(swp,1));
            posiY = grid.position.h_column(stim.trial_order{rep}(swp,1));
            posi_index = stim.trial_order{rep}(swp,1);
            spotcolor = repmat(stim.color(swp),[1,3]);
            Screen(stim.feature, expWin, spotcolor, [posiX - (grid.ls/2), posiY - (grid.ls/2), posiX + (grid.ls/2), posiY + (grid.ls/2)]);
            
            
            %% PreStim(trigger-ON)  
            if strcmp(Params.TTL_TrigMode,'momentary')
                %outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])
            end

            T = tic;
            trig_globaltime_onset(end+1,1) = toc(T_global);
            
            while toc(T)< Params.time_pre_on 
            end
            
            %% Visual stim
            %%%%%% visual stim ON %%%%%% 
            vbl_on = Screen('Flip', expWin); % Spot
            %outputSingleScan(do.TTL.StimTiming,[1,1]) % TTL output   
            disp(['Posi#',num2str(posi_index),', sweep#',num2str(swp) ', #Rep:', num2str(rep),...
                '/' num2str(size(stim.trial_order,2))]); %position
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%% visual stim OFF %%%%%%
            vbl_off  = Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % BackGround Screenn
            %outputSingleScan(do.TTL.StimTiming,[0,0]) % TTL output 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            %% PostStim(trigger-OFF)
            T = tic;
            while toc(T)< Params.time_post_on 
            end
            if strcmp(Params.TTL_TrigMode,'momentary')
                %outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])
            end
            trig_globaltime_offset(end+1,1) = toc(T_global);
            trig_tag{end+1,1} = 'size tuning';
            
            %% Inter-Trial-Interval
            T = tic;
            
            %%%%%%%%%% record %%%%%%%%%%
            StimCenterX(k,1) = posiX;
            StimCenterY(k,1) = posiY;
            PositionIndex(k,1) = posi_index;
            OnStimDispTime(k,1) = [vbl_off - vbl_on];
            Counter(k,1) = k;
            Sweep(k,1) = swp;
            Rep(k,1) = rep;
            StimColor(k,1) = spotcolor(1);
            file_dt = datevec(datetime);
            filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
            DATETIME(k,1) = str2num(filename_date);
            
            %%%% temporaly save %%%%
            matfiles=what(path_save);
            matfiles_n = num2str(numel(matfiles.mat) + 1);
            OUTPUT = table(Counter,Rep,Sweep, StimCenterX,StimCenterY,StimColor,OnStimDispTime,DATETIME);
            filename_temp = [path_save '/temp/' matfiles_n,'_RF_TempSave'];
            save([filename_temp '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor')
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

if strcmp(Params.TTL_TrigMode,'momentary')
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])
end


%% Baseline recording (post)
if Params.baseline.on == 1
    [trig_tag,trig_globaltime_onset,trig_globaltime_offset] = ...
    baseline_post(do,trig_tag,T_global,trig_globaltime_onset,trig_globaltime_offset,Params)
end

%% save
clear OUTPUT
OUTPUT = table(Counter,Rep,Sweep, StimCenterX,StimCenterY,StimColor,OnStimDispTime,DATETIME);
TriggerOnGlobalTime = table(trig_tag,trig_globaltime_onset,trig_globaltime_offset);
file_dt = datevec(datetime); filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
filename = [path_save '/' matfiles_n '_RF_' filename_date];
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
