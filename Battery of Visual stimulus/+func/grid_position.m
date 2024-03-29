function [grid] = grid_position(w,h,divmonitor)

%w = monitor.rect(3); %wide
%h = monitor.rect(4); %hight
grid.height = divmonitor; %画面縦のgrid数（横長モニタを想定.横grid数は縦grid数をもとに算出）
grid.width = [];
grid.ls = (h /grid.height); % lenght of square (pixel)
grid.width = fix(w/grid.ls);
n_trails = grid.height * grid.width; 

%%刺激提示の画面座標取得
position.base_w = (grid.ls/2) : grid.ls : w;
if numel(position.base_w) ~= grid.width %デバック
    position.base_w = position.base_w(1:grid.width);
end

position.w = repmat(position.base_w, grid.height,1);
position.base_h = transpose((grid.ls/2) : grid.ls : h);
position.h = repmat(position.base_w, grid.width,1)';
position.h = position.h(1 : grid.height, 1 : grid.width);

%デバック
if size(position.w) ~= size(position.h)
    disp('ERROR@grid')
    return
end

grid.position.w_grid = position.w;
grid.position.h_grid = position.h;

grid.position.w_column = reshape(position.w, n_trails,1);
grid.position.h_column= reshape(position.h,1, n_trails);

%%grid positionがわかるように figure 作る%%
figure('Position',[0 0 1000 800]/2,'name', 'monitor')

l2 = grid.ls/2;
for i = 1 : (grid.height * grid.width)
    W = grid.position.w_column(i) - l2;
    H = grid.position.h_column(i) - l2;
    rectangle('Position',[W,H,grid.ls,grid.ls])
    
end
xlim([0 w])
ylim([0 h])
pbaspect([w h 1])
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])   

n = 1;
for i = 1 : grid.width
    for ii = grid.height: -1 : 1
        X = grid.position.w_grid(1,i);
        Y = grid.position.h_grid(ii,1);
        text(X,Y,num2str(n))
        n = n + 1;
    end
end
        
end
