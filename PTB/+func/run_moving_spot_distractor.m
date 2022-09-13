function [OUTPUT] = run_moving_spot_distractor(stim, dio, monitor, grid, expWin)

clear OUTPUT rep swp
disp_time =[];
ri = 0;
spotcolor = repmat(stim.color ,[1,3]);
    
%% %%% %run: without laser
try 
    for rep = 1 : stim.rep
        for swp = 1 : size(stim.trial_order_pix{rep},1) 
            ri = ri + 1;
            %%%% TTL. timing of each repetitions start%%%%
            %outputSingleScan(dio.TTL.SE,[1]) % TTL output
            %outputSingleScan(dio.TTL.SE,[0]) % reset TTL
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% 初期設定値 %%%
            stim_pix = stim.trial_order_pix{rep}(swp,1); %spotのサイズ(ピクセル）
            baserect = [0 0 stim_pix stim_pix];
            move_pix = stim.trial_order_pix{rep}(swp,3); %frameあたりに動かす ピクセル.
            centroid_x = stim.trial_order_pix{rep}(swp,4);
            centroid_y = stim.trial_order_pix{rep}(swp,5);
            spot_color = stim.trial_order_pix{rep}(swp,6);
            moving_direction = stim.trial_order_pix{rep}(swp,7); %1:'Up2Down'; 2:'Down2Up'; 3:'Left2Right' ; 4:'Right2Left'
            switch moving_direction
                case 1
                    moving_direction = 'Up2Down';
                case 2
                    moving_direction = 'Down2Up';
                case 3
                    moving_direction = 'Left2Right';
                case 4
                    moving_direction = 'Right2Left';
            end
                    
            xxx = 0;
            deg_obj = stim.trial_order_deg{rep}(swp,1);
            deg_vel = stim.trial_order_deg{rep}(swp,2);
            disp([num2str(ri) '; ' num2str(deg_obj) ' deg; ' num2str(deg_vel) ' dps;  ' moving_direction])
            
            switch moving_direction
                case 'Up2Down'
                    move_end = monitor.rect(4);
                    move_posi = 0;
                    centroid_x = centroid_x; % x座標. ここを軸に spotが y軸方向に動く.
                    centroid_y = 0;%stim.Sz_centroid(2); % x座標. ここを軸に spotが y軸方向に動く.
                case 'Down2Up'
                    move_end = monitor.rect(4);
                    move_posi = monitor.rect(4);
                    centroid_x = centroid_x; % x座標. ここを軸に spotが y軸方向に動く.
                    centroid_y = 0;%stim.Sz_centroid(2); % x座標. ここを軸に spotが y軸方向に動く.
                case 'Left2Right'
                    move_end = monitor.rect(3);
                    move_posi = 0;
                    centroid_x = 0; % x座標. ここを軸に spotが y軸方向に動く.
                    centroid_y = centroid_y;
                case 'Right2Left'
                    move_end = monitor.rect(3);
                    move_posi = monitor.rect(3);
                    centroid_x = 0; % x座標. ここを軸に spotが y軸方向に動く.
                    centroid_y = centroid_y;
            end
            %%%%%%%%%%%%%%%%%
            
            n_disp_frame = 1;
            timestanp.start = Screen('Flip',expWin);
            %outputSingleScan(dio.TTL.w,[1]) % TTL output
            while move_end > (move_pix * n_disp_frame) %刺激がmonitor幅より短い時にON
                n_disp_frame = n_disp_frame + 1;
                switch moving_direction
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
                %%%% Center of rectangle on the centre of the screen %%%%
                centeredRect_1 = CenterRectOnPointd(baserect, squareXpos, squareYpos);
                centeredRect_2 = CenterRectOnPointd(baserect, squareXpos+200, squareYpos);
                spot_color = 0; %[spot_color; spot_color];
                % Draw the rect to the screen
                Screen(stim.feature, expWin, spot_color, centeredRect_1);
                Screen(stim.feature, expWin, spot_color, centeredRect_2);
                
                timestanp.end = Screen('Flip', expWin);
                %move_posi = move_pix + move_posi;
            end
            %outputSingleScan(dio.TTL.w,[0]) % TTL output
            change_BG(monitor.color.BG, monitor.rect,expWin)
            OUTPUT{ri,1}.rep = rep;
            OUTPUT{ri,1}.swp = swp;
            OUTPUT{ri,1}.feature = stim.feature;
            OUTPUT{ri,1}.color_feature = spot_color;
            OUTPUT{ri,1}.color_BG = monitor.color.BG';
            OUTPUT{ri,1}.deg = stim.trial_order_deg{rep}(swp,1);
            OUTPUT{ri,1}.pix = stim_pix;
            OUTPUT{ri,1}.centroid = [centroid_x , centroid_y];
            OUTPUT{ri,1}.monitor_div = [grid.hight; grid.wide];
            OUTPUT{ri,1}.moving_direction = moving_direction;
            OUTPUT{ri,1}.moving_velocity_deg = stim.trial_order_deg{rep}(swp,2);
            OUTPUT{ri,1}.moving_velocity_pix = stim.trial_order_pix{rep}(swp,2);
            OUTPUT{ri,1}.disp_time = [(timestanp.end-timestanp.start)];
            WaitSecs(stim.time.ISI);
        end
    end
    
catch
    disp('error@running')
    change_BG(monitor.color.BG, monitor.rect,expWin)
end

%outputSingleScan(dio.TTL.start,[1]) % TTL output   
%outputSingleScan(dio.TTL.start,[0]) % reset TTL
%outputSingleScan(dio.TTL.w,[0]) % reset TTL
%outputSingleScan(dio.TTL.SE,[0]) % reset TTL
%% %save

global path_save
matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_Moving_spot_' filename_date];
save([filename '.mat'], 'OUTPUT', 'stim', 'grid', 'monitor')
%}
%%
end