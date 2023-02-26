function Params = SoundOut_params(soundfile,path_base)

InitializePsychSound 
Params.audiofile = [path_base,'/+Sound/soundfiles/', soundfile,'.wav']; 
[Params.wavedata, Params.freq] = psychwavread(Params.audiofile);
Params.Swp = 8; %
Params.on = 2; %sec for sound continuation
Params.ITI = 30;%If Params.Swp > 1, have to be input.
%%%%%%%%%%%%%%%%%%%%%%%%
end