function [stim] = Chirp_Presert(Params)
global monitor
global grid

%% Common %%
stim=[];
stim.common.feature = Params.stim_feature; %'FillOval' or 'FIllRect
stim.common.rep = Params.rep;
stim.common.center = Params.stim_PosiCenter;
stim.common.centroid = [grid.position.w_column(Params.stim_PosiCenter)'; grid.position.h_column(Params.stim_PosiCenter)]; %row1:x, row2:y
stim.common.size_deg = Params.stim_size;
%calculate pixel size %
for i = 1 : numel(stim.common.size_deg)
    [Pix] = func.deg2pix(stim.common.size_deg(i), monitor.dist, monitor.pixpitch);
    stim.common.size_pix(1,i) = Pix.n_pixel;
end


%% LDAI %%
stim.LDAI.color_bk = monitor.color.BG(1);
stim.LDAI.black = monitor.color.black;
stim.LDAI.white = monitor.color.white;

%% 2: Frequency modulation %%%
stim.FM.gga0 = [];
n_frm_fm=monitor.fps*Params.Stim_FM.time_on;%8sec;
str_npr=Params.Stim_FM.SF;
nff=round(n_frm_fm/length(str_npr));
for ps=1:length(str_npr)
    n_period=str_npr(ps)*2;%
    theta=90;
    d_phase=45/1.245;
    degrees=pi/180;
    a=1;%period
    theta=theta*degrees;
    ff=0.6;
    %
    %n_period=4;
    %
    sx=n_period*a;
    sy=n_period*a;
    nres=100;
    %
    dx=a/nres;
    dy=a/nres;
    nx=ceil(sx/dx);
    dx=sx/nx;
    ny=ceil(sy/dy);
    dy=sy/ny;
    xa=[0:nx-1]*dx;
    xa=xa-mean(xa);
    ya=[0:ny-1]*dy;
    ya=ya-mean(ya);
    %
    [Y,X]=meshgrid(ya,xa);
    Fx=(2*pi/a)*cos(theta);
    Fy=(2*pi/a)*sin(theta);
    GA=cos(Fx*X+Fy*Y+d_phase);
    %
    gga=GA(1,:);
    gga=resample(gga,nff,length(gga));
    %
    if str_npr(ps)==0.5;
       bs_am=gga; 
    end
    if ps==1;
        gga0=gga;
    else
        if ps==2;
            gga0=[gga0,gga*-1];
        else
            gga0=[gga0,gga*-1];
        end
    end
end
gga0=(gga0*-1+1)/2;
gga0=gga0*255;
stim.FM.gga0 = gga0;


%% 3: Amplitude modulation %%%
stim.AM.ggb0 = [];

bs_am=bs_am*255;
str_amp=Params.Stim_AM.amp;
for ps=1:length(str_amp);
    ggb=bs_am*(str_amp(ps)/100);
    ggb=((ggb*-1));
    if ps==1;
        ggb0=ggb;
    else
        ggb0=[ggb0,ggb];
    end
end
ggb0=ggb0-min(ggb0);
ggb0=ggb0/max(ggb0);
ggb0=ggb0*(255);

stim.AM.ggb0 = ggb0;

end