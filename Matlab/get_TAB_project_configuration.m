function structProject = get_TAB_project_configuration(projectPath)
% This function will be replaced with a single config.yml file
% in the projectPath folder that the parent function will read.
%
% To simplify writing of YAML config files and reduce cutting and pasting
% errors, we could write a Matlab GUI to create the initial YAML using the code
% below. The resulting YAML can then be
% edited by either the same GUI or by the user using a text editor.
% 
% Here is the matlab structure structProject that could be saved
% as YAML file using yaml.dumpFile function.
%-------- start yaml ---------------------
projectName = 'UQAM';
structProject.projectName   = projectName;
structProject.ismain        = true;     % false if this is a recalc PC, 
                                        % true if this is the main server
structProject.path          = fullfile(projectPath);
structProject.databasePath  = fullfile(structProject.path,'Database');
structProject.sitesPath     = fullfile(structProject.path,'Sites');
structProject.matlabPath    = fullfile(structProject.path,'Matlab');
structProject.hfPath        = structProject.sitesPath; % location of the siteID/HighFrequencyData folder

%===========================
siteID = 'UQAM_1';
structProject.sites.(siteID).siteID = siteID;
structProject.sites.(siteID).siteIP = "68.182.132.135";
structProject.sites.(siteID).netCam_Link                = ['http://' char(structProject.sites.(siteID).siteIP) ':4925/netcam.jpg'];
structProject.sites.(siteID).monitorSitesDataPath       = fullfile(structProject.sitesPath,siteID,'monitorSites\data');
structProject.sites.(siteID).monitorSitesHHourPath      = fullfile(structProject.sitesPath,siteID,'monitorSites\hhour');
structProject.sites.(siteID).EP_template                = 'Templates/ClosedPathStandard.eddypro';

% Flux instruments
structProject.sites.(siteID).dataSources.flux.LI7200 = true;
structProject.sites.(siteID).dataSources.flux.LI7500 = false;
structProject.sites.(siteID).dataSources.flux.LI7700 = true;

% Data logger tables
tableNum = 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_30m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 30;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = 'Met';
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'RawData_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);

% ECCC stations
structProject.sites.(siteID).dataSources.eccc(1).stationsID                    = 10732;
structProject.sites.(siteID).dataSources.eccc(1).stationsName                  = 'NICOLET';
% structProject.sites.(siteID).dataSources.eccc(2).stationsID                    = 27646;
% structProject.sites.(siteID).dataSources.eccc(2).stationsName                  = 'SHAWINIGAN';
% structProject.sites.(siteID).dataSources.eccc(3).stationsID                    = 8321;
% structProject.sites.(siteID).dataSources.eccc(3).stationsName                  = 'TROIS-RIVIERES';

%===========================
siteID = 'UQAM_2';
structProject.sites.(siteID).siteID = siteID;
structProject.sites.(siteID).siteIP = "68.182.132.133";
structProject.sites.(siteID).netCam_Link                = ['http://' char(structProject.sites.(siteID).siteIP) ':4925/netcam.jpg'];
structProject.sites.(siteID).monitorSitesDataPath       = fullfile(structProject.sitesPath,siteID,'monitorSites\data');
structProject.sites.(siteID).monitorSitesHHourPath      = fullfile(structProject.sitesPath,siteID,'monitorSites\hhour');
structProject.sites.(siteID).EP_template                = 'Templates/ClosedPathStandard.eddypro';

% Flux instruments
structProject.sites.(siteID).dataSources.flux.LI7200 = true;
structProject.sites.(siteID).dataSources.flux.LI7500 = false;
structProject.sites.(siteID).dataSources.flux.LI7700 = true;

% Data logger tables
tableNum = 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_30m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 30;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = 'Met';
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'RawData_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);

% ECCC stations
structProject.sites.(siteID).dataSources.eccc(1).stationsID                    = 27646;
structProject.sites.(siteID).dataSources.eccc(1).stationsName                  = 'SHAWINIGAN';

%===========================
siteID = 'UQAM_3';
structProject.sites.(siteID).siteID = siteID;
structProject.sites.(siteID).siteIP = "96.1.34.212";
structProject.sites.(siteID).netCam_Link                = ['http://' char(structProject.sites.(siteID).siteIP) ':4925/netcam.jpg'];
structProject.sites.(siteID).monitorSitesDataPath       = fullfile(structProject.sitesPath,siteID,'monitorSites\data');
structProject.sites.(siteID).monitorSitesHHourPath      = fullfile(structProject.sitesPath,siteID,'monitorSites\hhour');
structProject.sites.(siteID).EP_template                = 'Templates/ClosedPathStandard.eddypro';

% Flux instruments
structProject.sites.(siteID).dataSources.flux.LI7200 = true;
structProject.sites.(siteID).dataSources.flux.LI7500 = false;
structProject.sites.(siteID).dataSources.flux.LI7700 = true;

% Data logger tables
tableNum = 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_30m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 30;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = 'Met';
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'RawData_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'EFOY_Data';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       =30;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);

% ECCC stations
structProject.sites.(siteID).dataSources.eccc(1).stationsID                    = 27646;
structProject.sites.(siteID).dataSources.eccc(1).stationsName                  = 'SHAWINIGAN';


%===========================
siteID = 'UQAM_4';
structProject.sites.(siteID).siteID = siteID;
structProject.sites.(siteID).siteIP = "161.184.80.112";
structProject.sites.(siteID).netCam_Link                = ['http://' char(structProject.sites.(siteID).siteIP) ':4925/netcam.jpg'];
structProject.sites.(siteID).monitorSitesDataPath       = fullfile(structProject.sitesPath,siteID,'monitorSites\data');
structProject.sites.(siteID).monitorSitesHHourPath      = fullfile(structProject.sitesPath,siteID,'monitorSites\hhour');
structProject.sites.(siteID).EP_template                = 'Templates/ClosedPathStandard.eddypro';

% Flux instruments
structProject.sites.(siteID).dataSources.flux.LI7200 = true;
structProject.sites.(siteID).dataSources.flux.LI7500 = false;
structProject.sites.(siteID).dataSources.flux.LI7700 = true;

% Data logger tables
tableNum = 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_30m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 30;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = 'Met';
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'RawData_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_30m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID 'B_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 30;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met','B');


tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID 'B_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met','B',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
% ECCC stations
structProject.sites.(siteID).dataSources.eccc(1).stationsID                    = 10762;
structProject.sites.(siteID).dataSources.eccc(1).stationsName                  = 'ST-CLOTILDE';


%===========================
siteID = 'MCGILL_1';
structProject.sites.(siteID).siteID = siteID;
structProject.sites.(siteID).siteIP = "173.181.213.63";
structProject.sites.(siteID).netCam_Link                = ['http://' char(structProject.sites.(siteID).siteIP) ':4925/netcam.jpg'];
structProject.sites.(siteID).monitorSitesDataPath       = fullfile(structProject.sitesPath,siteID,'monitorSites\data');
structProject.sites.(siteID).monitorSitesHHourPath      = fullfile(structProject.sitesPath,siteID,'monitorSites\hhour');
structProject.sites.(siteID).EP_template                = 'Templates/ClosedPathStandard.eddypro';

% Flux instruments
structProject.sites.(siteID).dataSources.flux.LI7200 = true;
structProject.sites.(siteID).dataSources.flux.LI7500 = false;
structProject.sites.(siteID).dataSources.flux.LI7700 = true;

% Data logger tables
tableNum = 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_30m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 30;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = 'Met';
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'RawData_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'SYS';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 30;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);

% ECCC stations
structProject.sites.(siteID).dataSources.eccc(1).stationsID                    = 10732;
structProject.sites.(siteID).dataSources.eccc(1).stationsName                  = 'NICOLET';

%% Add siteID_config.yml Metadata for all sites
% (if it exists)
allSites = fieldnames(structProject.sites);
allSites = allSites(:)';
for cSiteID = allSites
    siteID = char(cSiteID);
    configYMLpath = fullfile(structProject.databasePath,'Calculation_Procedures','TraceAnalysis_ini',siteID,[siteID '_config.yml']);
    if exist(configYMLpath,"file")
        configYML =  yaml.loadFile(configYMLpath);
        structProject.sites.(siteID).Metadata = configYML.Metadata;
    end
end


%-------- end yaml ---------------------------

