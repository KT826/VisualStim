function [stim] = visual_stim_info_RF(VS_info,w,h,monitor)
stim = [];
stim.feature = VS_info.feature; %'FillOval', 'FIllRect'. square 正方形で固定.
stim.rep = VS_info.rep;
stim.time.ON = VS_info.on; %stimulus-duration (sec). Caution FRAME RATE
stim.time.ISI = VS_info.isi; %inter-stimulus-interval-(sec) 


switch VS_info.type
    case 'sparse'
        stim.color = repmat([monitor.color.white; monitor.color.black],(w*h),1); %元のデータセット.
        for i = 1 : stim.rep
            TrialOrder_pre = randperm(w*h); %re-order trials randomly
            stim.trial_order{1,i}(:,1:2) = f_Interlacer(TrialOrder_pre(1:(end/2)), TrialOrder_pre((end/2)+1:end),i);
            stim.trial_order{1,i}(:,2) = stim.color;
            stim.time.ISI = 0;
        end

    case 'mapping_order'
        stim.color = repmat([monitor.color.black],(w*h),1); %元のデータセット.
        for i = 1 : stim.rep
            stim.trial_order{1,i}(:,1) = 1 : 1 : (w*h); %re-order trials randomly
            stim.trial_order{1,i}(:,2) = monitor.color.black; %color
        end
end

end