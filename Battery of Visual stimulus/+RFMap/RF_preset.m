function [stim] = RF_Params(Params)
global grid
global monitor
stim = [];
stim.feature = Params.stim_feature;
stim.rep = Params.rep;
stim.time.ON = Params.time_on;
stim.color = Params.stim_color;

switch Params.type
    case 'sparse'
        stim.color = repmat(Params.stim_color,(grid.width*grid.height),1); %元のデータセット.
        for i = 1 : stim.rep
            TrialOrder_pre = randperm(grid.width*grid.height); %re-order trials randomly
            stim.trial_order{1,i}(:,1) = TrialOrder_pre;%f_Interlacer(TrialOrder_pre(1:(end/2)), TrialOrder_pre((end/2)+1:end),i);
            stim.trial_order{1,i}(:,2) = stim.color;
        end

    case 'mapping_order'
        stim.color = repmat([monitor.color.black],(grid.width*grid.height),1); %元のデータセット.
        for i = 1 : stim.rep
            stim.trial_order{1,i}(:,1) = 1 : 1 : (grid.width*grid.height); %re-order trials randomly
            stim.trial_order{1,i}(:,2) = stim.color; %color
        end
end

end