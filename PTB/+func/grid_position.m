function [grid] = grid_position(w,h,divmonitor)

%w = monitor.rect(3); %wide
%h = monitor.rect(4); %hight

grid.hight = divmonitor; %��ʏc��grid���i�������j�^��z��.��grid���͏cgrid�������ƂɎZ�o�j
grid.wide = [];
grid.ls = (h /grid.hight); % lenght of square (pixel)
grid.wide = fix(w/grid.ls);
n_trails = grid.hight * grid.wide; 

%%�h���񎦂̉�ʍ��W�擾
position.base_w = (grid.ls/2) : grid.ls : w;
if numel(position.base_w) ~= grid.wide %�f�o�b�N
    position.base_w = position.base_w(1:grid.wide);
end

position.w = repmat(position.base_w, grid.hight,1);
position.base_h = transpose((grid.ls/2) : grid.ls : h);
position.h = repmat(position.base_w, grid.wide,1)';
position.h = position.h(1 : grid.hight, 1 : grid.wide);

%�f�o�b�N
if size(position.w) ~= size(position.h)
    disp('ERROR@grid')
    return
end

grid.position.w_grid = position.w;
grid.position.h_grid = position.h;

grid.position.w_column = reshape(position.w, n_trails,1);
grid.position.h_column= reshape(position.h,1, n_trails);

%%grid position���킩��悤�� figure ���%%
figure('Position',[0 0 1000 800]/2,'name', 'monitor')

l2 = grid.ls/2;
for i = 1 : (grid.hight * grid.wide)
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
for i = 1 : grid.wide
    for ii = grid.hight: -1 : 1
        X = grid.position.w_grid(1,i);
        Y = grid.position.h_grid(ii,1);
        text(X,Y,num2str(n))
        n = n + 1;
    end
end
        
end
