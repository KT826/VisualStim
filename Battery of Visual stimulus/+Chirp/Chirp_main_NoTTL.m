function Chirp_main_NoTTL(Params,stim)
disp('Press any key to start'); 
pause
%%
global do
global monitor
global grid
global expWin
global path_save

%%% preset %%%
stim_pix = stim.common.size_pix;
baserect = [0, 0, stim_pix, stim_pix];
centeredRect = CenterRectOnPointd(baserect,stim.common.centroid(1),stim.common.centroid(2));
ptrg0 = ones(1,1);
%%% record time %%%
rep=[1:stim.common.rep]';
Trig_ON=[];
LDAI_ON=[];
LDAI_OFF=[];
FM_ON=[];
FM_OFF=[];
AM_ON=[];
AM_OFF=[];
Trig_OFF=[];

%%
globaltime = tic;
clc
for rep = 1 : stim.common.rep
    %% Pre-stimulus
    disp(['Chirp...#',num2str(rep),'/',num2str(stim.common.rep)])
    Trig_ON(rep,1) = toc(globaltime);
    WaitSecs(Params.time_pre_on);

    %% 1. Light decement and increment 
    %%%% 1.Gray rectangle %%%%
    cwTexture_f1=Screen('MakeTexture',expWin,stim.LDAI.color_bk);
    Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);
    Screen('Flip',expWin);
    WaitSecs(Params.Stim_LDAI.time_on);
    %%%% 2.Black rectangle %%%%
    LDAI_ON(rep,1) = toc(globaltime);
    cwTexture_f1=Screen('MakeTexture',expWin,stim.LDAI.black);
    Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);%P1
    Screen('Flip',expWin);
    WaitSecs(Params.Stim_LDAI.time_on);
    %%%% 3.White rectangle %%%%
    cwTexture_f1=Screen('MakeTexture',expWin,stim.LDAI.white);
    Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);%P1
    Screen('Flip',expWin);
    WaitSecs(Params.Stim_LDAI.time_on);
    %%%% 4.Black rectangle %%%%
    cwTexture_f1=Screen('MakeTexture',expWin,stim.LDAI.black);
    Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);%P1
    Screen('Flip',expWin);
    WaitSecs(Params.Stim_LDAI.time_on);
    LDAI_OFF(rep,1) = toc(globaltime);
    %%%% 5.Gray rectangle %%%%
    cwTexture_f1=Screen('MakeTexture',expWin,stim.LDAI.color_bk);
    Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);
    Screen('Flip',expWin);
    WaitSecs(Params.Stim_LDAI.time_on);

    
    %% 2. Frequency modulation
    FM_ON(rep,1) = toc(globaltime);
    for kk1=1:length(stim.FM.gga0)
        cwTexture_f1=Screen('MakeTexture',expWin,ptrg0*stim.FM.gga0(kk1));
        Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);%P4, gray
        Screen('Flip',expWin);
    end
    FM_OFF(rep,1) = toc(globaltime);

    cwTexture_f1=Screen('MakeTexture',expWin,stim.LDAI.color_bk);
    Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);
    Screen('Flip',expWin);
    WaitSecs(Params.Stim_LDAI.time_on);
    
    %% 3.Amplitude modulation
    AM_ON(rep,1) = toc(globaltime);
    for kk1=1:length(stim.AM.ggb0)
        cwTexture_f1=Screen('MakeTexture',expWin,ptrg0*stim.AM.ggb0(kk1));
        Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);%P4, gray
        Screen('Flip',expWin);
    end
    AM_OFF(rep,1) = toc(globaltime);
    cwTexture_f1=Screen('MakeTexture',expWin,stim.LDAI.color_bk);
    Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);
    Screen('Flip',expWin);
    WaitSecs(Params.Stim_LDAI.time_on);
    
    %% 4.Black rectangle
    cwTexture_f1=Screen('MakeTexture',expWin,stim.LDAI.black);
    Screen('DrawTexture',expWin,cwTexture_f1,[],centeredRect);
    Screen('Flip',expWin);
    WaitSecs(Params.Stim_LDAI.time_on);
    
    %% Post-stimulus
    WaitSecs(Params.time_post_on);
    Trig_OFF(rep,1) =  toc(globaltime);
   
    %% inter-stim-interval
    func.change_BG(monitor.color.BG, monitor.rect,expWin)
    WaitSecs(Params.time_ITI);
    
end


%% save
GlobalTime = table(Trig_ON,LDAI_ON,LDAI_OFF,FM_ON,FM_OFF,AM_ON,AM_OFF,Trig_OFF);

matfiles=what(path_save); matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime); filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
filename = [path_save '/' matfiles_n '_Chirp_' filename_date];
save([filename '.mat'], 'GlobalTime', 'stim', 'grid', 'monitor','Params')

clc
disp('Chirp done')
end
