function [OUTPUT] = run_size_tuning(stim, do, monitor, grid, expWin)
%20/03/01: waitsec をやめて、フレーム数で制御するようにした。

clear rep swp rep
OUTPUT =[]; disp_time =[]; ri = 1; rep = 1;
trig_tag ={};
trig_globaltime_onset =[];
trig_globaltime_offset = [];
if nargin == 6
    spotcolor = repmat(monitor.color.black,[1,3]);
else
    spotcolor = repmat(spotcolor,[1,3]);
end
flipSecs_ON = stim.time.ON;
waitframes_ON = round(flipSecs_ON / monitor.ifi);

%% Baseline recording 
%default 15sec
outputSingleScan(do.TTL.nVoke_Ex,[1,1])% nVoke rec started.
T_global= tic; 
trig_globaltime_onset(end+1,1) = toc(T_global);
disp(['Rec. Baseline for ' num2str(VS_info.baseline.rec), ' sec']); 
while toc(T_global)< VS_info.baseline.rec
end
outputSingleScan(do.TTL.nVoke_Ex,[0,0])% nVoke rec started.
trig_tag{1,1} = 'BL-Pre';
trig_globaltime_offset(end+1,1) = toc(T_global);

%recovering
T= tic;
disp(['Recovery from baseline Rec for ' num2str(VS_info.baseline.rec), ' sec']); 
while toc(T)< VS_info.baseline.recovery
end























%%


clear OUTPUT rep swp

%laser_switch = [];
disp_time =[];
ri = 1;

flipSecs_ON = stim.time.ON;
waitframes_ON = round(flipSecs_ON / monitor.ifi);
flipSecs_OFF = stim.time.ISI;
waitframes_OFF = round(flipSecs_OFF / monitor.ifi);
spotcolor = repmat(stim.color ,[1,3]);

         
%% %%% %run
%try 
    vbl_off = Screen('Flip', expWin); %initial time-stamp
    for rep = 1 : stim.rep
        swp = 1;
        
        while swp <=  size(stim.trial_order{rep},1) 
            stim_deg = stim.trial_order{rep}(swp,2);
            stim_pix = stim.trial_order{rep}(swp,1);
            baserect = [0 0 stim_pix stim_pix];
            centeredRect = CenterRectOnPointd(baserect,stim.Sz_centroid(1),stim.Sz_centroid(2));
            
            
            %%% Prepare Visual stim %%%
            Screen(stim.feature, expWin, spotcolor, centeredRect);
            
            
            %%% stim ON %%%
            vbl_on = Screen('Flip', expWin, vbl_off + (waitframes_OFF - 0.5) * monitor.ifi); % Spot
            outputSingleScan(do.TTL.trigger,[1]) % TTL output   
            outputSingleScan(do.TTL.trigger,[0]) % reset TTL
            outputSingleScan(do.TTL.w,[1]) % TTL output
            
            switch stim.Opt
                case 'on'
                    AO = stim.aovector{rep}{swp,1};
                    AO_Hz = stim.aovector{rep}{swp,2};
                    queueOutputData(ao,AO);  
                    startBackground(ao);
                    %startBackground実行中は別の for/whileループに入れないため、tic-tocで制御する。
                    %pulseは 1-secベクターで作成しているため、 toc＞1　になるまで次ループに進めなくする.
                    tic; 
                case 'off'
                    AO = NaN;
                    AO_Hz = NaN;
                    
            end
            
            disp([num2str(stim_deg), '-deg, '  num2str(swp) '/' num2str(size(stim.trial_order{rep},1)), ' swp, ' ,...
                num2str(rep) '/' num2str(stim.rep) '-rep, Laser: ' num2str(AO_Hz) ' Hz']); %position
           
            
            %%% stim OFF %%%
            switch (stim.time.ISI == 0)
                case 0
                    vbl_off  = Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % BackGround Screenn
                    outputSingleScan(do.TTL.w,[0]) % TTL output
                    OUTPUT{ri,1}.disp_time(1,1) = [ vbl_off - vbl_on ]; 
                    OUTPUT{ri,1}.rep = rep;
                    OUTPUT{ri,1}.swp = swp;
                    OUTPUT{ri,1}.deg = stim_deg;
                    OUTPUT{ri,1}.pix = stim_pix;
                    OUTPUT{ri,1}.centeredRect = centeredRect;
                    OUTPUT{ri,1}.center = stim.Sz_center;
                    OUTPUT{ri,1}.monitor_div = [grid.hight; grid.wide];
                    OUTPUT{ri,1}.feature = stim.feature;
                    OUTPUT{ri,1}.frame(1,1) = waitframes_ON;
                    OUTPUT{ri,1}.frame(1,2) = waitframes_OFF;
                    
                    switch stim.Opt 
                        case 'on'
                            OUTPUT{ri,1}.opt_vector = AO;
                            OUTPUT{ri,1}.opt_Hz = AO_Hz;
                            if toc < 1.1
                                pause(1.1-toc)
                            end
                    end
                    %OUTPUT{1,ri}.laser = 0 or 1;
                case 1
            end
            ri = ri + 1;
            swp = swp + 1;

        end
        
    end
%catch
%    disp('error@running')
%    change_BG(monitor.color.BG, monitor.rect,expWin)
%end

outputSingleScan(do.TTL.trigger,[0]) % reset TTL
outputSingleScan(do.TTL.w,[0]) % reset TTL
outputSingleScan(do.TTL.SE,[0])
%% %save

global path_save
matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_SizeTuning_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor')


end