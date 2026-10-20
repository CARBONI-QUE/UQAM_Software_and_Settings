cd z:\uqam-site\Matlab\
allYears= 2026;
sourceDatabase = 'Y:\GHG_database';
destinationDatabase = 'z:\uqam-site\Database';


allSites = get_TAB_site_names;
for currentSiteID = allSites
    siteID = char(currentSiteID);
    if strcmpi(siteID,'BB1')
        siteID = 'BB';
    end
    fprintf('Syncing GHG Database for: %s\n',siteID);
    for yearIn = allYears
        fprintf('   Year: %d\n',yearIn);
        sourceFolder      = fullfile(sourceDatabase,     num2str(yearIn),siteID);
        destinationFolder = fullfile(destinationDatabase,num2str(yearIn),siteID);
        cmd = sprintf("robocopy %s  %s  /R:3 /W:2 /E /NDL /NFL  /log:ReportGHT_sync.txt",sourceFolder,destinationFolder);
        [status,cmdout] = system(cmd);
        [status2,cmdout2] = system(['type ReportGHT_sync.txt']);
        disp(cmdout2);
    end
end

