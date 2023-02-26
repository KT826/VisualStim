function [stim] = Sz_Params(Params,OptParams)
global monitor
global grid
stim=[];
stim.Opt = OptParams.Opt;% 
stim.feature = Params.stim_feature; %'FillOval' or 'FIllRect
stim.rep = Params.rep;
stim.time.ON = Params.time_on; %stimulus-duration (sec). Caution FRAME RATE
stim.Sz_center = Params.stim_PosiCenter;
stim.Sz_centroid = [grid.position.w_column(Params.stim_PosiCenter)'; grid.position.h_column(Params.stim_PosiCenter)]; %row1:x, row2:y
stim.Sz_size_deg = Params.stim_size;

%%%% calculate stim color %%%%
bk = monitor.color.BG (1);
k = monitor.color.black;
colval = transpose(bk:-1:k);
stim.color = colval(fix(prctile(colval,Params.stim_contrast))+1)';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% calculate pixel size %%%%
for i = 1 : numel(stim.Sz_size_deg)
    [Pix] = func.deg2pix(stim.Sz_size_deg(i), monitor.dist, monitor.pixpitch);
    stim.Sz_size_pix(1,i) = Pix.n_pixel;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%% make stim patterns %%%
StimPatterns = []; %table

%number of trial type 
n_trial_type = numel(stim.Sz_center) * numel(stim.Sz_size_deg) * numel(stim.color);

%PixSize = repmat(stim.Sz_size_pix', n_trial_type/numel(stim.Sz_size_pix),1);
%DegSize = repmat(stim.Sz_size_deg', n_trial_type/numel(stim.Sz_size_deg),1);
%StimPatterns= table(PixSize,DegSize,OG);

% Stim Size
PixSize = single(stim.Sz_size_pix)';
DegSize = stim.Sz_size_deg';
StimPatterns= table(PixSize,DegSize);

% Stim Position
StimPatterns = repmat(StimPatterns,numel(stim.Sz_center),1);
[CenterIndex, idx] = sort(repmat(stim.Sz_center',size(StimPatterns,1)/numel(stim.Sz_center),1));
posi = repmat(stim.Sz_centroid',size(StimPatterns,1)/numel(stim.Sz_center),1);
CenterCoordinate = posi(idx,:); clear posi idx 
StimPatterns = [StimPatterns, table(CenterIndex), table(CenterCoordinate)];


% Stim Color (contrast)
StimPatterns = repmat(StimPatterns,numel(stim.color),1);
StimColor = sort(repmat(stim.color',size(StimPatterns,1)/numel(stim.color),1));
StimPatterns = [StimPatterns, table(StimColor)];

%Opt (true 1 or false 0)
switch stim.Opt
    case 0
        OG = zeros(size(StimPatterns,1),1);
        StimPatterns = [StimPatterns, table(OG)];
    case 1
        OG = [zeros(size(StimPatterns,1),1); ones(size(StimPatterns,1),1)];
        StimPatterns = repmat(StimPatterns,2,1);
        StimPatterns = [StimPatterns, table(OG)];
end
  
%%
for i = 1 : stim.rep
    TrialOrder_pre = randperm(size(StimPatterns,1)); %re-order trials randomly
    stim.trial_order{1,i} = StimPatterns(TrialOrder_pre,:); 
end

end