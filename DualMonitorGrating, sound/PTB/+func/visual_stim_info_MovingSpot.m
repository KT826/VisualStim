function [stim] = visual_stim_info_MovingSpot(VS_info,grid,monitor)
clear stim;

stim.feature = VS_info.feature; %'FillOval', 'FIllRect'. square 正方形で固定.
stim.rep = VS_info.rep;
stim.velocity_deg = VS_info.velocity; %deg/sec
stim.velocity_pix = []; %pix/sec
stim.time.ISI = VS_info.isi; %inter-stimulus-interval-(sec) 
stim.Sz_center = VS_info.center;
stim.color = VS_info.stim_color;
            
switch  VS_info.type
    case 'Moving_spot_single'

        for i = 1 : numel(stim.Sz_center)
            stim.Sz_centroid(i,1:2) = [grid.position.w_column(VS_info.center(i)), grid.position.h_column(VS_info.center(i))]; 
        end
        stim.Sz_size_deg = VS_info.stim_size;
        for i = 1 : numel(stim.Sz_size_deg)
            [Pix] = deg2pix(stim.Sz_size_deg(i), monitor.dist, monitor.pixpitch);
            stim.Sz_size_pix(1,i) = Pix.n_pixel;
        end
        
        %%%velocity の変換%%%
        %deg -> pixel
        for i = 1: numel(stim.velocity_deg)
            [Pix] = deg2pix(stim.velocity_deg(i), monitor.dist, monitor.pixpitch);
            stim.velocity_pix(1,i) = Pix.n_pixel; %1秒で　このピクセルを動かす.
            %frame rate = monitor.fps
            stim.pix_per_frame(1,i) = stim.velocity_pix(1,i)/monitor.fps; %1フレームあたりに動かすピクセル.
        end
        %%%%%%%%%%%%%%%%%%%%
        stim.moving_direction = VS_info.direction;
        
        %combination = velocity x size x centroid x direction
        comb = allcomb([1:1:numel(stim.pix_per_frame)], [1:1:numel(stim.Sz_size_pix)],[1:1:numel(stim.Sz_center)],[1:1:numel(stim.moving_direction)]);
        
        for i = 1 : stim.rep
            TrialOrder_pre = randperm(size(comb,1)); %re-order trials randomly
            stim.trial_order_deg{1,i}(:,1) = stim.Sz_size_deg(comb(TrialOrder_pre,2)); %size
            stim.trial_order_deg{1,i}(:,2) = stim.velocity_deg(comb(TrialOrder_pre,1)); %velocity
            stim.trial_order_deg{1,i}(:,3) = NaN; %frame per deg
            stim.trial_order_deg{1,i}(:,4) = NaN;
            stim.trial_order_deg{1,i}(:,5) = stim.color;
    
            stim.trial_order_pix{1,i}(:,1) = stim.Sz_size_pix(comb(TrialOrder_pre,2)); %size
            stim.trial_order_pix{1,i}(:,2) = stim.velocity_pix(comb(TrialOrder_pre,1)); %velocity
            stim.trial_order_pix{1,i}(:,3) = stim.pix_per_frame(comb(TrialOrder_pre,1)); %pix per frame
            stim.trial_order_pix{1,i}(:,4) =  stim.Sz_centroid(comb(TrialOrder_pre,3),1); %centroid_x
            stim.trial_order_pix{1,i}(:,5) =  stim.Sz_centroid(comb(TrialOrder_pre,3),2); %centroid_y
            stim.trial_order_pix{1,i}(:,6) = stim.color;
            stim.trial_order_pix{1,i}(:,7) = stim.moving_direction(comb(TrialOrder_pre,4)); %direction...1:'Up2Down'; 2:'Down2Up'; 3:'Left2Right' ; 4:'Right2Left'
        end

        
        
    %{    
    case 'Moving_spot_double'
        
    stim.Sz_centroid(1:2) = [grid.position.w_column(VS_info.center(1)), grid.position.h_column(VS_info.center(1))]; 
    stim.Sz_size_deg = VS_info.stim_size;
    [Pix] = deg2pix(stim.Sz_size_deg, monitor.dist, monitor.pixpitch);
    stim.Sz_size_pix = Pix.n;
    
    %%%velocity の変換%%%
    %deg -> pixel
    for i = 1: numel(stim.velocity_deg)
        [Pix] = deg2pix(stim.velocity_deg(i), monitor.dist, monitor.pixpitch);
        stim.velocity_pix(1,i) = Pix.n; %1秒で　このピクセルを動かす.
        %frame rate = monitor.fps
        stim.pix_per_frame(1,i) = stim.velocity_pix(1,i)/monitor.fps; %1フレームあたりに動かすピクセル.
    end
    %%%%%%%%%%%%%%%%%%%%
    stim.moving_direction = VS_info.direction;
    
    %%%% distractor 作成 %%%%
    stim.distractor_deg = VS_info.distracter.size;
    stim.distractor_dir = VS_info.distracter.direction;
    n = numel(stim.distractor_deg) + numel(stim.Sz_center);
    posi = [];
    posi(1:2,1) = stim.Sz_centroid';
    
    for i = 1: numel(stim.distractor_deg)
        [Pix] = deg2pix(stim.distractor_deg(i), monitor.dist, monitor.pixpitch);
        stim.distractor_pix(1,i) = Pix.n; %このピクセル分だけ基準点からずらす.
        
        switch stim.distractor_dir
            case 'right'
                stim.centroid_distractor(i,1) = stim.Sz_centroid(1) + stim.distractor_pix(1,i);
                stim.centroid_distractor(i,2) = 0;
            case 'left'
                stim.centroid_distractor(i,1) = stim.Sz_centroid(1) - stim.distractor_pix(1,i);
                stim.centroid_distractor(i,2) = 0;
            case 'upper'
                stim.centroid_distractor(i,1) = 0;
                stim.centroid_distractor(i,2) = stim.Sz_centroid(2) + stim.distractor_pix(1,i);
            case 'bottom'
                stim.centroid_distractor(i,1) = stim.Sz_centroid(2) - stim.distractor_pix(1,i);
                stim.centroid_distractor(i,2) = 0;
        end
        posi(1:2,i+1) = stim.centroid_distractor(i,1:2)';
    end
    
    %combination = <1 or 2 spot > x <number of positions = base + distractor> 
    comb_a(:,1:2) = [repmat(1,[size(posi,2),1]), repmat(0,[size(posi,2),1])] %single-spot
    comb_b(:,1:2) = [repmat(2,[numel(stim.distractor_deg),1]), (1:numel(stim.distractor_deg))'] %2-spot
    comb = [comb_a; comb_b];
    
    for i = 1 : stim.rep
        TrialOrder_pre = randperm(size(comb,1)); %re-order trials randomly
        stim.trial_order_pix{1,i}(:,1) = stim.Sz_size_pix; %size
        stim.trial_order_pix{1,i}(:,2) = stim.velocity_pix; %velocity
        stim.trial_order_pix{1,i}(:,3) = stim.pix_per_frame
        
        stim.trial_order_pix{1,i}(:,4) =  stim.Sz_centroid(comb(TrialOrder_pre,1),2); %base_centroid_x
        stim.trial_order_pix{1,i}(:,5) =  stim.Sz_centroid(comb(TrialOrder_pre,3),2); %base_centroid_y
            
            stim.trial_order_pix{1,i}(:,8) =  stim.Sz_centroid(comb(TrialOrder_pre,3),1); %distractor_centroid_x
            stim.trial_order_pix{1,i}(:,9) =  stim.Sz_centroid(comb(TrialOrder_pre,3),2); %distractor_centroid_y

            
            stim.trial_order_pix{1,i}(:,6) = stim.color;
            stim.trial_order_pix{1,i}(:,7) = stim.moving_direction(comb(TrialOrder_pre,4)); %direction...1:'Up2Down'; 2:'Down2Up'; 3:'Left2Right' ; 4:'Right2Left'
       
        
        
            stim.trial_order_deg{1,i}(:,1) = stim.Sz_size_deg(comb(TrialOrder_pre,2)); %size
            stim.trial_order_deg{1,i}(:,2) = stim.velocity_deg(comb(TrialOrder_pre,1)); %velocity
            stim.trial_order_deg{1,i}(:,3) = NaN; %frame per deg
            stim.trial_order_deg{1,i}(:,4) = NaN;
            stim.trial_order_deg{1,i}(:,5) = stim.color;
    end
%}
    
        
end