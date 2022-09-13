function sparse_all_field
%memo last update: 20/2/5
%memo: all dispay-filed
%memo: start TTL to cha-0

%’†g‚Ì\¬
%1: monitor î•ñŽæ“¾
%2: Ž‹ŠoŽhŒƒì¬
%3 run

filename = '20';
%memo: graybackground-> white for ON response, Black for OFF response.
tic
ListenChar(1); % need
AssertOpenGL; % Make sure the script is running on Psychtoolbox-3:
KbName('UnifyKeyNames'); % need

Screen('Screens');
screenNumber = 1;

%%%%variable & functions (setting parameter) %%%%
GetSecs; %need
WaitSecs(0.1);
rand('state', sum(100*clock)); %initialization

%stimulus-duration (sec) 
time_stimON = .03; %caution FRAME RATE
%inter-stimulus-interval-(sec) 
time_ISI = .0;
%pre-monitor(sec) 
time_Pre = 30;
%sampling baseline activity(sec)
PreSampling = 5;
%repetition
rep =10;
%grid
divmonitor = 16; %should be even number
%ntrials = divmonitor^2;


%BG
bgColor = [120 120 120];
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
%feature of stimulus
stim_feature = 'FillRect'; %'FillOval', 'FIllRect';      
% 'order' or 'rand'
order_type = 'rand';
% 'square' or 'rectangle'
S_R = 'square';

%
%%%%%NI-DAQ & TTL setting%%%%%
device = daq.getDevices;
%white(stim1). stimulus duration
dio.TTL.w = daq.createSession('ni');
addDigitalChannel(dio.TTL.w,device.ID, 'port0/line6', 'OutputOnly');
outputSingleScan(dio.TTL.w,[0]) % reset TTL
%black(stim2). stimulus duration
dio.TTL.k = daq.createSession('ni');
addDigitalChannel(dio.TTL.k,device.ID, 'port0/line7', 'OutputOnly');
outputSingleScan(dio.TTL.k,[0]) % reset TTL
%start trigger (initial trigger = intan starts sampling). transient pulse
dio.TTL.start = daq.createSession('ni');
addDigitalChannel(dio.TTL.start,device.ID, 'port0/line0', 'OutputOnly');
outputSingleScan(dio.TTL.start,[0]) % reset TTL
%sparse start & end. transient pulse
dio.TTL.SE = daq.createSession('ni');
addDigitalChannel(dio.TTL.SE,device.ID, 'port0/line2', 'OutputOnly');
outputSingleScan(dio.TTL.SE,[0]) % reset TTL
%



try
  %Open PTB
  [expWin, windowRect] = Screen('OpenWindow', screenNumber, bgColor);
  h = windowRect(4); %[0 0 800 600] 
  w = windowRect(3);
  ls = h /divmonitor; % lenght of square
  n_h = divmonitor;
  n_w = fix(w/ls);
  ntrials = n_w * n_h; 
  stimColor = repmat([ white; black],(ntrials/2)*rep*2,1); 
  
  %%prepare OUTPUT%%
  OUTPUTs_1.bgcolor = bgColor;
  OUTPUTs_1.time_stimON = time_stimON;
  OUTPUTs_1.stimcolor = stimColor;
  OUTPUTs_1.stimfeature = 'circle';
  %OUTPUTs_1.stimsize= radius;
  OUTPUTs_1.divmonitor= divmonitor^2;
  OUTPUTs_1.time_ISI= time_ISI;
  OUTPUTs_1.time_Pre= time_Pre;
  OUTPUTs_1.order_type = order_type;
  colHeaders_OP2 = {'#trial-through-all-trials','#repetition', '#grid', 'posiX', 'posiY', 'color', 'display time(sec)', 'frame number'};
  OUTPUTs_2 = NaN * ones(divmonitor^2*rep,length(colHeaders_OP2)); 
  %%%%%%%%%%%%%%%%%%
  
  
  %refresh rate (frame-per-second)
  Screen('Preference', 'SkipSyncTests', 0);
  fps = Screen('FrameRate',expWin); % frames per second
  %inter-frame-interval
  ifi = Screen('GetFlipInterval', expWin);

  %time_pre
  Pre_Disp = Screen('Flip', expWin); % display 
  Screen('Flip', expWin, Pre_Disp + time_Pre);  
  
  WaitSecs(PreSampling)
  %
  %%%TTL. sampling start (baseline recording)%%%
  outputSingleScan(dio.TTL.start,[1]) % TTL output   
  outputSingleScan(dio.TTL.start,[0]) % reset TTL
  %
  
  %%% coordination of screen center
  clear position  
  if strcmp(S_R, 'square')
      %center positions  
      position.base_w = (ls/2) : ls : w;
      if numel(position.base_w) ~= n_w
          position.base_w = position.base_w(1:n_w)
      end
      position.w = repmat(position.base_w, n_h,1);
      position.base_h = transpose((ls/2) : ls : h);
      position.h = repmat(position.base_w,n_w,1)'
      position.h = position.h(1:n_h,1:n_w);
      
  
  elseif strcmp(S_R, 'rectangle')
  %    w = windowRect(3);
  %    h = windowRect(4);
  %    ls = 50; %size(pixel)
      %center positions
  %    for p = 1 : divmonitor
  %        for q = 1 : divmonitor
  %            position.w(q,p) = (w/(divmonitor+1)) * p;
   %           position.h(p,q) = (h/(divmonitor+1)) * p;
   %       end
    %  end
  end

  size(position.w)
  size(position.h)
  
  position.w = reshape(position.w, ntrials,1);
  position.h = reshape(position.h,1,ntrials);
  
  ri = 0;
  disp_time = [NaN, 0];
  for repetiton = 1 : rep
      repetiton
      n_w, n_h
      if strcmp(order_type, 'order')
          TrialOrder= 1 : ntrials;
      elseif strcmp(order_type, 'rand')
          %TrialOrder= randperm(ntrials); %re-order trials randomly
          TrialOrder_pre = randperm(ntrials); %re-order trials randomly
          TrialOrder = f_Interlacer(TrialOrder_pre(1:(end/2)), TrialOrder_pre((end/2)+1:end), repetiton);
      end
      
      %%%% TTL. timing of each repetitions start%%%%
      outputSingleScan(dio.TTL.SE,[1]) % TTL output
      outputSingleScan(dio.TTL.SE,[0]) % reset TTL
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      for i = 1 : size(TrialOrder,1) %ntrials
          
          posiX = position.w(TrialOrder(i,1));
          posiY = position.h(TrialOrder(i,1));
          Screen(stim_feature, expWin, stimColor(i,:), [posiX - (ls/2), posiY - (ls/2), posiX + (ls/2), posiY + (ls/2)]);
          
          %%% stim ON %%%
          [VBLTimestamp, StimulusDisplayTime_ON, FlipTimestamp] = Screen('Flip', expWin);
          switch stimColor(i,:)
              case white
                  outputSingleScan(dio.TTL.w,[1]) % TTL output
              case black 
                  outputSingleScan(dio.TTL.k,[1]) % TTL output
          end
                  
          %%% measure display time %%%
          ri = ri + 1;
          disp_time(ri,1) = StimulusDisplayTime_ON;
          if ri > 1
              disp_time(ri,2) = disp_time(ri,1) - disp_time(ri-1,1);
          end
          WaitSecs(time_stimON);
          
          switch stimColor(i,:)
              case white
                  outputSingleScan(dio.TTL.w, [0]) % TTL output
              case black 
                 outputSingleScan(dio.TTL.k, [0]) % TTL output
          end
          
          %%% stim OFF %%%
          if ~time_ISI == 0
              tic;
              ISI_Disp = Screen('Flip', expWin); % BackGround Screen 
              WaitSecs(time_ISI);
              toc;
          end
          OUTPUTs_2(ri,:) = [ri,repetiton,TrialOrder(i),posiX,posiY,stimColor(i),disp_time(ri,2),NaN];
      end
  end
  
  %%%% TTL. timing of trials end %%%%
  outputSingleScan(dio.TTL.SE,[1]) % TTL output
  outputSingleScan(dio.TTL.SE,[0]) % reset TTL
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %calculate  frame number%
  %ifi
  
  %write results to comma delimited text file (use '\t' for tabs)
  save(['OUTPUTs_' filename '.mat'], 'OUTPUTs_2', 'OUTPUTs_1')
  
  %End process
  Post_Disp = Screen('Flip', expWin); % display 
  WaitSecs(3);
  %Screen('Flip', expWin, Post_Disp + 1);  
  Screen('CloseAll');
  ShowCursor;
  ListenChar(0); clc
  toc
  
  outputSingleScan(dio.TTL.w,[0]) % reset TTL
  outputSingleScan(dio.TTL.k,[0]) % reset TTL
  outputSingleScan(dio.TTL.start,[0]) % reset TTL
  outputSingleScan(dio.TTL.SE,[0]) % reset TTL
catch
  Screen('CloseAll');
  ShowCursor;
  ListenChar(0);
  psychrethrow(psychlasterror);
  
end

%%
