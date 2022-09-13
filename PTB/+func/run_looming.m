function [OUTPUT] = run_looming(stim, do, monitor, grid, expWin,ao)

clear OUTPUT rep swp
global ao_vector


OUTPUT = [];
waitframes = 1;
nSwp = numel(stim.trial_order_info{1,1}.initial_deg);
TotalSwp = nSwp * stim.rep;
TotalSwp_count = 0;


%% %%% %run: without laser
%try 
    for rep = 1 : stim.rep
        swp = 1;
        
        
        while swp <=  nSwp

            disp(['-----------'])
            TotalSwp_count = TotalSwp_count + 1;
            loomingsize = stim.trial_order_LoomFrame_info{rep}(:,2); %monitor frame–ˆ‚Ìsize‚ðŽæ“¾
            total_frame = numel(loomingsize);
            lmcolor = stim.trial_order_info{1,rep}.LMcolor(swp);
            n_frame = 1;
            time = 0 ;
            
            %%% INTAN trigger start %%%
            outputSingleScan(do.TTL.trigger,[1]) % TTL output   
            outputSingleScan(do.TTL.trigger,[0]) % reset TTL
            
            vbl = Screen('Flip', expWin);            
            
            switch stim.Opt
                case 'on'
                    AO_Hz =  stim.aovector{1,rep}{2,swp};
                    AO = stim.aovector{1, rep}{1,swp};
                    queueOutputData(ao,AO);  
                    startBackground(ao);
                case 'off'
                    AO(1,1:2) = NaN;
                    AO_Hz = NaN;                    
            end
            
            disp(['Swp:' num2str(swp), '/' num2str(nSwp), ', Rep:' num2str(rep), '/', num2str(stim.rep),...
                ', Vel:', num2str(stim.trial_order_info{1,rep}.velocity(swp)), 'deg/sec, Sz:',...
                num2str(stim.trial_order_info{1,rep}.final_deg(swp)), ', Laser:', num2str(AO_Hz), 'Hz']); 
                
            
            outputSingleScan(do.TTL.w,[1]) % TTL output
            while n_frame <= total_frame
                %%% Prepare Visual stim %%%
                baserect = [0 0 loomingsize(n_frame) loomingsize(n_frame)];
                centeredRect = CenterRectOnPointd(baserect,stim.LM_centroid(1),stim.LM_centroid(2));
                Screen(stim.feature, expWin, lmcolor, centeredRect);
                %%% Disp %%%
                vbl_on = Screen('Flip', expWin, vbl + (waitframes - 0.5) * monitor.ifi); % Spot
                time = time + monitor.ifi;
                n_frame = n_frame + 1;
            end
            outputSingleScan(do.TTL.w,[0]) % TTL output
            change_BG(monitor.color.BG, monitor.rect,expWin)
            
            
            disp(['DispTime: ' num2str(time) 's, Now on ISI: ' num2str(stim.time.ISI),'s...'])
            
            %%%% Save info %%%
            OUTPUT{swp,rep}.rep = rep;
            OUTPUT{swp,rep}.swp = swp;
            OUTPUT{swp,rep}.TotalSweep = TotalSwp_count;
            OUTPUT{swp,rep}.CenteredRect_FinalFrame = centeredRect;
            OUTPUT{swp,rep}.Center = stim.LM_center;
            OUTPUT{swp,rep}.monitor_div = [grid.hight; grid.wide];
            OUTPUT{swp,rep}.feature = stim.feature;
            OUTPUT{swp,rep}.LM_Velocity = stim.trial_order_info{1,rep}.velocity(swp);
            OUTPUT{swp,rep}.LM_Size_Final= stim.trial_order_info{1,rep}.final_deg(swp);
            OUTPUT{swp,rep}.LM_Size_Initial= stim.trial_order_info{1,rep}.initial_deg(swp);
            OUTPUT{swp,rep}.LM_DispTime = time; 
            OUTPUT{swp,rep}.LM_Color = lmcolor;
            OUTPUT{swp,rep}.Opt = lmcolor;
            OUTPUT{swp,rep}.Opt = stim.Opt;
            OUTPUT{swp,rep}.Opt_Hz = AO_Hz;
            OUTPUT{swp,rep}.Opt_Vector_Intan = AO(:,1);
            OUTPUT{swp,rep}.Opt_Vector_Laser = AO(:,2);
            OUTPUT{swp,rep}.AnalogOutput_ScanRate = ao.Rate; % /Sec
            %%%%%%%%%%%%%%%%%%%%%
            
            switch TotalSwp_count == TotalSwp
                case 0 
                    pause(stim.time.ISI)
                case 1
            end
            swp = swp + 1;
            
        end
    end
    
%catch
%    disp('error@running')
%    change_BG(monitor.color.BG, monitor.rect,expWin)
%end

%%
%saving
global path_save
matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_Looming_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor')


end