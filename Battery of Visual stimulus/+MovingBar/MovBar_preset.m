function [stim] = MovBar_preset(Params)
global monitor
global grid

stim=[];
%stim.Opt = OptParams.Opt;% 
stim.rep = Params.rep;

%%
%%% make stim patterns %%%
StimPatterns = []; %table

%number of trial in single block
Direction(:,1) = Params.direction;
StimPatterns= table(Direction);

%{
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
%}
%%
for i = 1 : stim.rep
    TrialOrder_pre = randperm(size(StimPatterns,1)); %re-order trials randomly
    stim.trial_order{1,i} = StimPatterns(TrialOrder_pre,:); 
end
