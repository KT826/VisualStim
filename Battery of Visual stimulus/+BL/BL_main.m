function Looming_main(Params)

disp('Press any key to start'); 
pause
%%
global do
global monitor
global grid
global expWin
global path_save


%% main loop
for rep = 1 : Params.rep
    %% trigger-ON/OFF
    clc
    disp(['Sweep ',num2str(rep),'/',num2str(Params.rep)])
    outputSingleScan(do.TTL.nVoke_Ex,[1,1,1])% nVoke rec started.
    T = tic;
    while toc(T)< Params.time_on; end
    outputSingleScan(do.TTL.nVoke_Ex,[0,0,0])% nVoke rec stop.
    
    %% interval+
    T = tic;
    while toc(T)< Params.time_ITI;end
end

%% save
matfiles=what(path_save);
matfiles_n = num2str(numel(matfiles.mat) + 1);
file_dt = datevec(datetime); 
filename_date = [num2str(file_dt(1)), num2str(file_dt(2)),num2str(file_dt(3)),num2str(file_dt(4)),num2str(file_dt(5))];
filename = [path_save '/' matfiles_n '_BaseLine_' filename_date];
save([filename '.mat'], 'Params')

disp(['DONE'])

end

