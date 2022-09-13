function [Deg] = pix2deg(pixs,dist,pixpitch)

%�O�p�֐���p���āA�s�N�Z�������王��p�����߂�.
%ref: http://www.s12600.net/psy/python/ppb/html/chapter02.html

%pixs: �s�N�Z����
%dist: �����̋���
%dixpitch: monitor 1�s�N�Z��������� ���� (cm)
%pixpitch = 0.05;
%dist = 30;
pixs = fix(pixs);

syms x1
Deg.cm = double(solve(pixs == round(x1/pixpitch), x1)); %cm
syms x2
Deg.deg = double(solve(x2 == tan(Deg.cm/dist) * (180/pi), x2));


end