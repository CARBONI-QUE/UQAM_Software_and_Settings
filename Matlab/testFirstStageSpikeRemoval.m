% testFirstStageSpikeRemoval.m
%
% Compares first stage spike removal algorithms, currently: run_std_dev and
% remove_spikes_diurnal_nonParametric.
%
% Rosie Howard
% Based on initial code for run_std_dev only written by Zoran.
% 22 January 2026

% for now, compares one year at a time because I'm not sure whether the
% non-parametric function uses all the data you give it to create
% statistics or just uses a small window (look at code/ask Paul...), and
% given that we clean each year separately we want to mimic that.

%% load parameters
% clear;
clear;
projectPath = '/Users/rosie/Documents/Micromet/Projects/Carbonique/UQAM_Software_and_Settings/';
structProject = set_TAB_project(projectPath);

yearsIn = 2024:2026;
% yearIn = 2025;
siteID = 'UQAM_1'; 
dataType = 'Met';
%vars_list = {'MET_WaterCond_Avg', 'MET_WaterLevel_Avg', ...
 %            'MET_WaterORP_Avg', 'MET_WaterpH_Avg', ...
  %           'MET_WaterT_Avg'};

% parameters for run_std_dev
wlen = 24;
thres = 4;

%% load variables to test

vars_list = {};
ini_out = readIniFileDirect(yearIn,siteID,1);
% for i = 1:length(ini_out)
%     if contains(ini_out(i).ini.inputFileName,'MET')
%         param = ini_out(i).ini.inputFileName;
%     else
%         param = [];
%     end
%     if exist('param','var') & ~isempty(param)
%          vars_list{end+1} = param; 
%     end
% end

% automate gathering this list from first stage INI file , if it's
% old/already exists and needs testing...
for i = 1:length(ini_out)
    % if isfield(ini_out(i).ini,"postEvaluate")
    if isfield(ini_out(i).ini,"Evaluate1")
        % if contains(ini_out(i).ini.postEvaluate,'run_std_dev') || contains(ini_out(i).ini.postEvaluate,'remove_spikes_diurnal_nonParametric')
        if contains(ini_out(i).ini.Evaluate1,'run_std_dev') || contains(ini_out(i).ini.Evaluate1,'remove_spikes_diurnal_nonParametric')
            param = [ini_out(i).ini.inputFileName, ini_out(i).ini.variableName];
        else
            param = '';
        end
    end 
    if exist('param','var') & ~isempty(param)
         vars_list{end+1} = param; 
    end
end

flat = vertcat(vars_list{:});          % unwrap inner cells
flat = strtrim(string(flat)); 
vars_list_inputFileName = unique(flat(:,1),'stable');   % for testing raw data
vars_list_variableName = unique(flat(:,2),'stable');    % for testing first stage cleaned data

% vars_list_inputFileName = flat_unique_inputFileName;
% vars_list_variableName = flat_unique_variableName;

% Can be generalized to all files in raw data folder:
% list_files = dir(fullfile(biomet_database_default,num2str(yearIn),siteID,dataType));
% for i = 1:length(list_files)
%     baseFileName = list_files(i).name;
%     if strcmp(baseFileName,'.') ...
%             | strcmp(baseFileName,'..') ...
%             | strcmp(baseFileName,'.DS_Store') ...
%             | strcmp(baseFileName,'clean_tv') ...
%             | strcmp(baseFileName,'TimeVector') ...
%             | strcmp(baseFileName,'Clean') ...
%             | strcmp(baseFileName,'5min')

%% begin comparison

% run first stage cleaning without any spike removal, but including any
% Evaluate, minMax, calibration, etc., THEN look at remaining spikes.
% (spike removal should happen in postEvaluate)

clc;
% vars_list_variableName = {'TS_1_1_1';...
                          % 'TS_1_2_1';...
                          % 'TS_1_3_1';...
                          % 'TS_1_4_1';...
                          % 'TS_2_1_1';...
                          % 'TS_2_2_1';...
                          % 'TS_2_3_1';...
                          % 'TS_2_4_1';...
                          % 'TW_1_1_1'};

vars_list_variableName = {'D_SNOW'};

% for k = 1:length(vars_list_inputFileName)
for k = 1:length(vars_list_variableName)
    for yearIn = yearsIn
        % load data
        % mainTraceName = vars_list_inputFileName{k};
        mainTraceName = vars_list_variableName{k};
        fprintf('Running for %s\n',mainTraceName);

        pthDatabase = fullfile(biomet_database_default,'yyyy',siteID);
        clean_tv = read_bor(fullfile(pthDatabase,dataType,'Clean','clean_tv'),8,[],yearIn);
        tv_dt = datetime(clean_tv,'ConvertFrom','datenum');
        mainTrace = read_bor(fullfile(pthDatabase,dataType,'Clean',mainTraceName),[],[],yearIn);      % first stage !

        cleanTrace_SD = run_std_dev(mainTrace,clean_tv,wlen,thres);
        d1 = mainTrace - cleanTrace_SD;
        indRemoved1 = find(isnan(cleanTrace_SD) & ~isnan(mainTrace));

        cleanTrace_NP = remove_spikes_diurnal_nonParametric(mainTrace,clean_tv);
        d2 = mainTrace - cleanTrace_NP;
        indRemoved2 = find(isnan(cleanTrace_NP) & ~isnan(mainTrace));

        if ~isempty(indRemoved1)
            fprintf('*** Trace %s had %d points removed by run_std_dev for yearIn = %d\n',mainTraceName,length(indRemoved1),yearIn)
            % fprintf('*** Trace %s had %d points removed by run_std_dev for yearIn = %d:%d\n',mainTraceName,length(indRemoved1),yearIn(1), yearIn(end))
        else
            fprintf('No spikes found by run_std_dev for trace %s for yearIn = %d\n',mainTraceName,yearIn)
            % fprintf('Trace %s does not need spike removal for yearIn = %d:%d\n',mainTraceName,yearIn(1), yearIn(end))
        end

        if ~isempty(indRemoved2)
            fprintf('*** Trace %s had %d points removed by remove_spikes_diurnal_nonParametric for yearIn = %d\n',mainTraceName,length(indRemoved2),yearIn)
            % fprintf('*** Trace %s had %d points removed by remove_spikes_diurnal_nonParametric for yearIn = %d:%d\n',mainTraceName,length(indRemoved2),yearIn(1), yearIn(end))
        else
            fprintf('No spikes found by remove_spikes_diurnal_nonParametric for trace %s for yearIn = %d\n',mainTraceName,yearIn)
            % fprintf('Trace %s does not need spike removal for yearIn = %d:%d\n',mainTraceName,yearIn(1), yearIn(end))
        end

        figure(100)
        clf
        ax(1) = subplot(2,1,1);
        plot(tv_dt,mainTrace,tv_dt(indRemoved1),mainTrace(indRemoved1),'o')
        grid on
        title('run_std_dev','Interpreter','none')
        if ~isempty(indRemoved1)
            legend('', [num2str(length(indRemoved1)) ' points removed'],'Interpreter','none')
        end

        ax(2) = subplot(2,1,2);
        plot(tv_dt,mainTrace,tv_dt(indRemoved2),mainTrace(indRemoved2),'o')
        grid on
        title('remove_spikes_diurnal_nonParametric','Interpreter','none')
        if ~isempty(indRemoved2)
            legend('', [num2str(length(indRemoved2)) ' points removed'],'Interpreter','none')
        end

        linkaxes(ax,'x')

        sgtitle([num2str(yearIn) ' ' mainTraceName],'Interpreter','none');

        % move to next variable?
        disp("ready for next variable?")
        user_response = input('Continue? (Y/N): ', 's');

        % Check response
        if strcmpi(user_response, 'N') || strcmpi(user_response, 'NO')
            disp('Stopped and exiting.');
            disp('--------------------');
            break; % Exit
        elseif strcmpi(user_response, 'Y') || strcmpi(user_response, 'YES')
            disp('Continuing...');
            disp('-------------');
            % Continue to the next variable
        else
            disp('Invalid input. Continuing anyway.');
            disp('--------------------');
        end

        % pause(1);
    end

end

