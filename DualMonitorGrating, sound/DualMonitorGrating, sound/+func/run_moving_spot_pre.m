function [OUTPUT] = run_moving_spot_pre(stim, dio, monitor, grid, expWin)

clear OUTPUT rep swp
%laser_switch = [];
disp_time =[];
ri = 0;

spotcolor = repmat(stim.color ,[1,3]);
    
%% %%% %run: without laser
try 
    for rep = 1 : stim.rep
        for swp = 1 : size(stim.trial_order{rep},1) 
            
            %%%% TTL. timing of each repetitions start%%%%
            %outputSingleScan(dio.TTL.SE,[1]) % TTL output
            %outputSingleScan(dio.TTL.SE,[0]) % reset TTL
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% 初期設定値 %%%
            stim_pix = stim.trial_order{rep}(swp,1); %spotのサイズ(ピクセル）
            baserect = [0 0 stim_pix stim_pix];
            move_pix = stim.pix_per_frame; %frameあたりに動かす ピクセル.
            xxx = 0;
             
            switch stim.moving_direction
                case 'Up2Down'
                    move_end = monitor.rect(4);
                    move_posi = 0;
                    centroid_x = stim.Sz_centroid(1); % x座標. ここを軸に spotが y軸方向に動く.
                    centroid_y = 0;%stim.Sz_centroid(2); % x座標. ここを軸に spotが y軸方向に動く.
                case 'Down2Up'
                    move_end = monitor.rect(4);
                    move_posi = monitor.rect(4);
                    centroid_x = stim.Sz_centroid(1); % x座標. ここを軸に spotが y軸方向に動く.
                    centroid_y = 0;%stim.Sz_centroid(2); % x座標. ここを軸に spotが y軸方向に動く.
                case 'Left2Right'
                    move_end = monitor.rect(3);
                    move_posi = 0;
                    centroid_x = 0; % x座標. ここを軸に spotが y軸方向に動く.
                    centroid_y = stim.Sz_centroid(2);%stim.Sz_centroid(2); % x座標. ここを軸に spotが y軸方向に動く.
                case 'Right2Left'
                    move_end = monitor.rect(3);
                    move_posi = monitor.rect(3);
                    centroid_x = 0; % x座標. ここを軸に spotが y軸方向に動く.
                    centroid_y = stim.Sz_centroid(2);%stim.Sz_centroid(2); % x座標. ここを軸に spotが y軸方向に動く.
            end
            %%%%%%%%%%%%%%%%%
            
            n_disp_frame = 1;
            while move_end > (stim.pix_per_frame * n_disp_frame) %刺激がmonitor幅より短い時にON
                n_disp_frame = n_disp_frame + 1;
                switch stim.moving_direction
                    case 'Up2Down'
                        move_posi = xxx + move_posi;
                        squareYpos = centroid_y + move_posi;
                        squareXpos = centroid_x;
                        move_posi = move_pix + move_posi;
                    case 'Down2Up'
                        move_posi = xxx + move_posi;
                        squareYpos = move_posi - centroid_y;
                        squareXpos = centroid_x;
                        move_posi = move_posi - move_pix;
                    case 'Left2Right'
                        move_posi = xxx + move_posi;
                        squareYpos = centroid_y;
                        squareXpos = centroid_x + move_posi;
                        move_posi = move_pix + move_posi;
                    case 'Right2Left'
                        move_posi = xxx + move_posi;
                        squareYpos = centroid_y;
                        squareXpos = move_posi - centroid_x;
                        move_posi = move_posi - move_pix;
                end
                
                %{
                move_posi = xxx + move_posi;
                squareYpos = centroid_y + move_posi;
                squareXpos = centroid_x;
                %}
              
                % Center the rectangle on the centre of the screen
                centeredRect = CenterRectOnPointd(baserect, squareXpos, squareYpos);
                % Draw the rect to the screen
                Screen('FillRect', expWin, [0 0 0] +200, centeredRect);
                Screen('Flip', expWin);
                %move_posi = move_pix + move_posi;
            end
            change_BG(monitor.color.BG, monitor.rect,expWin)
            WaitSecs(stim.time.ISI)
        end
    end
end

%{
            %%% stim ON %%%
            [StimulusDisplayTime_ON] = Screen('Flip', expWin);
            %outputSingleScan(dio.TTL.k,[1]) % TTL output
            
            %%% stim OFF %%%
            WaitSecs(stim.time.ON);
            %outputSingleScan(dio.TTL.k,[0]) % TTL output
            
            ri = ri + 1;
            switch (stim.time.ISI == 0)
                case 0
                    OUTPUT{ri,1}.rep = rep;
                    OUTPUT{ri,1}.swp = swp;
                    OUTPUT{ri,1}.deg = stim_deg;
                    OUTPUT{ri,1}.pix = stim_pix;
                    OUTPUT{ri,1}.centeredRect = centeredRect;
                    OUTPUT{ri,1}.center = stim.Sz_center;
                    OUTPUT{ri,1}.monitor_div = [grid.hight; grid.wide];
                    OUTPUT{ri,1}..feature = stim.feature;
                    %OUTPUT{1,ri}.laser = 0 or 1;
                    [StimulusDisplayTime_OFF]  = Screen('Flip', expWin); % BackGround Screenn
                    OUTPUT{ri,1}.disp_time = [StimulusDisplayTime_OFF - StimulusDisplayTime_ON]; 
                    %disp(['StimON = ' num2str(OUTPUT{1,ri}.disp_time) 'ms' ])
                    WaitSecs(stim.time.ISI);                       
                case 1
            end
            
        end
    end
catch
    disp('error@running')
    change_BG(monitor.color.BG, monitor.rect,expWin)
end

%% %save

global filenametag 
global path_save
matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_SizeTuning_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor')
%}

end