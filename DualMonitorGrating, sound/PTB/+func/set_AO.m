function [ao_vector] = set_AO(voltage_intan,voltage_led)

global ao
global ao_vector
%%
%ao.Rate = 1000;
ao_vector = [];

%voltage_intan %ao cha-0
%voltage_led %ao cha-1
    
try 
    
    if voltage_intan >= 5
        voltage_intan = 3.0;
    end
    
    if voltage_led >= 5
        voltage_led = 3.0;
    end
    
    %%
    %without laser (empty vector)
    ao0 = zeros(ao.Rate,2);
    ao0(1:ao.Rate,1:2) = 0;
    ao_vector.ao0.vector = ao0;
    ao_vector.ao0.hz = NaN;
    ao_vector.ao0.duration = NaN;
    
    %%
    %800ms duration
    ao1 = zeros(ao.Rate,2);
    ao1(1:800,1) = voltage_intan;
    ao1(1:800,2) = voltage_led;
    
    ao_vector.ao1.vector = ao1;
    ao_vector.ao1.hz = 1;
    ao_vector.ao1.duration = 800;
    
    %% '10Hz: 50msON-50msOFF';
    hz = 10;
    duration = 50;
    ao2 = zeros(ao.Rate,2);
    
    for i = 0 : hz-1
        t1 = (1000/hz)*i+1;
        t2 = t1 + (duration-1);  
        ao2(t1:t2,1) = voltage_intan;
        ao2(t1:t2,2) = voltage_led;
    end
    ao2(800:end,:) = 0;
    ao_vector.ao2.vector = ao2;
    ao_vector.ao2.hz = hz;
    ao_vector.ao2.duration = duration;
   
    %% '20Hz: 25msON-25msOFF';
    hz = 20;
    duration = 25;
    ao3 = zeros(ao.Rate,2);
    
    for i = 0 : (hz-1)
        t1 = (1000/hz)*i+1;
        t2 = t1 + (duration-1);  
        ao3(t1:t2,1) = voltage_intan;
        ao3(t1:t2,2) = voltage_led;
    end
    ao3(800:end,:) = 0;
    ao_vector.ao3.vector = ao3;
    ao_vector.ao3.hz = hz;
    ao_vector.ao3.duration = duration;
    
    %%  '50Hz: 10msON-10msOFF';
    hz = 50;
    duration = 10;
    ao4 = zeros(ao.Rate,2);
    
    for i = 0 : (hz-1)
        t1 = (1000/hz)*i+1;
        t2 = t1 + (duration-1);  
        ao4(t1:t2,1) = voltage_intan;
        ao4(t1:t2,2) = voltage_led;
    end
    ao4(800:end,:) = 0;
    ao_vector.ao4.vector = ao4;
    ao_vector.ao4.hz = hz;
    ao_vector.ao4.duration = duration;
   
    
    %%
    ao_vector.n = 5;
    

catch
    ao_vector = [];
    disp('ERROR@ No AO vector')
end
end
   
