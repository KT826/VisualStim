function [OUTPUT,laser_switch] = run_sparse_stim(stim, dio, monitor, grid_STA, expWin, ~)
%20/03/03: frame数で制御する。 isiは 0とすること.
clear rep swp ri OUTPUT laser_switch laser_switch_n disp_time

ri = 1;
rep = 1;
XXX=tic;
laser_switch = [];
   
flipSecs_ON = stim.time.ON
waitframes_ON = round(flipSecs_ON / monitor.ifi)

outputSingleScan(dio.TTL.w,[0])
outputSingleScan(dio.TTL.k,[0])
%outputSingleScan(dio.TTL.SE,[0]) 

%% %%% %run: without laser
if nargin == 5  
    try 
        vbl_on = Screen('Flip', expWin); %initial time-stamp
        vbl_on_initial = vbl_on;
        while rep <= stim.rep
            swp = 1;
            
            %%%% TTL. timing of each repetitions start%%%%
            outputSingleScan(dio.TTL.SE,[1]) % TTL output
            outputSingleScan(dio.TTL.SE,[0]) % reset TTL
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            while swp <= size(stim.trial_order{rep},1) 
                posiX = grid_STA.position.w_column(stim.trial_order{rep}(swp,1));
                posiY = grid_STA.position.h_column(stim.trial_order{rep}(swp,1));
                Screen(stim.feature, expWin, repmat(stim.trial_order{rep}(swp,2),[1,3]), [posiX - (grid_STA.ls/2), posiY - (grid_STA.ls/2), posiX + (grid_STA.ls/2), posiY + (grid_STA.ls/2)]);
               
                vbl_on = Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % Spot
                
                switch stim.trial_order{rep}(swp,2)
                    case monitor.color.white
                        outputSingleScan(dio.TTL.k,[0]) % TTL output
                        outputSingleScan(dio.TTL.w,[1]) % TTL output
                    case monitor.color.black
                        outputSingleScan(dio.TTL.w,[0]) % TTL output
                        outputSingleScan(dio.TTL.k,[1]) % TTL output
                end
                
                disp_time(ri,1) = [vbl_on]; 
                OUTPUT(ri,:) = [ri,swp,rep,stim.trial_order{rep}(swp,2),posiX,posiY]; %intervalの時間も含まれ
  
                swp = swp + 1;
                ri = ri + 1;
            end
            rep = rep + 1;
        end
        Screen('FillRect', expWin, monitor.color.BG, monitor.rect);
        Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % Spot
    catch
        disp('error@running')
        change_BG(monitor.color.BG, monitor.rect,expWin)
    end
end


%% %%% %run: with laser
%%%%%%
if nargin == 6
    %global laser
    %laser;
    TIME = tic;
    laser_switch_n = 1;
    
    laser_off = 5;
    laser_preVS = .5;
    
    try 
        while rep <= stim.rep
            
            swp = 1;            
            %%%% TTL. timing of each repetitions start%%%%
            %outputSingleScan(dio.TTL.SE,[1]) % TTL output
            %outputSingleScan(dio.TTL.SE,[0]) % reset TTL
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            while swp <= size(stim.trial_order{rep},1) 
                
                %%%
                %opt 制御.
                %visaul stim (32ms)時間 < laser on 時間, であればここで制御可能.
                %contineuousの場合(1s stimu + 2s interval).ひとまず外部刺激装置でpulseコントロール.
                %parameta: [10Hz,10ms], [20Hz,10ms] , [40Hz,10ms] x 4sec~
                %((rep:10))
                %5.5秒当てて、5秒休む
                
                if ri == 1
                    disp('TTL_on')
                    %outputSingleScan(dio.TTL.OPT,[1]) % TTL output
                    %outputSingleScan(dio.TTL.OPT,[0]) % TTL output
                    TIMER = tic;
                    WaitSecs(laser_preVS);
                    vbl_on = Screen('Flip', expWin); %initial time-stamp
                    vbl_on_initial = vbl_on;
                elseif toc(TIMER) >=  (laser_off + laser_preVS)
                    %backgroundを表示.
                    Screen('FillRect', expWin, monitor.color.BG');
                    Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % Spot
                    
                    switch stim.trial_order{rep}(swp,2)
                        case monitor.color.white
                            %outputSingleScan(dio.TTL.k,[0]) % TTL output
                        case monitor.color.black
                            %outputSingleScan(dio.TTL.w,[0]) % TTL output
                    end
                    
                    disp('TTL_off')
                    %outputSingleScan(dio.TTL.OPT,[0]) % TTL output
                    WaitSecs(laser_off);
                    %outputSingleScan(dio.TTL.OPT,[1]) % TTL output
                    %outputSingleScan(dio.TTL.OPT,[0]) % TTL output
                    disp('TTL_on')
                    TIMER = tic;
                    WaitSecs(laser_preVS);
                    vbl_on = Screen('Flip', expWin); %initial time-stamp  
                    laser_switch(laser_switch_n,1:2)= [rep; swp];
                    laser_switch(laser_switch_n,3)=  vbl_on;
                    laser_switch_n = laser_switch_n+ 1;
                end
                %%%
                
                posiX = grid_STA.position.w_column(stim.trial_order{rep}(swp,1));
                posiY = grid_STA.position.h_column(stim.trial_order{rep}(swp,1));
                Screen(stim.feature, expWin, repmat(stim.trial_order{rep}(swp,2),[1,3]), [posiX - (grid_STA.ls/2), posiY - (grid_STA.ls/2), posiX + (grid_STA.ls/2), posiY + (grid_STA.ls/2)]);
                
                %%% stim ON %%%
                vbl_on = Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % Spot
                %toc(TIMER);
                switch stim.trial_order{rep}(swp,2)
                    case monitor.color.white
                        %outputSingleScan(dio.TTL.k,[0]) % TTL output
                        %outputSingleScan(dio.TTL.w,[1]) % TTL output
                    case monitor.color.black
                        %outputSingleScan(dio.TTL.w,[0]) % TTL output
                        %outputSingleScan(dio.TTL.k,[1]) % TTL output
                end
                
                disp_time(ri,1) = [vbl_on]; 
                OUTPUT(ri,:) = [ri,swp,rep,stim.trial_order{rep}(swp,2),posiX,posiY]; %intervalの時間も含まれ
                
                ri = ri + 1;
                swp = swp + 1;
            end
            rep = rep + 1;
        end
        
        Screen('FillRect', expWin, monitor.color.BG, monitor.rect);
        Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi); % Spot
    catch
        disp('error@running')
    end
end

%%
outputSingleScan(dio.TTL.w,[0])
outputSingleScan(dio.TTL.k,[0])
outputSingleScan(dio.TTL.SE,[0]) 

%%%save%%%%
toc(XXX)
OUTPUT(1,7) = disp_time(1) - vbl_on_initial;
OUTPUT(2:end,7) = disp_time(2:end,1) - disp_time(1:end-1,1);
OUTPUT(1:end,8) = NaN;
if nargin == 6
    for i = 1 : size(laser_switch,1)
        id = laser_switch(i,2);
        OUTPUT(id,7) = disp_time(id) - laser_switch(i,3);
    end
end
%%%%%%%%%%%

global filenametag 
global path_save
matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];


if nargin == 5
    filename = [path_save '/' matfiles_n '_STAcontrol_' filename_date];
    save([filename '.mat'], 'OUTPUT', 'stim', 'grid_STA', 'monitor')
elseif nargin == 6
    filename = [path_save '/' matfiles_n '_STAlaser_' filename_date];
    save([filename '.mat'], 'OUTPUT', 'stim', 'grid_STA', 'monitor','laser_switch')
end


end

