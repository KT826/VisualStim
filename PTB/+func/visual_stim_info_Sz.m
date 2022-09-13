function [stim] = nVoke_visual_stim_info_Sz(VS_info,grid,monitor,Opt)

stim=[];
stim.Opt = Opt; 
%{
switch Opt
    case 'on'
        global ao_vector
        stim.Opt_info = ao_vector;
    case 'off'
        stim.Opt_info = [];
end
%}

stim.feature = VS_info.feature; %'FillOval', 'FIllRect'. square ê≥ï˚å`Ç≈å≈íË.
stim.rep = VS_info.rep;
stim.time.ON = VS_info.on; %stimulus-duration (sec). Caution FRAME RATE
stim.Sz_center = VS_info.center;
stim.Sz_centroid = [grid.position.w_column(VS_info.center), grid.position.h_column(VS_info.center)]; 
stim.color = VS_info.stim_color;
stim.Sz_size_deg = VS_info.stim_size;

for i = 1 : numel(stim.Sz_size_deg)
    [Pix] = deg2pix(stim.Sz_size_deg(i), monitor.dist, monitor.pixpitch);
    stim.Sz_size_pix(1,i) = Pix.n_pixel;
end


StimPatterns = []; %colum indicates single-paramter set
switch Opt
    case 'off'
        StimPatterns(1,:) = stim.Sz_size_pix;
        StimPatterns(2,:) = stim.Sz_size_deg;
        StimPatterns(3,:) = stim.color;
        StimPatterns(4,:) = 0; %no laser        
    case 'on'
        StimPatterns(1,:) = stim.Sz_size_pix;
        StimPatterns(2,:) = stim.Sz_size_deg;
        StimPatterns(3,:) = stim.color;
        n = size(StimPatterns,2);
        StimPatterns = repmat(StimPatterns,1,2);
        StimPatterns(4,:) = [zeros(1,n),ones(1,n)]; %0:OG-off, 1:OG-on
end        

for i = 1 : stim.rep
    TrialOrder_pre = randperm(size(StimPatterns,2)); %re-order trials randomly
    stim.trial_order{1,i}(:,1) = StimPatterns(1,TrialOrder_pre); %size(pix)
    stim.trial_order{1,i}(:,2) = StimPatterns(2,TrialOrder_pre); %size(deg)
    stim.trial_order{1,i}(:,3) = StimPatterns(3,TrialOrder_pre); %color
    stim.trial_order{1,i}(:,4) = StimPatterns(4,TrialOrder_pre); %Opt
end

end