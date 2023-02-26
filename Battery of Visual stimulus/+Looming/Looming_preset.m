function [stim] = Looming_preset(Params,OptParams)
global monitor
global grid
%%
stim.feature = Params.loom_feature; %'FillOval', 'FIllRect'. square 正方形で固定.
stim.rep = Params.rep;
stim.time.ITI = Params.time_ITI; %inter-stimulus-interval-(sec) 
stim.Opt = OptParams.Opt;
stim.LM_center = Params.stim_PosiCenter;
stim.LM_centroid = [grid.position.w_column(Params.stim_PosiCenter), grid.position.h_column(Params.stim_PosiCenter)]; 
stim.color = Params.stim_color;


%% フレーム毎に提示する刺激サイズを計算 (20/06/27現在　複数パラメータには対応していない）
total_frame_expand =round(((Params.loom_final_size-Params.loom_initial_size)/Params.loom_velocity)/monitor.ifi); %period-expanding
total_frame_pause = round(Params.loom_pausetime/monitor.ifi); %period-pausing
sz_per_frame_expand(:,1) = linspace(Params.loom_initial_size,Params.loom_final_size,total_frame_expand); %degree
total_frame = total_frame_expand + total_frame_pause;
sz_per_frame = zeros(total_frame,1);
sz_per_frame(1:total_frame_expand) = sz_per_frame_expand;
sz_per_frame(total_frame_expand+1:total_frame_expand+total_frame_pause) = sz_per_frame_expand(end);

%%% degree to pixel
for i = 1 : size(sz_per_frame)
    [Pix] = func.deg2pix(sz_per_frame(i,1), monitor.dist, monitor.pixpitch);
    sz_per_frame(i,2) = Pix.n_pixel;
end
stim.sz_per_frame = sz_per_frame;
stim.time.ON = total_frame*monitor.ifi; %inter-stimulus-interval-(sec) 
stim.LMsize.initial = Params.loom_initial_size;
stim.LMsize.final = Params.loom_final_size;
stim.LMsize.vel = Params.loom_velocity;


%%

StimPatterns = [];
switch stim.Opt
    case true
        
        %%%%%%%%
        % analog output のpatternを組み合わせる.
        % pixel, degree; ao_typeの配列を作成
        global ao_vector
        ao_vector.n;
        for i = 1 %: numel(stim.Sz_size_pix)
            R(1,1) = stim.LMsize.initial;
            R(2,1) = stim.LMsize.final;
            R(3,:) = stim.LMsize.vel;
            R(4,:) =  stim.color;
            RR = repmat(R,1,(ao_vector.n));
            RR(5,:) = [0:1:(ao_vector.n-1)]; %laser pulse
            StimPatterns = [StimPatterns, RR];
        end
        clear R RR
        %%%%%%%%
    
    case false
        StimPatterns(1,:) = stim.LMsize.initial;
        StimPatterns(2,:) = stim.LMsize.final;
        StimPatterns(3,:) = stim.LMsize.vel;
        StimPatterns(4,:) = stim.color;
        StimPatterns(5,:) = 0; %no laser
end


%%
%刺激順番
for i = 1 : stim.rep
    TrialOrder_pre = randperm(size(StimPatterns,2)); %re-order trials randomly
    stim.trial_order{1,i}.initial_deg = StimPatterns(1,TrialOrder_pre); %initial_size(deg)
    stim.trial_order{1,i}.final_deg = StimPatterns(2,TrialOrder_pre); %final_size(deg)
    stim.trial_order{1,i}.velocity = StimPatterns(3,TrialOrder_pre); %velocity(deg/sec)
    stim.trial_order{1,i}.LMcolor = StimPatterns(4,TrialOrder_pre); %color
    stim.trial_order{1,i}.Opt = StimPatterns(5,TrialOrder_pre); %Opt laser type = ao_vector.
    stim.trial_order_LMframeInfo{1,i} = stim.sz_per_frame;% low1: deg, low2: pix, (/frame)
    
    switch stim.Opt
        case true
            for ii = 1 : numel(stim.trial_order{1,i}.Opt)
                no_vector = stim.trial_order{1, i}.Opt(1,ii);
                exp= ['vc_info = ao_vector.ao' num2str(no_vector) ';'];
                eval(exp)
                stim.aovector{1,i}{1,ii} = vc_info.vector;
                stim.aovector{1,i}{2,ii} = vc_info.hz; %Hz of laser-pulse
                stim.aovector{1,i}{3,ii} = vc_info.duration; %duration of single-pulse
            end
    end
end

end