function ERROR= nVoke_TrialDesigner(VS_info,stim,OptParams)
%%
%check the input parameters
%calculate the time taken in the trial

%last update- 2022/Jan/29: Subfunction

if nargin == 2
    OptParams = [];
end


%% 
clc
switch VS_info.type
    %% Grid mapping
    case 'mapping_order' % Grid mapping
        TIME = subfun_TrialDesigner_mapping_order(VS_info,stim);
        
    case 'sparse' % Grid mapping
        TIME = subfun_TrialDesigner_sparse(VS_info,stim);
    
    case 'Sz_tuning' 
        [TIME,ERROR] = subfun_TrialDesigner_Sz_tuning(VS_info,stim,OptParams);

    case 'CKB'
        [TIME,ERROR] = subfun_TrialDesigner_CKB(VS_info,stim,OptParams);

    case 'Grating'
        [TIME,ERROR] = subfun_TrialDesigner_Grating(VS_info,stim,OptParams);

end

if ~exist('ERROR')
    ERROR = false;
end
disp('Parameters are correct')
disp([VS_info.type ': scan time: ', num2str(TIME) ' min']); 
end

%% subfunctiuons 
function  TIME = subfun_TrialDesigner_mapping_order(VS_info,stim)

if VS_info.baseline.on == 1
    t1 = (VS_info.baseline.rec + VS_info.baseline.recovery/2) *2;
else
    t1 = 0;
end
t2 = (VS_info.preon + VS_info.on + VS_info.off + VS_info.recovery)*length(stim.trial_order{1})*VS_info.rep;
TIME = (t1+t2)/60; %minutes
end   

function  TIME = subfun_TrialDesigner_sparse(VS_info,stim)
if VS_info.baseline.on == 1
    t1 = (VS_info.baseline.rec + VS_info.baseline.recovery/2) *2;
else
    t1 = 0;
end
t2 = (VS_info.preon + VS_info.on + VS_info.off + VS_info.recovery)*length(stim.trial_order{1})*VS_info.rep;
TIME = (t1+t2)/60; %minutes
end   

function [TIME,ERROR] = subfun_TrialDesigner_Sz_tuning(VS_info,stim,OptParams)
if VS_info.baseline.on == 1
    t1 = (VS_info.baseline.rec + VS_info.baseline.recovery/2) *2;
else
    t1 = 0;
end
t2_n = numel(stim.trial_order) * size(stim.trial_order{1},1);
t2 = (VS_info.preon + VS_info.on + VS_info.off + VS_info.recovery) * t2_n;
TIME = (t1+t2)/60; %minutes

if stim.Opt == 1 & VS_info.off < OptParams.offset 
    disp('error @ Opt time vector')
    ERROR= true;
    return
else
    ERROR= false;
end
end

function [TIME,ERROR] = subfun_TrialDesigner_CKB(VS_info,stim,OptParams)

if VS_info.baseline.on == 1
    t1 = (VS_info.baseline.rec + VS_info.baseline.recovery/2) *2;
else 
    t1 = 0;
end

t2_n = numel(stim.trial_order);
t2 = (VS_info.preon + VS_info.poston + VS_info.on*VS_info.rep*2)*t2_n;
t3 = VS_info.ITI*(t2_n-1);
TIME = (t1+t2+t3)/60; %minutes

if stim.Opt == 1 & VS_info.poston < OptParams.offset 
    disp('error @ Opt time vector')
    ERROR= true;
    return
else
    ERROR= false;            
end
end


function [TIME,ERROR] = subfun_TrialDesigner_Grating(VS_info,stim,OptParams);

if VS_info.baseline.on == 1
    t1 = (VS_info.baseline.rec + VS_info.baseline.recovery/2) *2;
else 
    t1 = 0;
end

t2_1 = stim.trial_order{1}.Duration(1)*size(stim.trial_order{1},1); 
t2_2 = (VS_info.preon + VS_info.poston)*size(stim.trial_order{1},1);
t2 = (t2_1 + t2_2) *  size(stim.trial_order,2);
t3 = VS_info.recovery*(size(stim.trial_order{1},1))* size(stim.trial_order,2);

TIME = (t1+t2+t3)/60; %minutes        
if stim.Opt == 1 && VS_info.poston < OptParams.offset 
    disp('error @ Opt time vector')
    ERROR= true;
    return
else
    ERROR = false;
end
end

