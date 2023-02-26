%%%% make sound (sin) %%%%
clear all
%% FIX. DO NOT  CHANGE
Fs = 22050;
t = 0:1/Fs:2*pi;

%%
SoundHz = 15000;
x_15k = sin(2*pi*SoundHz*t);

SoundHz = 19000;
x_19k = sin(2*pi*SoundHz*t);

X = zeros(Fs*2,1);
X(1:Fs) = x_15k(1:Fs);
X(Fs+1:Fs*2) = x_19k(1:Fs);

SinNoise=X;
filename = 'Sin_k15Hz_19kHz5000Fs_2sec';
save(filename,'SinNoise','Fs');

filename = 'Sin_k15Hz_19kHz5000Fs_2sec.wav';
audiowrite(filename,SinNoise,Fs);


%sound(X*1,Fs)
%toc

