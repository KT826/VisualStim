function nVoke_run_AudioOutOnly(do, AUD_info)

%%
OUTPUT =[];
trig_tag ={};
trig_globaltime_onset =[];
trig_globaltime_offset = [];

wavedata = AUD_info.wavedata';
freq = AUD_info.freq;
 T_global= tic;
%% Baseline recording 
if AUD_info.baseline.on == 1
    %default 15sec
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started. 
    trig_globaltime_onset(end+1,1) = toc(T_global);
    disp(['Rec. Baseline for ' num2str(VS_info.baseline.rec), ' sec']); 
    while toc(T_global)< AUD_info.baseline.rec
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec started.
    trig_tag{1,1} = 'BL-Pre';
    trig_globaltime_offset(end+1,1) = toc(T_global);

    %recovering
    T= tic;
    disp(['Recovery from baseline Rec for ' num2str(AUD_info.baseline.rec), ' sec']); 
    while toc(T)< AUD_info.baseline.recovery
    end
end

%% main
for rep = 1 : AUD_info.rep
    
    %% preparation
    repetitions = 0;
    nrchannels = size(wavedata,1); % Number of rows == number of channels.
    if nrchannels < 2
        wavedata = [wavedata ; wavedata];
        nrchannels = 2;
    end
    device = [];
    InitializePsychSound;
    pahandle = PsychPortAudio('Open', device, [], 0, freq, nrchannels);
    
    %% pre stim %%%%
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    T = tic;
    trig_globaltime_onset(end+1,1) = toc(T_global); 
    while toc(T)< AUD_info.preon %duration_prestim = 1
    end

    %% Sound out %%%%
    outputSingleScan(do.TTL.nVoke_AUDIO,[1])% audio TTL
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1);
    at = tic
    while toc(at)<AUD_info.on
    end
    outputSingleScan(do.TTL.nVoke_AUDIO,[0])% audio TTL
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);
    
    %% post stim
    T = tic;
    while toc(T) < AUD_info.off
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop.
    trig_globaltime_offset(end+1,1) = toc(T_global);
    trig_tag{end+1,1} = 'Audio';
    
    %% recovery (Inter-Stim-Iterval) %%%%
    T = tic;
    disp(['ITI'])
    while toc(T)< AUD_info.recovery %duration_post = 3
    end
end

%% Baseline recording (post)
if AUD_info.baseline.on == 1
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    T= tic; trig_globaltime_onset(end+1,1) = toc(T_global);
    disp(['Rec. Baseline for ' num2str(VS_info.baseline.rec), ' sec']);
    while toc(T)< AUD_info.baseline.rec
    end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop
    trig_globaltime_offset(end+1,1) = toc(T_global);
    trig_tag{end+1,1} = 'BL-Post';
end

%% %save
StimInfoGlobal = table(trig_tag,trig_globaltime_onset,trig_globaltime_offset);

global path_save
matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];

filename = [path_save '/' matfiles_n '_AUD_' filename_date];
save([filename '.mat'], 'filename_date','StimInfoGlobal','AUD_info')
end