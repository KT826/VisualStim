function ERROR= TrialDesigner(Params,stim,OptParams)

%{
06/June/2022: wrote Sz.


%}

%%
%check the input parameters
%calculate the time taken in the trial

if nargin == 2
    OptParams = [];
end


%% 
clc
switch Params.type
    case 'Sz_tuning' 
        [TIME,ERROR] = localfunc_SzTuning(Params,stim,OptParams);
    case 'Looming'
        [TIME,ERROR] = localfunc_Looming(Params,stim,OptParams);
    case 'RWD'
        [TIME,ERROR] = localfunc_Looming(Params,stim,OptParams);
    case 'sparse' % RF mapping
        TIME = localfunc_RFmapping(Params,stim);
    case 'mapping_order' % RF mapping
        TIME = localfunc_RFmapping(Params,stim);
    case 'Col_Preference' % RF mapping
        TIME = localfunc_ColPref(Params,stim);
    case 'MovingBar' % Moving Bar
        global monitor
        TIME = localfunc_MovBar(Params,stim);
        TIME = TIME *1.75;%about
    case 'CKB'
        [TIME,ERROR] = localfunc_TrialDesigner_CKB(Params,stim,OptParams);
    case 'Grating'
        [TIME,ERROR] = localfunc_TrialDesigner_Grating(Params,stim,OptParams);
        
    case 'Chirp'
        [TIME] = localfunc_TrialDesigner_Chirp(Params,stim);
end

if ~exist('ERROR')
    ERROR = false;
end
switch ERROR
    case false
        disp('Preset is acceptable')
        disp([Params.type ': scan time: ', num2str(TIME) ' min']); 
    case true
        disp('Preset is unacceptable')
end
       
end

%% localfuncctiuons 
function [TIME,ERROR] = localfunc_SzTuning(Params,stim,OptParams)
if Params.baseline.on == 1
    t1 = (Params.baseline.rec + Params.baseline.recovery/2) *2;
else
    t1 = 0;
end
t2_n = numel(stim.trial_order) * size(stim.trial_order{1},1);
t2 = (Params.time_pre_on + Params.time_on + Params.time_post_on + Params.time_ITI) * t2_n;
t2 = t2 - Params.time_ITI;
TIME = (t1+t2)/60; %time taken the recording(min)

if stim.Opt == 1 & Params.time_post_on < OptParams.Offset 
    disp('error @ Opt time vector')
    ERROR= true;
    return
else
    ERROR= false;
end
end


function  [TIME,ERROR] = localfunc_Looming(Params,stim,OptParams)

if Params.baseline.on == 1
    t1 = (Params.baseline.rec + Params.baseline.recovery/2) *2;
else
    t1 = 0;
end
t2_n = numel(stim.trial_order) * size(stim.trial_order{1},1);
LoomingTime = (Params.loom_final_size-Params.loom_initial_size)/Params.loom_velocity;
t2 = (Params.time_pre_on + LoomingTime + Params.loom_pausetime + Params.time_post_on + Params.time_ITI) * t2_n;
t2 = t2 - Params.time_ITI;
TIME = (t1+t2)/60; %time taken the recording(min)

if stim.Opt == 1 & Params.time_post_on < OptParams.Offset 
    disp('error @ Opt time vector')
    ERROR= true;
    return
else
    ERROR= false;
end
end   

function  TIME = localfunc_RFmapping(Params,stim)
if Params.baseline.on == 1
    t1 = (Params.baseline.rec + Params.baseline.recovery/2) *2;
else
    t1 = 0;
end
t2 = (Params.time_pre_on + Params.time_on + Params.time_post_on + Params.time_ITI)*length(stim.trial_order{1})*Params.rep;
t2 = t2 - Params.time_ITI;
TIME = (t1+t2)/60; %time taken the recording(min)
end   

function  TIME = localfunc_ColPref(Params,stim)
if Params.baseline.on == 1
    t1 = (Params.baseline.rec + Params.baseline.recovery/2) *2;
else
    t1 = 0;
end
t2 = (Params.time_pre_on + Params.time_post_on + Params.time_ITI)*Params.rep;
t2 = t2 - Params.time_ITI;
t3 = sum(Params.time_on)*Params.rep;
TIME = (t1+t2+t3)/60; %time taken the recording(min)
end   

function  TIME = localfunc_MovBar(Params,stim)
global monitor
if Params.baseline.on == 1
    t1 = (Params.baseline.rec + Params.baseline.recovery/2) *2;
else
    t1 = 0;
end
t2 = (mean([monitor.rect(3),monitor.rect(4)])/(Params.PixPerFrame/monitor.ifi))*numel(Params.direction)*Params.rep;
t3 = (Params.time_pre_on+Params.time_post_on)*numel(Params.direction)*Params.rep;
t4 = Params.time_ITI * (numel(Params.direction)*Params.rep-1);
TIME = (t1+t2+t3+t4)/60; %time taken the recording(min)
end   


function [TIME,ERROR] = localfunc_TrialDesigner_CKB(Params,stim,OptParams)

if Params.baseline.on == 1
    t1 = (Params.baseline.rec + Params.baseline.recovery/2) *2;
else 
    t1 = 0;
end

t2_n = numel(stim.trial_order);
t2 = (Params.preon + Params.poston + Params.on*Params.rep*2)*t2_n;
t3 = Params.ITI*(t2_n-1);
TIME = (t1+t2+t3)/60; %minutes

if stim.Opt == 1 & Params.poston < OptParams.offset 
    disp('error @ Opt time vector')
    ERROR= true;
    return
else
    ERROR= false;            
end
end


function [TIME,ERROR] = localfunc_TrialDesigner_Grating(Params,stim,OptParams);

if Params.baseline.on == 1
    t1 = (Params.baseline.rec + Params.baseline.recovery/2) *2;
else 
    t1 = 0;
end

t2_1 = stim.trial_order{1}.Duration(1)*size(stim.trial_order{1},1); 
t2_2 = (Params.preon + Params.poston)*size(stim.trial_order{1},1);
t2 = (t2_1 + t2_2) *  size(stim.trial_order,2);
t3 = Params.recovery*(size(stim.trial_order{1},1))* size(stim.trial_order,2);

TIME = (t1+t2+t3)/60; %minutes        
if stim.Opt == 1 && Params.poston < OptParams.offset 
    disp('error @ Opt time vector')
    ERROR= true;
    return
else
    ERROR = false;
end
end

function [TIME] = localfunc_TrialDesigner_Chirp(Params,stim)

t1 = Params.time_pre_on + Params.time_post_on;
t2 = Params.Stim_LDAI.time_on*5;
t3 = Params.Stim_FM.time_on;
t4 = Params.Stim_LDAI.time_on;
t5 = Params.Stim_AM.time_on;
t6 = Params.Stim_LDAI.time_on;
t7 = Params.Stim_LDAI.time_on;
T1 = (t1+t2+t3+t4+t5+t6+t7)*Params.rep;
T2 = Params.time_ITI*(Params.rep-1);
TIME = (T1+T2)/60; %minutes      
clc
end




