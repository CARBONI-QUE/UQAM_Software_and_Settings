% TO install python 3.11 in Matlab 2024a
% In Anaconda prompt:
%    > conda create -n env_311 python=3.11
%    > conda activate env_311
%    > where python
% Then pick the version that says :env_311
% and run something like this in Matlab (may need to edit the path):
% pyenv("Version","C:\Users\flux-central\.conda\envs\env_311\python.exe")
% ** restart Matlab otherwise wierd errors like py.dict not recognized may
% happen. ***
% In Anaconda prompt run this to install the library
%   > conda install -c conda-forge cdsapi

%allSites = get_TAB_site_names;
allSites = {'MCGILL_1','UQAM_1','UQAM_2','UQAM_3','UQAM_4','UQAM_5'};
yearStart = 2024;
yearEnd = 2026;
% stDate  = '2019-01-01';
% endDate = '2019-01-31';

for cnt = 1:length(allSites)
    stDate  = sprintf('%d-01-01',yearStart);
    endDate = sprintf('%d-12-31',yearEnd);
    try
        siteID = char(allSites(cnt));
        fprintf('=========================================\n');
        fprintf('%s: Downloading ERA5 data for the period %s - %s\n',siteID,stDate,endDate);
        db_ERA5_data_retrieval(siteID, stDate, endDate, [],'ts')
        db_ERA5_compile(siteID,1)
        fprintf('\n============= END ===================\n\n');
    catch ME
        disp(ME);
        fprintf('\n\nContinuing...\n\n');
    end
end