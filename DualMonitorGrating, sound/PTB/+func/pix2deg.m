function [Deg] = pix2deg(pixs,dist,pixpitch)

%三角関数を用いて、ピクセル数から視野角を求める.
%ref: http://www.s12600.net/psy/python/ppb/html/chapter02.html

%pixs: ピクセル数
%dist: 視軸の距離
%dixpitch: monitor 1ピクセルあたりの 長さ (cm)
%pixpitch = 0.05;
%dist = 30;
pixs = fix(pixs);

syms x1
Deg.cm = double(solve(pixs == round(x1/pixpitch), x1)); %cm
syms x2
Deg.deg = double(solve(x2 == tan(Deg.cm/dist) * (180/pi), x2));


end