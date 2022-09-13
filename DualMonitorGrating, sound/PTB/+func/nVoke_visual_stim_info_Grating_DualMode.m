function [stim] = nVoke_visual_stim_info_Grating_DualMode(VS_info,Opt)

%update: 2022/01/18: dualmode

global monitor
global grid

%% Default set %%
stim=[];
stim.Opt = Opt; 
stim.rep = VS_info.rep;
stim.grating_TempFreq = VS_info.grating.TempFreq;
stim.duration = VS_info.grating.duration;
stim.contrast = VS_info.grating.contrast;

%%%% calculate cycle/degree %%
stim.grating_SpatialFreq_cpd = VS_info.grating.SpatialFreq; %cycle/degree
[Pix] = deg2pix(1, monitor.dist, monitor.pixpitch);
stim.grating_SpatialFreq_cpp  = stim.grating_SpatialFreq_cpd/Pix.n_pixel; %cycle/pixel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%% make stim patterns %%%
StimPatterns = []; %table
StimPatterns_sub= []; %table

%Contrast
StimColor_Contrast = repmat(stim.contrast ,[8,1]);
StimColor_Contrast_sub = StimColor_Contrast;
StimColor_Contrast([3,4]) = NaN;
StimColor_Contrast_sub([1,2]) = NaN;


% TempFreq
TempFreq =  ones(8,1);
TempFreq_sub =  ones(8,1);
TempFreq([3,4]) = NaN;
TempFreq_sub([1,2]) = NaN;

% Duration
Duration =  repmat(stim.duration,[8,1]);
Duration_sub =  repmat(stim.duration ,[8,1]);
Duration([3,4]) = NaN;
Duration_sub([1,2]) = NaN;

% SpatialFreq
SpaFreq_cpd =  ones(8,1);
SpaFreq_cpd_sub =  ones(8,1);
SpaFreq_cpd([3,4]) = NaN;
SpaFreq_cpd_sub([1,2]) = NaN;
SpaFreq_cpp =  ones(8,1);
SpaFreq_cpp_sub =  ones(8,1);
SpaFreq_cpp([3,4]) = NaN;
SpaFreq_cpp_sub([1,2]) = NaN;

% angle
direction =     [0  ; 180; nan; nan; 0; 180; 0; 180];
direction_sub = [nan; nan; 0;   180; 0; 180; 180; 0];

%StimPatterns = table(StimColor_Contrast,TempFreq,Duration,SpaFreq_cpd, SpaFreq_cpp, direction);
%StimPatterns_sub = table(StimColor_Contrast_sub,TempFreq_sub,Duration_sub,SpaFreq_cpd_sub, SpaFreq_cpp_sub, direction_sub);
StimPatterns = table(StimColor_Contrast,Duration,direction);
StimPatterns_sub = table(StimColor_Contrast_sub,Duration_sub, direction_sub);


%%
%%% variable parameters %%%
%stim.grating_TempFreq
%stim.grating_SpatialFreq_cpd;
%stim.grating_SpatialFreq_cpp;

combination = numel(stim.grating_TempFreq)*numel(stim.grating_SpatialFreq_cpd);
tag_Hz(:,1) = sort(repmat(stim.grating_TempFreq,[1,numel(stim.grating_SpatialFreq_cpd)]));
tag_cpd(:,1) = repmat(stim.grating_SpatialFreq_cpd,[1,numel(stim.grating_TempFreq)]);
tag_cpp(:,1) = repmat(stim.grating_SpatialFreq_cpp,[1,numel(stim.grating_TempFreq)]);
Tags = table(tag_Hz,tag_cpd,tag_cpp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch stim.Opt 
    case 0
        OG = zeros(8,1);
        StimPatterns_base = [StimPatterns, table(OG)]; clear StimPatterns
        StimPatterns_sub_base = [StimPatterns_sub, table(OG)]; clear StimPatterns_sub
        k = 0;
        for i = 1 : stim.rep
            seq(:,1) = randperm(combination);
            stim.trial_sequence{i,1} = [Tags,table(seq)];
            for ii = 1 : combination
                k = k + 1;
                idx = find(stim.trial_sequence{i,1}.seq == ii);
                
                TempFreq =  ones(8,1);TempFreq_sub =  ones(8,1);
                TempFreq([3,4]) = NaN; TempFreq_sub([1,2]) = NaN;
                TempFreq_val = Tags.tag_Hz(idx);
                
                TempFreq(~isnan(TempFreq)) = TempFreq_val;
                TempFreq_sub(~isnan(TempFreq_sub)) = TempFreq_val;
                
                % SpatialFreq
                SpaFreq_cpd =  ones(8,1); SpaFreq_cpd_sub =  ones(8,1);
                SpaFreq_cpd([3,4]) = NaN; SpaFreq_cpd_sub([1,2]) = NaN;
                SpaFreq_cpd_val =Tags.tag_cpd(idx);
                SpaFreq_cpd(~isnan(SpaFreq_cpd)) = SpaFreq_cpd_val;
                SpaFreq_cpd_sub(~isnan(SpaFreq_cpd_sub)) = SpaFreq_cpd_val;
                
                SpaFreq_cpp =  ones(8,1); SpaFreq_cpp_sub =  ones(8,1);
                SpaFreq_cpp([3,4]) = NaN; SpaFreq_cpp_sub([1,2]) = NaN;
                SpaFreq_cpp_val =Tags.tag_cpp(idx);
                SpaFreq_cpp(~isnan(SpaFreq_cpp)) = SpaFreq_cpp_val;
                SpaFreq_cpp_sub(~isnan(SpaFreq_cpp_sub)) = SpaFreq_cpp_val;
                
                StimPatterns =[StimPatterns_base,table(TempFreq),table(SpaFreq_cpd),table(SpaFreq_cpp)];
                StimPatterns_sub =[StimPatterns_sub_base,table(TempFreq_sub),table(SpaFreq_cpd_sub),table(SpaFreq_cpp_sub)];
                
                stim.trial_order{1,k} = StimPatterns; clear StimPatterns
                stim.trial_order_sub{1,k} = StimPatterns_sub; clear StimPatterns_sub
            end
        end
  %{      
    case 1
        t = 0;
        for i = 1 : stim.rep*2
            t = t + 1;
            if rem(t,2) == 1
                OG = zeros(8,1);
            elseif rem(t,2) == 0
                OG = ones(8,1);
            end
            StimPatterns = [StimPatterns, table(OG)];
            StimPatterns_sub = [StimPatterns_sub, table(OG)];
            
            stim.trial_order{1,t} = StimPatterns;
            stim.trial_order_sub{1,t} = StimPatterns_sub;
            
            StimPatterns = removevars(StimPatterns,{'OG'});
            StimPatterns_sub = removevars(StimPatterns_sub,{'OG'});
        end
        %}
end
