function [OUTPUT] = run_checkerboard(VS_info, do, monitor, expWin)

flipSecs_ON = VS_info.ON;
waitframes_ON = round(flipSecs_ON / monitor.ifi);
[xCenter, yCenter] = RectCenter(monitor.rect);

% Define a simple X by X checker board
checkerboard_1 = repmat(eye(2), VS_info.n_square_y/2, VS_info.n_square_x/2) * monitor.color.white;
checkerboard_2 = abs(checkerboard_1 - monitor.color.white);
checkerTexture_1 = Screen('MakeTexture', expWin, checkerboard_1);
checkerTexture_2 = Screen('MakeTexture', expWin, checkerboard_2);

%dstRect = [0 0 s1 s2] .* 90;
dstRect = CenterRectOnPointd(monitor.rect, xCenter, yCenter);

% Draw the checkerboard texture to the screen. By default bilinear
% filtering is used. For this example we don't want that, we want nearest
% neighbour so we change the filter mode to zero
filterMode = 0;
VS_info.rep * 2;
sweep = 0;
disp_time = [];
vbl_on = Screen('Flip', expWin);
vbl_on_initial = vbl_on;


%%

outputSingleScan(do.TTL.trigger,[1])% nVoke rec started.
T= tic;
while toc(T)<15
    disp(['baseline_' num2str(toc(T))])
end



try
    while sweep < VS_info.rep * 2
        sweep = sweep + 1;
        switch rem(sweep,2)
            case 1
                Screen('DrawTextures', expWin, checkerTexture_1, [],dstRect, 0, filterMode);
            case 0
                Screen('DrawTextures', expWin, checkerTexture_2, [],dstRect, 0, filterMode);
        end
        
        % Flip to the screen
        vbl_on = Screen('Flip', expWin, vbl_on + (waitframes_ON - 0.5) * monitor.ifi);
        disp(['#Sweep: ' num2str(sweep) '/ ' num2str(VS_info.rep * 2)])
        outputSingleScan(do.TTL.StimTiming1,[1])
        outputSingleScan(do.TTL.StimTiming1,[0])
        disp_time(sweep) = vbl_on;
    end
    
    T= tic;
    while toc(T)<15
        disp(['baseline_post_' num2str(toc(T))])
    end
    outputSingleScan(do.TTL.trigger,[0]) % reset TTL

    OUTPUT.disp_time(1,1) = disp_time(1) - vbl_on_initial;
    OUTPUT.disp_time(2:sweep,1) = disp_time(2:end) - disp_time(1:end-1);
    OUTPUT.checkerboard1 = checkerboard_1;
    OUTPUT.checkerboard2 = checkerboard_2;
    OUTPUT.rep = VS_info.rep * 2;
    OUTPUT.stim_size_deg = VS_info.stim_size;
catch
    disp('error@running')
    change_BG(monitor.color.BG, monitor.rect,expWin)
end
change_BG(monitor.color.BG, monitor.rect,expWin)

%%
%saving
global path_save
matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_Checkerboard_' filename_date];
save([filename '.mat'], 'OUTPUT', 'VS_info', 'monitor')

end