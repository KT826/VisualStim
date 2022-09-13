function [Pix] = deg2pix(ang,dist,pixpitch)

%�O�p�֐���p���āA�~�����p�x�ɑΉ�����s�N�Z���������߂�.
%ref: http://www.s12600.net/psy/python/ppb/html/chapter02.html

%ang: �Z�o�������p�x
%dist: �����̋���
%dixpitch: monitor 1�s�N�Z��������� ���� (cm)
%Pix.ang = 2;
%Pix.dist = 10;
%Pix.pixpitch=0.1;

%DELL 2007FP <800x600> �̎�.
%Pix.pixpitch=0.051; %cm


if nargin  == 3
    syms x
    Pix.cm = solve(ang == tan(x/dist) * (180/pi), x);
    Pix.cm  =double(Pix.cm);
    Pix.n_pixel = round(Pix.cm/pixpitch);
    Pix.n_pixel;
else 
    disp('error @ deg2pix')
    return
end
Pix.ang = ang;
Pix.dist = dist;
Pix.pixpitch= pixpitch;

%{
syms x
S = double(solve(10 == round(x/0.05), x))
syms x
SS = double(solve(x == tan(S/30) * (180/pi), x));
%}

end