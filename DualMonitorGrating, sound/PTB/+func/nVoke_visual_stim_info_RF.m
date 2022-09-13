function [stim] = nVoke_visual_stim_info_RF(VS_info,w,h,monitor)

%w = grid.wide;
%h = grid.hight;

%%%%%%%%%%%%%%%%%+
global stim
stim = [];
stim.feature = VS_info.feature; %'FillOval', 'FIllRect'. square 正方形で固定.
stim.rep = VS_info.rep;
stim.time.ON = VS_info.on; %stimulus-duration (sec). Caution FRAME RATE

switch VS_info.type
    case 'sparse'
        stim.color = repmat([monitor.color.black],(w*h),1); %元のデータセット.
        for i = 1 : stim.rep
            TrialOrder_pre = randperm(w*h); %re-order trials randomly
            stim.trial_order{1,i}(:,1) = TrialOrder_pre;%f_Interlacer(TrialOrder_pre(1:(end/2)), TrialOrder_pre((end/2)+1:end),i);
            stim.trial_order{1,i}(:,2) = stim.color;
        end

    case 'mapping_order'
        stim.color = repmat([monitor.color.black],(w*h),1); %元のデータセット.
        for i = 1 : stim.rep
            stim.trial_order{1,i}(:,1) = 1 : 1 : (w*h); %re-order trials randomly
            stim.trial_order{1,i}(:,2) = monitor.color.black; %color
        end
end
%%%%%%%%%%%%%%

end