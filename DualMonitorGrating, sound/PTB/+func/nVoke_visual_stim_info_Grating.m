function [stim] = nVoke_visual_stim_info_SinGrating(VS_info,Opt)

%update: 2022/01/14: change the format of stim -> table

global monitor
global grid
%%
stim=[];

stim.Opt = Opt; 
stim.rep = VS_info.rep;
stim.grating_TempFreq = VS_info.grating.TempFreq;
stim.grating_angle = VS_info.grating.angle;
stim.duration = VS_info.grating.duration;
stim.contrast = VS_info.grating.contrast;

%%%% calculate cycle/degree %%
stim.grating_SpatialFreq_cpd = VS_info.grating.SpatialFreq; %cycle/degree
[Pix] = func.deg2pix(1, monitor.dist, monitor.pixpitch);
stim.grating_SpatialFreq_cpp  = stim.grating_SpatialFreq_cpd/Pix.n_pixel; %cycle/pixel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%% make stim patterns %%%
StimPatterns = []; %table

%number of trial types
n_trial_type = numel(stim.duration) *numel(stim.grating_TempFreq) * numel(stim.grating_angle) *...
    numel(stim.contrast)*numel(stim.grating_SpatialFreq_cpp);

%Contrast
for c = 1 : numel(stim.contrast)
    StimColor_Contrast(c,1) = VS_info.grating.contrast(c);
end
StimPatterns = [StimPatterns, table(StimColor_Contrast)];


% TempFreq
StimPatterns = repmat(StimPatterns,numel(stim.grating_TempFreq),1);
TempFreq = sort(repmat(stim.grating_TempFreq',[size(StimPatterns,1)/numel(stim.grating_TempFreq),1]));
StimPatterns = [StimPatterns, table(TempFreq)];

% Duration
StimPatterns = repmat(StimPatterns,numel(stim.duration),1);
Duration = sort(repmat(stim.duration',[size(StimPatterns,1)/numel(stim.duration),1]));
StimPatterns = [StimPatterns, table(Duration)];

% SpatialFreq
StimPatterns = repmat(StimPatterns,numel(stim.grating_SpatialFreq_cpp),1);
SpaFreq_cpd = sort(repmat(stim.grating_SpatialFreq_cpd',[size(StimPatterns,1)/numel(stim.grating_SpatialFreq_cpd),1]));
SpaFreq_cpp = sort(repmat(stim.grating_SpatialFreq_cpp',[size(StimPatterns,1)/numel(stim.grating_SpatialFreq_cpp),1]));
StimPatterns = [StimPatterns, table(SpaFreq_cpd), table(SpaFreq_cpp)];

% angle
StimPatterns = repmat(StimPatterns,numel(stim.grating_angle),1);
direction = sort(repmat(stim.grating_angle',[size(StimPatterns,1)/numel(stim.grating_angle),1]));
StimPatterns = [StimPatterns, table(direction)];



%Opt (true 1 or false 0)
switch Opt
    case 0
        OG = zeros(size(StimPatterns,1),1);
        StimPatterns = [StimPatterns, table(OG)];
    case 1
        OG = [zeros(size(StimPatterns,1),1); ones(size(StimPatterns,1),1)];
        StimPatterns = repmat(StimPatterns,2,1);
        StimPatterns = [StimPatterns, table(OG)];
end
%%
stim.trial_order = [];
for i = 1 : stim.rep
    TrialOrder_pre = randperm(size(StimPatterns,1)); %re-order trials randomly
    stim.trial_order{1,i} = StimPatterns(TrialOrder_pre,:); 
end

