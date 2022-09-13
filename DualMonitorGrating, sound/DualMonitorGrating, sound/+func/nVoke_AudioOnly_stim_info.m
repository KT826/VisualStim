function [stim] = nVoke_AudioOnly_stim_info(AUD_info)

stim=[];

%%
AUD_info.wavedata = AUD_info.wavedata';


%%
TrialOrder = [repmat(0,AUD_info.rep ,1);repmat(1,AUD_info.rep ,1)];
TrialOrder = TrialOrder(randperm(numel(TrialOrder)));


end