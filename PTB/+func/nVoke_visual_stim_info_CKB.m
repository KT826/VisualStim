function [stim] = nVoke_visual_stim_info_CKB(VS_info,Opt)

%update: 2022/01/15: make this file newly.

global monitor
global grid
%%
stim=[];
stim.Opt = Opt; 
stim.rep = VS_info.rep;
stim.time.ON = VS_info.on; %stimulus-duration (sec). Caution FRAME RATE
stim.Sz_size_deg = VS_info.stim_size;
%VS_info.stim_contrast

%%%% calculate stim color %%%%
w = monitor.color.white;
k = monitor.color.black;
colval = transpose(w:-1:k);
for c = 1 : numel(VS_info.stim_contrast)
        halfcol = fix(prctile(colval,100) - prctile(colval,50));
        stim.color{1,c}(1,1) = halfcol + fix(halfcol/(100/VS_info.stim_contrast(c)));
        stim.color{1,c}(1,2) = halfcol - fix(halfcol/(100/VS_info.stim_contrast(c)));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% calculate pixel size %%%%
[Pix] = func.deg2pix(stim.Sz_size_deg, monitor.dist, monitor.pixpitch);
stim.Sz_size_pix = Pix.n_pixel; %pixel size of box length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%% make stim patterns %%%
StimPatterns = []; %table

%number of trial type s
n_trial_type = numel(stim.Sz_size_deg) * numel(stim.color);

% Stim Size
PixSize = stim.Sz_size_pix';
DegSize = stim.Sz_size_deg';
StimPatterns= table(PixSize,DegSize);

% Stim Color (contrast)
StimPatterns = repmat(StimPatterns,numel(stim.color),1);
for c = 1 : numel(stim.color)
    StimColor(c,:) = stim.color{c};
    StimColor_Contrast(c,1) = VS_info.stim_contrast(c);
end
StimPatterns = [StimPatterns, table(StimColor), table(StimColor_Contrast)];

% Define a simple X by X checker board
[xCenter, yCenter] = RectCenter(monitor.rect);
VS_info.n_square_x = fix(monitor.rect(3)/Pix.n_pixel);
VS_info.n_square_y = fix(monitor.rect(4)/Pix.n_pixel);
if rem(VS_info.n_square_x,2) == 1 %VS_info.n_squareは偶数の必要があるため、奇数の場合は + 1する.
    VS_info.n_square_x = VS_info.n_square_x + 1;
end
if rem(VS_info.n_square_y,2) == 1 %VS_info.n_squareは偶数の必要があるため、奇数の場合は + 1する.
    VS_info.n_square_y = VS_info.n_square_y + 1;
end
for q = 1 : size(StimPatterns,1)
    base = eye(2);
    base(find(base == 1)) = StimPatterns.StimColor(q,1);
    base(find(base == 0)) = StimPatterns.StimColor(q,2);
    CKB_1{q,1} = repmat(base, VS_info.n_square_y/2, VS_info.n_square_x/2);
    CKB_2{q,1} = fliplr(CKB_1{q,1});
end
StimPatterns = [StimPatterns, table(CKB_1,CKB_2)];


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
TrialOrder_pre = randperm(size(StimPatterns,1)); %re-order trials randomly
for i = 1 : numel(TrialOrder_pre )
    stim.trial_order{1,i} = StimPatterns(TrialOrder_pre(i),:); 
end

end