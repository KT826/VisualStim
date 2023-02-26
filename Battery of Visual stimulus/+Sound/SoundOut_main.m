function SoundOut_main(Params)
global do
global path_save

%%%%%%%%
%%% preset %%%
soundouttime = [];
StartTime = [];
EndTime = [];
wavedata = Params.wavedata';
freq = Params.freq;


%%
disp('press any key to start Audio Stim.')
pause
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
StartTime = str2num(filename_date);
TAKENTIME = tic;

for k = 1 : Params.Swp
    
    %% preparation-1 %%%%
    InitializePsychSound;
    repetitions = 0;
    nrchannels = size(wavedata,1); % Number of rows == number of channels.
    if nrchannels < 2
        wavedata = [wavedata ; wavedata];
        nrchannels = 2;
    end
    device = [];
    InitializePsychSound;
    pahandle = PsychPortAudio('Open', device, [], 0, freq, nrchannels);
    clc
    
    %% Sound out %%%%
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    pause(5)
    outputSingleScan(do.TTL.nVoke_AUDIO,[1,1])% audio TTL
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1);
    at = tic
    while toc(at)<Params.on
    end
    toc(at)
    outputSingleScan(do.TTL.nVoke_AUDIO,[0,0])% audio TTL
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);
    pause(8)
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1]*0)% nVoke rec started.
    
    %% Inter-stimulus-Interval
    t_isi = tic;
    if k<Params.Swp
        while toc(t_isi)<=Params.ITI
        end
    end
end


soundouttime = toc(TAKENTIME);
file_dt = datevec(datetime);
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
EndTime = str2num(filename_date);

%% save
matfiles=what(path_save); matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime); filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
filename = [path_save '/' matfiles_n '_Sound_' filename_date];
TimeInfo_SoundOut = table(soundouttime,StartTime,EndTime);
Params.date = date;
save([filename '.mat'], 'TimeInfo_SoundOut','Params')

end

