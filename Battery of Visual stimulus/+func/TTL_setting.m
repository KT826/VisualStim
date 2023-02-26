function TTL_setting

global ao
global do
%%
try 
    do = [];
    %%%%%NI-DAQ & TTL setting%%%%%
    
   %% Digital 
   %daq.getVendors
   device = daq.getDevices;
   
   %Rec trigger 
   do.TTL.nVoke_Ex = daq.createSession('ni');
   addDigitalChannel(do.TTL.nVoke_Ex,device.ID, 'port0/line0:2', 'OutputOnly');
   outputSingleScan(do.TTL.nVoke_Ex,[0,0,0]) % reset TTL
   
   %Stim timing
   do.TTL.StimTiming = daq.createSession('ni');
   addDigitalChannel(do.TTL.StimTiming,device.ID, 'port1/line0:1', 'OutputOnly');
   outputSingleScan(do.TTL.StimTiming,[0,0]) % reset TTL
   
   %Stim timing(Optional)
   do.TTL.StimTiming_sub = daq.createSession('ni');
   addDigitalChannel(do.TTL.StimTiming_sub,device.ID, 'port0/line4:5', 'OutputOnly');
   outputSingleScan(do.TTL.StimTiming_sub,[0,0]) % reset TTL
   
   %Opt-Trig
   do.TTL.nVoke_OG = daq.createSession('ni');
   addDigitalChannel(do.TTL.nVoke_OG,device.ID, 'port1/line2:3', 'OutputOnly');
   outputSingleScan(do.TTL.nVoke_OG,[0,0]) % reset TTL
      
   %Audio-Trig
   do.TTL.nVoke_AUDIO = daq.createSession('ni');
   addDigitalChannel(do.TTL.nVoke_AUDIO,device.ID, 'port0/line6:7', 'OutputOnly');
   outputSingleScan(do.TTL.nVoke_AUDIO,[0,0]) % reset TTL

   
   %% 
   ao = daq.createSession('ni');
   addAnalogOutputChannel(ao,device.ID,'ao0','Voltage');
   addAnalogOutputChannel(ao,device.ID,'ao1','Voltage');
   disp('Success  TTL setting')

   
    
catch
    do = [];
    ao = [];
    disp('Error@ TTL setting')

end

end
