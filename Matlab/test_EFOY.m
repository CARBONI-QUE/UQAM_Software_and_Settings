%% testing fr_EFOY_database

siteID = 'UQAM_3';

%wildCardPath = 'Z:\uqam-site\Sites\UQAM_3\EFOY\430512-2437-80399*.xlsx';
%wildCardPath = 'Z:\uqam-site\Sites\UQAM_3\EFOY\e81c1a8b-4d8*.xlsx';
wildCardPath = 'Z:\uqam-site\Sites\UQAM_3\EFOY\430512-2437-80399_2026-03-08*.xlsx';

databasePath = fullfile('Z:\uqam-site\Database','yyyy',siteID,'EFOY');
processProgressListPath = 'Z:\uqam-site\Database\log\EFOY_progress_list';     % current folder
[numOfFilesProcessed,numOfDataPointsProcessed] = fr_EFOY_database(...
                wildCardPath,processProgressListPath,databasePath);

