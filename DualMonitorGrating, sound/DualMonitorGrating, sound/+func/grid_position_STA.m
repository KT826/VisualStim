function grid_STA = grid_position_STA(grid,center_position,stim_size,monitor,divmoni)

h = grid.position.h_column(center_position);
w = grid.position.w_column(center_position);

[Pix_2] = deg2pix(stim_size * divmoni,monitor.dist,monitor.pixpitch);
%disp(['2degで16x16 gridを出すのに必要なピクセル数 = ', num2str(Pix_2.n_pixel)]);
half = round(Pix_2.n_pixel/2); %縦横方向には中心から上下にこの値だけ必要.
[Pix_3] = deg2pix(stim_size,monitor.dist,monitor.pixpitch);
Pix_3.n_pixel;

%%%% hight %%%%
n_grid.top = fix(h/Pix_3.n_pixel);
n_grid.btm = fix((monitor.rect(4) - h)/Pix_3.n_pixel);
switch n_grid.top < divmoni/2 || n_grid.btm < divmoni/2
    case 1
        if n_grid.top < divmoni/2       
            k = (divmoni/2) - n_grid.top;
            n_grid.btm = k + (divmoni/2);
        elseif n_grid.btm < (divmoni/2)
            k = (divmoni/2) - n_grid.btm;
            n_grid.top = k + (divmoni/2);
        end
    case 0
        n_grid.top = divmoni/2;
        n_grid.btm = divmoni/2;
end
range.h_top = h - (Pix_3.n_pixel * n_grid.top);
range.h_btm = h + (Pix_3.n_pixel * n_grid.btm);
%disp(['縦方向は、' num2str(range.h_top) '~' num2str(range.h_btm) ' の範囲で、' num2str(Pix_3.n_pixel) ' pixel の1-grid作成すればよい'])

%%%% wide %%%%
n_grid.left = fix(w/Pix_3.n_pixel);
n_grid.right = fix((monitor.rect(3) - w)/Pix_3.n_pixel);
switch n_grid.left < (divmoni/2)   || n_grid.right < (divmoni/2)  
    case 1
        if n_grid.right < (divmoni/2)        
            k = (divmoni/2) - n_grid.right;
            n_grid.left = k + (divmoni/2);
        elseif n_grid.left < (divmoni/2)
            k = (divmoni/2) - n_grid.left;
            n_grid.right = k + (divmoni/2);
        end
    case 0
        n_grid.left = (divmoni/2);
        n_grid.right = (divmoni/2);
end
range.w_left = w - (Pix_3.n_pixel * n_grid.left);
range.w_right = w + (Pix_3.n_pixel * n_grid.right);
range.grid_size_single = Pix_3.n_pixel;
range.grid_number = divmoni;
%disp(['横方向は、' num2str(range.w_left) '~' num2str(range.w_right) ' の範囲で、' num2str(Pix_3.n_pixel) ' pixel の1-grid作成すればよい'])

%%%
w = abs(range.w_right-range.w_left); %wide
h = abs(range.h_top-range.h_btm); %hight

%デバック
if w~=h
    disp('ERORR@h/w size')
    return
end

grid_STA.hight = divmoni; %画面縦のgrid数（横長モニタを想定.横grid数は縦grid数をもとに算出）
grid_STA.wide = divmoni;
grid_STA.ls = range.grid_size_single; % lenght of square (pixel)
n_trails = grid_STA.hight * grid_STA.wide; 

base_w = range.w_left+(range.grid_size_single/2):(range.grid_size_single):range.w_right;
base_h = range.h_top+(range.grid_size_single/2):(range.grid_size_single):range.h_btm;

grid_STA.position.w_grid = repmat(base_w, grid_STA.wide,1);
grid_STA.position.h_grid = repmat(base_h, grid_STA.hight,1)';

grid_STA.position.w_column = reshape(grid_STA.position.w_grid, n_trails,1);
grid_STA.position.h_column= reshape(grid_STA.position.h_grid,1, n_trails);


%%%% make figure %%%%
%%grid positionがわかるように figure 作る%%
%%% base grid = whole monitor 
close 
figure('Position',[0 0 800 600],'name', 'monitor')
subplot(1,2,1)
l2 = grid.ls/2;
for i = (grid.hight * grid.wide): -1 :1
    W = grid.position.w_column(i) - l2;
    H = grid.position.h_column(i) - l2;
    rectangle('Position',[W,H,grid.ls,grid.ls])    
end

xlim([0 monitor.rect(3)])
ylim([0 monitor.rect(4)])
pbaspect([monitor.rect(3) monitor.rect(4) 1])
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

%%%center_positionをハイライト
W = grid.position.w_column(center_position) - l2;
%トリッキーだけど、高さ座標計算し直す.
h = grid.position.h_column(center_position);
w = grid.position.w_column(center_position);

[Pix_2] = deg2pix(stim_size * divmoni,monitor.dist,monitor.pixpitch);
%disp(['2degで16x16 gridを出すのに必要なピクセル数 = ', num2str(Pix_2.n_pixel)]);
half = round(Pix_2.n_pixel/2); %縦横方向には中心から上下にこの値だけ必要.
[Pix_3] = deg2pix(stim_size,monitor.dist,monitor.pixpitch);
Pix_3.n_pixel;

%%%% hight %%%%
n_grid.top = fix(h/Pix_3.n_pixel);
n_grid.btm = fix((monitor.rect(4) - h)/Pix_3.n_pixel);
switch n_grid.top < divmoni/2 || n_grid.btm < divmoni/2
    case 1
        if n_grid.top < divmoni/2       
            k = (divmoni/2) - n_grid.top;
            n_grid.btm = k + (divmoni/2);
        elseif n_grid.btm < (divmoni/2)
            k = (divmoni/2) - n_grid.btm;
            n_grid.top = k + (divmoni/2);
        end
    case 0
        n_grid.top = divmoni/2;
        n_grid.btm = divmoni/2;
end
range.h_top = h - (Pix_3.n_pixel * n_grid.top);
range.h_btm = h + (Pix_3.n_pixel * n_grid.btm);
%disp(['縦方向は、' num2str(range.h_top) '~' num2str(range.h_btm) ' の範囲で、' num2str(Pix_3.n_pixel) ' pixel の1-grid作成すればよい'])

%%%% wide %%%%
n_grid.left = fix(w/Pix_3.n_pixel);
n_grid.right = fix((monitor.rect(3) - w)/Pix_3.n_pixel);
switch n_grid.left < (divmoni/2)   || n_grid.right < (divmoni/2)  
    case 1
        if n_grid.right < (divmoni/2)        
            k = (divmoni/2) - n_grid.right;
            n_grid.left = k + (divmoni/2);
        elseif n_grid.left < (divmoni/2)
            k = (divmoni/2) - n_grid.left;
            n_grid.right = k + (divmoni/2);
        end
    case 0
        n_grid.left = (divmoni/2);
        n_grid.right = (divmoni/2);
end
range.w_left = w - (Pix_3.n_pixel * n_grid.left);
range.w_right = w + (Pix_3.n_pixel * n_grid.right);
range.grid_size_single = Pix_3.n_pixel;
range.grid_number = divmoni;
%disp(['横方向は、' num2str(range.w_left) '~' num2str(range.w_right) ' の範囲で、' num2str(Pix_3.n_pixel) ' pixel の1-grid作成すればよい'])

%%%
w = abs(range.w_right-range.w_left); %wide
h = abs(range.h_top-range.h_btm); %hight

%デバック
if w~=h
    disp('ERORR@h/w size')
    return
end

grid_STA.hight = divmoni; %画面縦のgrid数（横長モニタを想定.横grid数は縦grid数をもとに算出）
grid_STA.wide = divmoni;
grid_STA.ls = range.grid_size_single; % lenght of square (pixel)
n_trails = grid_STA.hight * grid_STA.wide; 

base_w = range.w_left+(range.grid_size_single/2):(range.grid_size_single):range.w_right;
base_h = range.h_top+(range.grid_size_single/2):(range.grid_size_single):range.h_btm;

grid_STA.position.w_grid = repmat(base_w, grid_STA.wide,1);
grid_STA.position.h_grid = repmat(base_h, grid_STA.hight,1)';

grid_STA.position.w_column = reshape(grid_STA.position.w_grid, n_trails,1);
grid_STA.position.h_column= reshape(grid_STA.position.h_grid,1, n_trails);


%%%% make figure %%%%
%%grid positionがわかるように figure 作る%%
%%% base grid = whole monitor 
close 
figure('Position',[0 0 800 600],'name', 'monitor')
subplot(1,2,1)
l2 = grid.ls/2;
for i = (grid.hight * grid.wide): -1 :1
    W = grid.position.w_column(i) - l2;
    H = grid.position.h_column(i) - l2;
    rectangle('Position',[W,H,grid.ls,grid.ls])    
end

xlim([0 monitor.rect(3)])
ylim([0 monitor.rect(4)])
pbaspect([monitor.rect(3) monitor.rect(4) 1])
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

%%%center_positionをハイライト
W_highlight = grid.position.w_column(center_position) - l2;
%トリッキーだけど、高さ座標計算し直す.
h2 = grid.position.h_grid(end:-1:1,:);
h3 = reshape(h2,1,numel(h2));
H_highlight = h3(center_position) - l2;
rectangle('Position',[W_highlight,H_highlight,grid.ls,grid.ls],'EdgeColor','b','LineWidth',10)  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% grid for STA
subplot(1,2,2)
l3 = grid_STA.ls/2;
h2 = monitor.rect(4) - grid_STA.position.h_grid;
h3 = reshape(h2,1,numel(h2));
for i = 1 : (grid_STA.hight * grid_STA.wide)
    W = grid_STA.position.w_column(i) - l3;
    H = h3(i) - l3;
    rectangle('Position',[W,H,grid_STA.ls,grid_STA.ls],'FaceColor','r')    
end

rectangle('Position',[W_highlight,H_highlight,grid.ls,grid.ls],'EdgeColor','b','LineWidth',10)  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlim([0 monitor.rect(3)])
ylim([0 monitor.rect(4)])
pbaspect([monitor.rect(3) monitor.rect(4) 1])
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])  


end

