% Sample code showing the data coverage:
% SmartFlux summaries vs EddyPro recalcs vs GHG files

siteID = 'UQAM_2';
yearIn = 2025;
structProject=get_TAB_project;
pathIn = biomet_path(yearIn,siteID,'Flux');
tv = read_bor(fullfile(pathIn,'clean_tv'),8,[],yearIn);
tv_dt = datetime(tv,'ConvertFrom','datenum');
x = read_bor(fullfile(pathIn,'air_p_mean'),[],[],yearIn);
try
    x1 = read_bor(fullfile(pathIn,'air_p_mean_1'),[],[],yearIn);
catch
    x1 = nan(size(x));
    fprintf(2,'No EP calcs.\n')
end
x2 = read_bor(fullfile(pathIn,'GHG','Data.Vin_SmartFlux.avg'),[],[],yearIn);

% Find how much raw data there is:
pathHF = fullfile(structProject.hfPath,siteID,'HighFrequencyData','raw',num2str(yearIn));
s=dir(pathHF);
allMonths = sort({s.name});
pathHF_lastMonth = fullfile(pathHF,allMonths(end));
s2=dir(char(fullfile(pathHF_lastMonth,[num2str(yearIn) '-*.ghg'])));
allGHGnames = sort({s2.name});
lastFile = char(allGHGnames(end));
lastDate = datetime(lastFile(1:15),'InputFormat','uuuu-MM-dd''T''HHmm');
lastDate = dateshift(lastDate,'start','day') + minutes(30) * round(timeofday(lastDate)/minutes(30));
fprintf('Site: %s,  Last date available: %s\n',siteID,lastDate);


%%
figure(1)
%plot(tv_dt,[x x1 x2*1000],'o', [lastDate lastDate],[min(x) max(x)],'-')
%plot(tv_dt,isnan(x),'o',tv_dt,isnan(x1)+0.1,'x',tv_dt,isnan(x2)+0.2,'d', [lastDate lastDate],[-0.5 0.5],'-');
plot(tv_dt,isnan(x)+0.2,'.',tv_dt,isnan(x1)+0.1,'.',tv_dt,isnan(x2),'.', [lastDate lastDate],[-0.5 0.5],'-');
title(siteID)
ylim([-0.5 0.5])
legend('SF','EP','GHG - averages','GHG - last file')
zoom on