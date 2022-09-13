function [OUTPUT] = nVoke_run_mapping(VS_info, stim, do, monitor, grid, expWin, spotcolor)
%20/03/01: waitsec をやめて、フレーム数で制御するようにした。

OUTPUT =[]; disp_time =[]; ri = 1; rep = 1;
trig_tag ={};
trig_globaltime_onset =[];
trig_globaltime_offset = [];
trig_globaltime =[];

if nargin == 6
    spotcolor = repmat(monitor.color.black,[1,3]);
else
    spotcolor = repmat(spotcolor,[1,3]);
end
flipSecs_ON = stim.time.ON;
waitframes_ON = round(flipSecs_ON / monitor.ifi);


%% Baseline recording 
if VS_info.baseline.on == 1
    %default 15sec
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    T_global= tic; 
    trig_globaltime_onset(end+1,1) = toc(T_global);
    disp(['Rec. Baseline for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T_global)< VS_info.baseline.rec
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec started.
    trig_tag{1,1} = 'BL-Pre';
    trig_globaltime_offset(end+1,1) = toc(T_global);

    %recovering
    T= tic;
    disp(['Recovery from baseline Rec for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T)< VS_info.baseline.recovery
    end
end

%% %%% %run: 
%outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
T_global= tic;            
try 
    while rep <= stim.rep
        swp = 1;
        while swp <=  size(stim.trial_order{rep},1) 
            posiX = grid.position.w_column(stim.trial_order{rep}(swp,1));
            posiY = grid.position.h_column(stim.trial_order{rep}(swp,1));
            posiindex = stim.trial_order{rep}(swp,1);
            Screen(stim.feature, expWin, spotcolor, [posiX - (grid.ls/2), posiY - (grid.ls/2), posiX + (grid.ls/2), posiY + (grid.ls/2)]);
            
            %%%% pre stim %%%%
            outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
            T = tic;
            trig_globaltime_onset(end+1,1) = toc(T_global);
            %disp('pre stim ') 
            while toc(T)< VS_info.preon %duration_prestim = 1
            end

            %vbl_on = Screen('Flip', expWin, vbl_off + (waitframes_OFF - 0.5) * monitor.ifi); % Spot
            vbl_on = Screen('Flip', expWin); % Spot
            outputSingleScan(do.TTL.StimTiming,[1,1]) % TTL output   
            disp(['Posi# ',num2str(posiindex),'/ ',num2str(swp) '/' num2str(size(stim.trial_order{rep},1)), ', ' num2str(rep) '-rep']); %position
            
            %%% stim OFF %%%
            vbl_off  = Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % BackGround Screenn
            outputSingleScan(do.TTL.StimTiming,[0,0]) % TTL output
            trig_globaltime_offset(end+1,1) = toc(T_global);
            disp_time(ri,1) = [vbl_off - vbl_on]; 
            OUTPUT(ri,:) = [ri,swp,rep,stim.trial_order{rep}(swp,2),posiX,posiY,posiindex]; 
            trig_globaltime(end+1,1) =toc(T_global);
            trig_tag{end+1,1} = 'mapping';
            
            %%%% post stim %%%%
            T = tic;
            %disp('post stim')
            while toc(T)< VS_info.off %duration_post = 3
            end
            
            %%%% recovery (Inter-Stim-Iterval) %%%%
            outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop.            
            T = tic;
            %disp(['recovery'])
            while toc(T)< VS_info.recovery %duration_post = 3
            end
            %vbl_off = Screen('Flip', expWin); %initial time-stamp
            ri = ri + 1;
            swp = swp + 1;            
        end
        rep = rep + 1;
    end

catch
    disp('error@running')
    change_BG(monitor.color.BG, monitor.rect,expWin)
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])
    outputSingleScan(do.TTL.StimTiming,[0,0]) % reset TTL
end

%outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop.            
            
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



%% %save
OnStimDispTime= disp_time; %stim_on time
StimCenterX=OUTPUT(:,5); StimCenterY=OUTPUT(:,6);
Counter=OUTPUT(:,1); Sweep=OUTPUT(:,2); Rep=OUTPUT(:,3); StimColor=OUTPUT(:,4);
PositionIndex=OUTPUT(:,7);

clear OUTPUT
OUTPUT = table(Counter,Rep,Sweep,PositionIndex,StimCenterX,StimCenterY,StimColor,OnStimDispTime);
StimInfoGlobal = table(trig_tag,trig_globaltime_onset,trig_globaltime_offset);

global path_save
matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_Mapping_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor','StimInfoGlobal')


end