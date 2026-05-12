%% testing fr_EFOY_database
structProject=get_TAB_project;
siteID = 'UQAM_3';
yearIn = 2026;

%wildCardPath = 'Z:\uqam-site\Sites\UQAM_3\EFOY\430512-2437-80399*.xlsx';
%wildCardPath = 'Z:\uqam-site\Sites\UQAM_3\EFOY\e81c1a8b-4d8*.xlsx';
wildCardPath = fullfile(structProject.sitesPath,siteID,'EFOY','430512-2437-80399_2026-*.xlsx');

databasePath = fullfile(structProject.databasePath,'yyyy',siteID,'EFOY');
processProgressListPath = fullfile(structProject.databasePath,'log\EFOY_progress_list.mat');     % current folder
[numOfFilesProcessed,numOfDataPointsProcessed] = fr_EFOY_database(...
                wildCardPath,processProgressListPath,databasePath);

%%
tv=read_bor(fullfile(databasePath,'clean_tv'),8,[],yearIn);
tv_dt = datetime(tv,'ConvertFrom','datenum');
runTime=read_bor(fullfile(databasePath,'StackOperatingTime'),[],[],yearIn);
PowerOutput=read_bor(fullfile(databasePath,'PowerOutput'),[],[],yearIn);
RemainingTotalFuel=read_bor(fullfile(databasePath,'RemainingTotalFuel'),[],[],yearIn);
AmbientTemperature=read_bor(fullfile(databasePath,'AmbientTemperature'),[],[],yearIn);

figure(1)
tiledlayout("vertical");
cnt=1;

ax(cnt) = nexttile;
plot(tv_dt,runTime);
title('Run time')

cnt=cnt+1;
ax(cnt) = nexttile;
plot(tv_dt,PowerOutput);
title('Power Output')

cnt=cnt+1;
ax(cnt) = nexttile;
plot(tv_dt,RemainingTotalFuel);
title('Remaining Total Fuel')

cnt=cnt+1;
ax(cnt) = nexttile;
plot(tv_dt,AmbientTemperature);
title('Ambient Temperature')

linkaxes(ax,'x')
zoom on


