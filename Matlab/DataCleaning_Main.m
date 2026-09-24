% DataCleaning_Main.m
% Rosie Howard
% 28 November 2024

% run cleaning
clear;
projectPath = '/Users/rosie/Documents/Micromet/Projects/Carbonique/UQAM_Software_and_Settings/';
structProject = set_TAB_project(projectPath);

siteID = 'MCGILL_1';  % Lac Saint-Pierre restored marsh (2025-present)
% siteID = 'UQAM_0';    % test site?
% siteID = 'UQAM_1';      % Lac Saint-Pierre disturbed marsh (2024-present)
% siteID = 'UQAM_2';    % Lac-à-la-Tortue natural open bog (2025-present)
% siteID = 'UQAM_3';    % Lac-à-la-Tortue natural treed bog (2025-present)
% siteID = 'UQAM_4';    % Saint-Rémi disturbed forested peatland (2026-present; no flux data in 2025 and very little met data)
% siteID = 'UQAM_5';    % Baie Saint François natural marsh (2026-present) - no data/INIs yet as of 4 September 2026                      

%% clean data

clc;
yearsIn = 2025;
fr_automated_cleaning(yearsIn,siteID,[1 2]);


% 1 = first stage
% 2 = second stage
% 7 = third stage
% 8 = Ameriflux output stage
% 9 = Python ML gap-filling stage   
% 10 = Ameriflux QAQC stage

%% load ERA5 data

start_date = '2026-01-01';
end_date = '2027-01-01';

db_ERA5_data_retrieval(siteID,start_date,end_date);
db_ERA5_compile(siteID);

%% get Canadian ECCC station data
 structProject = set_TAB_project(projectPath); 
 stationIDs = 27646;
 yearsIn = 2024:2026; 
 monthsIn  = 1:12; 
 for cntStations = 1:length(stationIDs) 
     sID = stationIDs(cntStations); 
     pathECCC = fullfile('yyyy','ECCC',num2str(sID)); 
     try 
         run_ECCC_climate_station_update(yearsIn,monthsIn,sID,structProject.databasePath)     
     catch 
         fprintf('Error processing station: %d (year: %d, month: %d)\n',sID,yearsIn,monthsIn(end)); 
     end 
 end

%% compare databases

yearIn = 2025;

oldPath = [projectPath 'Database_1Apr2026_BB2_FirstStageOld'];
newPath = [projectPath 'Database'];
fr_compare_database_traces(siteID,yearIn,oldPath,newPath,'Clean/SecondStage')

%% test: are gas concentrations (and fluxes) worse for more recent database (post EP rerun) for UQAM_2 2025?

% YES - same for CO2 concentrations. 

clc;
yearIn = 2025;

tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

filePath_new = fullfile(biomet_path(yearIn,siteID,'Flux'));
filePath_old = fullfile('/Users/rosie/Desktop/CarboniqueTemporary/');

co2_new = read_bor(fullfile(filePath_new,'co2_mole_fraction'));
AmerifluxCSV = fullfile(filePath_old,'CA-CQ2_HH_202501010000_202601010000.csv');
AmerifluxCSV_old = readtable(AmerifluxCSV);
co2_old = AmerifluxCSV_old.CO2;

clf;
plot(tv_dt,co2_old,'o')
hold on
plot(tv_dt,co2_new,'x')




%% check WTD for UQAM sites (2 September 2026)

yearsIn = 2026;

count = 1;
for yearIn = yearsIn

    tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
    tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

    % load data
    filePath = fullfile(biomet_path(yearIn,siteID,'Met'));
    % WTD = read_bor(fullfile(filePath,'L_WATER_Avg'));   % OLD input variable
    WTD_raw = read_bor(fullfile(filePath,'Lvl_m_Avg'));
    if yearIn ~=2025
        WTD = read_bor(fullfile(filePath,'Clean/WTD_1_1_1'));
    end

    % plot
    figure(100)
    % subplot(2,1,count);
    plot(tv_dt,WTD_raw,'x','MarkerSize',10)
    hold on
    if yearIn ~=2025
        plot(tv_dt,WTD,'o','MarkerSize',10)
    end
    grid on
    legend('raw','first stage')
    title(num2str(yearIn))

    count = count + 1;
end

sgtitle([siteID ' WTD (raw and first stage)']);


%% compare Ameriflux output: local (submitted to Ameriflux) vs. vinimet

% First download Ameriflux CSVs from vinimet, rename with '_vinimet' at the
% end of the file name, and put in same folder as local CSV Ameriflux file
% for each site. Currently compares one year at a time (defined by yearIn).

if strcmpi(siteID,'BB')
    AmerifluxID = 'CA-DBB'; %#ok<*UNRCH>
elseif strcmpi(siteID,'BB2') 
    AmerifluxID = 'CA-DB2';
elseif strcmpi(siteID,'DSM')
    AmerifluxID = 'CA-DSM';
elseif strcmpi(siteID,'RBM')
    AmerifluxID = 'CA-RBM';
end

% load data
yearIn = 2025;
filePath = fullfile(biomet_path(yearIn,siteID,'Clean/Ameriflux'));
filename_local = [AmerifluxID '_HH_202501010000_202601010000.csv'];
filename_vinimet = [AmerifluxID '_HH_202501010000_202601010000_vinimet.csv'];

CSV_local = readtable(fullfile(filePath,filename_local));
CSV_vinimet = readtable(fullfile(filePath,filename_vinimet));

% remove PI columns (not submitted to Ameriflux)
[a,b] = size(CSV_local);
CSV_vinimet(:, b+1:end) = [];

% find max and min differences in entire table as a first check (if find 
% large differences will need to do further check to locate and identify variables
diffArray = table2array(CSV_local) - table2array(CSV_vinimet);
maxDiff = max(max(diffArray));
minDiff = min(min(diffArray));

% write output to screen
fprintf('*** For siteID = %s, maximum difference between local and vinimet CSV is maxDiff = %f, for yearIn = %d\n',siteID,maxDiff,yearIn)
fprintf('*** For siteID = %s, minimum difference between local and vinimet CSV is minDiff = %f, for yearIn = %d\n',siteID,minDiff,yearIn)

% can convert back to table
T_diff = array2table(diffArray, 'VariableNames', CSV_local.Properties.VariableNames);



%% retrieve raw soil data from BB and BB2: format into CSV files (for Susanna Karlqvist, see emails early May 2026)

yearsIn = 2025;
tv = read_bor(fullfile(biomet_path(yearsIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearsIn,siteID,'Met'));
SWC_raw = read_bor(fullfile(filePath,'MET_616_VolW_Avg'));

% plot to check
figure(1)
set(gcf,'color','white');
clf
% ax(1) = subplot(4,2,1:2);
plot(tv_dt,SWC_raw,'-o')
title([num2str(yearsIn) ' SWC (raw)'])

% write to CSV
T = table(tv_dt, SWC_raw,'VariableNames',{'Datetime','SWC_raw'});
outFileName = [num2str(yearsIn) '_' siteID '_SWC_raw.csv'];
outPath = fullfile(structProject.matlabPath,outFileName);
writetable(T,outPath)

%% compare TA after switching heights to check

tv = read_bor(fullfile(biomet_path(yearsIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearsIn,siteID,'Flux'));
filePath_firstStage = fullfile(biomet_path(yearsIn,siteID,'Met/Clean'));
filePath_secondStage = fullfile(biomet_path(yearsIn,siteID,'Clean/SecondStage'));

% fluxes
co2_flux = read_bor(fullfile(filePath,'co2_flux'));
ch4_flux = read_bor(fullfile(filePath,'ch4_flux'));

% air temperature - first stage
TA_1_1_1 = read_bor(fullfile(filePath_firstStage,'TA_1_1_1'));
TA_1_2_1 = read_bor(fullfile(filePath_firstStage,'TA_1_2_1'));
TA_ECCC = read_bor(fullfile(filePath_firstStage,'TA_ECCC')); % ECCC for gap-filling

% comparison plot
figure(1)
set(gcf,'color','white');
clf
ax(1) = subplot(4,2,1:2);
plot(tv_dt,TA_1_2_1,'-o')
hold on
plot(tv_dt,TA_1_1_1,'-o')
grid
legend('TA\_1\_2\_1 (2 m)','TA\_1\_1\_1 (3.5 m)');
ylabel('Air temp (degC)')

ax(2) = subplot(4,2,3:4);
plot(tv_dt,TA_1_2_1-TA_1_1_1)
grid
hold on
plot(tv_dt,zeros(length(tv_dt),1),'k--')
ylabel('TA\_1\_2\_1 - TA\_1\_1\_1 (degC)')

linkaxes(ax,'x')

% histograms
ax(3) = subplot(4,2,5);
histogram(TA_1_1_1,'BinWidth',0.5)
grid
hold on
xlim([-15 35])
ylim([0 800])
set(gca,'YScale','log');
title('TA\_1\_1\_1 (3.5 m)')

ax(4) = subplot(4,2,6);
histogram(TA_1_2_1,'BinWidth',0.5)
grid
hold on
xlim([-15 35])
ylim([0 800])
set(gca,'YScale','log');
title('TA\_1\_2\_1 (2 m)');

% scatterplots
ax(5) = subplot(4,2,7);
scatter(ax(5),TA_1_1_1,TA_ECCC,'x')
grid
xlim([-20 40])
ylim([-20 40])
h1 = lsline(ax(5));
h1.LineStyle = '--';
h1.Color = 'k';

A = [ones(size(h1.XData(:))), h1.XData(:)]\h1.YData(:);
Slope = A(2);
Intercept = A(1);
% p2a = polyfit(get(h1,'xdata'),get(h1,'ydata'),1);
text(-12, 35, [num2str(Slope) 'x + ' num2str(Intercept)]);
title('TA\_1\_1\_1 vs. TA\_ECCC')

ax(6) = subplot(4,2,8);
scatter(ax(6),TA_1_2_1,TA_ECCC,'x')
grid
xlim([-20 40])
ylim([-20 40])
h2 = lsline(ax(6));
h2.LineStyle = '--';
h2.Color = 'k';

B = [ones(size(h2.XData(:))), h2.XData(:)]\h2.YData(:);
Slope = B(2);
Intercept = B(1);

% p2b = polyfit(get(h2,'xdata'),get(h2,'ydata'),1);
text(-12, 35, [num2str(Slope) 'x + ' num2str(Intercept)]);
title('TA\_1\_2\_1 vs. TA\_ECCC')

sgtitle('Measurement height comparison')

% simple time series
figure(2)
set(gcf,'color','white');
clf
subplot(3,1,1)
plot(tv_dt,TA_1_1_1)
title('TA\_1\_1\_1 (3.5 m)')
grid
ylim([-20 40])
ylabel('(degC)')

subplot(3,1,2)
plot(tv_dt,TA_1_2_1)
title('TA\_1\_2\_1 (2 m)')
grid
ylim([-20 40])
ylabel('(degC)')

subplot(3,1,3)
plot(tv_dt,TA_ECCC)
title('TA\_ECCC')
grid
ylim([-20 40])
ylabel('(degC)')

%% compare RH after switching heights to check

tv = read_bor(fullfile(biomet_path(yearsIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearsIn,siteID,'Met'));
filePath_firstStage = fullfile(biomet_path(yearsIn,siteID,'Met/Clean'));
filePath_secondStage = fullfile(biomet_path(yearsIn,siteID,'Clean/SecondStage'));

% relative humidity
RH_1_1_1 = read_bor(fullfile(filePath_firstStage,'RH_1_1_1'));
RH_1_2_1 = read_bor(fullfile(filePath_firstStage,'RH_1_2_1'));
RH_ECCC = read_bor(fullfile(filePath_firstStage,'RH_ECCC')); % ECCC for gap-filling

% comparison plot
figure(1)
set(gcf,'color','white');
clf
ax(1) = subplot(4,2,1:2);
plot(tv_dt,RH_1_1_1)
hold on
plot(tv_dt,RH_1_2_1)
grid
legend('RH\_1\_1\_1 (2 m)','RH\_1\_2\_1 (3.5 m)','location','southeast');
ylabel('RH (%)')

ax(2) = subplot(4,2,3:4);
plot(tv_dt,RH_1_1_1-RH_1_2_1)
grid
hold on
plot(tv_dt,zeros(length(tv_dt),1),'k--')
ylabel('RH\_1\_1\_1 - RH\_1\_2\_1 (%)')

linkaxes(ax,'x')

% histograms
ax(3) = subplot(4,2,5);
histogram(RH_1_1_1,'BinWidth',1)
grid
hold on
xlim([0 100])
ylim([0 5000])
set(gca,'YScale','log');
title('RH\_1\_1\_1 (3.5 m)')

ax(4) = subplot(4,2,6);
histogram(RH_1_2_1,'BinWidth',1)
grid
hold on
xlim([0 100])
ylim([0 5000])
set(gca,'YScale','log');
title('RH\_1\_2\_1 (2 m)');

% scatterplots
ax(5) = subplot(4,2,7);
scatter(ax(5),RH_1_1_1,RH_ECCC,'x')
grid
xlim([0 100])
ylim([0 100])
h1 = lsline(ax(5));
h1.LineStyle = '--';
h1.Color = 'k';

A = [ones(size(h1.XData(:))), h1.XData(:)]\h1.YData(:);
Slope = A(2);
Intercept = A(1);
% p2a = polyfit(get(h1,'xdata'),get(h1,'ydata'),1);
text(5, 95, [num2str(Slope) 'x + ' num2str(Intercept)]);
title('RH\_1\_1\_1 vs. RH\_ECCC')

ax(5) = subplot(4,2,8);
scatter(ax(5),RH_1_2_1,RH_ECCC,'x')
grid
xlim([0 100])
ylim([0 100])
h2 = lsline(ax(5));
h2.LineStyle = '--';
h2.Color = 'k';

B = [ones(size(h2.XData(:))), h2.XData(:)]\h2.YData(:);
Slope = B(2);
Intercept = B(1);

% p2b = polyfit(get(h2,'xdata'),get(h2,'ydata'),1);
text(5, 95, [num2str(Slope) 'x + ' num2str(Intercept)]);
title('RH\_1\_2\_1 vs. RH\_ECCC')

sgtitle('Measurement height comparison')

% simple time series
figure(2)
set(gcf,'color','white');
clf
subplot(3,1,1)
plot(tv_dt,RH_1_1_1)
title('RH\_1\_1\_1 (3.5 m)')
grid
subplot(3,1,2)
plot(tv_dt,RH_1_2_1)
title('RH\_1\_2\_1 (2 m)')
grid
subplot(3,1,3)
plot(tv_dt,RH_ECCC)
title('RH\_ECCC')
grid


%% analyze potential erroneous RH sensor

tv = read_bor(fullfile(biomet_path(yearsIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearsIn,siteID,'Met'));
filePath_firstStage = fullfile(biomet_path(yearsIn,siteID,'Met/Clean'));

% relative humidity
RH_raw_350cm = read_bor(fullfile(filePath,'MET_HMP_RH_350cm_Avg'));
RH_raw_2m = read_bor(fullfile(filePath,'MET_HMP_RH_2m_Avg'));
RH_ECCC = read_bor(fullfile(filePath_firstStage,'RH_ECCC')); % ECCC for gap-filling

if yearsIn == 2025
    RH_raw_350cm_std = read_bor(fullfile(filePath,'MET_HMP_RH_350cm_Std'));
    RH_raw_2m_std = read_bor(fullfile(filePath,'MET_HMP_RH_2m_Std'));
end


% simple time series
figure(1)
set(gcf,'color','white');
clf

subplot(4,2,1:2)
plot(tv_dt,RH_raw_350cm)
hold on
plot(tv_dt,RH_raw_2m)
ylim([0 100])
grid
title('RH\_raw DSM')
legend('RH\_raw (3.5 m)','RH\_raw (2m)','location','southeast')

ax(2) = subplot(4,2,3:4);
plot(tv_dt,RH_raw_350cm-RH_raw_2m)
grid
hold on
plot(tv_dt,zeros(length(tv_dt),1),'k--')
ylabel('RH\_raw\_350cm - RH\_raw\_2m (%)')

% histograms
ax(3) = subplot(4,2,5);
histogram(RH_raw_350cm,'BinWidth',1)
grid
hold on
xlim([0 100])
ylim([0 5000])
set(gca,'YScale','log');
title('RH\_raw (3.5 m)')

ax(4) = subplot(4,2,6);
histogram(RH_raw_2m,'BinWidth',1)
grid
hold on
xlim([0 100])
ylim([0 5000])
set(gca,'YScale','log');
title('RH\_raw (2 m)');

subplot(4,2,7:8)
plot(tv_dt,RH_ECCC)
title('RH\_ECCC (for reference only)')
grid

sgtitle(num2str(yearsIn))


%% comparison of calc_avg_trace and gapFillUsingAltSensor for TA

tv = read_bor(fullfile(biomet_path(yearsIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
% filePath = fullfile(biomet_path(yearsIn,siteID,'Met'));
filePath = fullfile(biomet_path(yearsIn,siteID,'Met/Clean'));
% filePath = fullfile(biomet_path(yearsIn,siteID,'Clean/SecondStage'));

% air temperature
TA_1_1_1 = read_bor(fullfile(filePath,'TA_1_1_1'));  % 3.5-m height 
% TA_1_2_1 = read_bor(fullfile(filePath_firstStage,'TA_1_2_1'));  % 2-m height
TA_ECCC = read_bor(fullfile(filePath,'TA_ECCC')); % ECCC for gap-filling

% gap-filled TA

% calc_avg_trace
TA_1_1_1_F = calc_avg_trace(tv,TA_1_1_1,TA_ECCC,-1); % upper TA measurement gap-filled using calc_avg_trace (cat)
% T_1_2_1_F = calc_avg_trace(tv,TA_1_2_1,TA_ECCC,-1); % upper TA measurement gap-filled using calc_avg_trace (cat)

% new gap-filling function
TA_1_1_1_F_new = gapFillUsingAltSensor(TA_1_1_1,TA_ECCC); % upper TA measurement gap-filled using new function
% TA_1_2_1_F_new = gapFillUsingAltSensor(tv,TA_1_2_1,TA_ECCC); % upper TA measurement gap-filled using new function

% compare output
figure(1)
set(gcf,'color','white');
clf

ax(1) = subplot(2,1,1);
plot(tv_dt,TA_1_1_1_F,'o')
hold on
plot(tv_dt,TA_1_1_1_F_new,'x')
grid

ax(2) = subplot(2,1,2);
diff_TA = TA_1_1_1_F - TA_1_1_1_F_new;
plot(tv_dt, diff_TA,'o')
grid

linkaxes(ax,'x')

%% sample code from Zoran for testing gapFillUsingAltSensor function
% test replecement function for calc_avg_trace

slopeTrue = 0.98;
offsetTrue = .1;
stdNoise = 0.05;
indGaps = [100 1000 10000 15000]';
nSpikes = 200;
spikeMult = 5;
stdMultiplier = 3;

spikeValues = spikeMult*randn(nSpikes,1);
indSpikes = abs(round(5000*randn(nSpikes,1)));
indSpikes(indSpikes>17520) = 17520;
indSpikes(indSpikes==0) = 1;
N = 17520;
tv = fr_round_time(datenum(2025,1,1) + (1/48:1/48:365)');
tv_dt = datetime(tv,'ConvertFrom','datenum');

x_true = sin(tv*2*pi/48);
x_measured = x_true * slopeTrue + offsetTrue + stdNoise*randn(size(tv));
x_measured(indSpikes)= spikeValues; 

x_measured_with_gaps = x_measured;
x_measured_with_gaps(indGaps) = NaN;

x_corrected_cacl_avg = calc_avg_trace(tv,x_measured_with_gaps,x_true,-1);

%---------------------------------------------------------------
% New function for gap filling using an alternative sensor
qaqcIn.enable = true;
qaqcIn.gapfillOverwrite = true;   % if the fit is not good enough: 
                                    %    false (default) - do not gap fill
                                    %    true - do gap fill
qaqcIn.r2min = 0.95;               % default min acceptable r2
qaqcIn.minSlope = 0.95;            % default min acceptable slope fit
qaqcIn.maxSlope = 1.05;            % default max acceptable slope fit
qaqcIn.maxRMSE = .15;              % default: no limit for max RMSE
[x_corrected_new,qaqc] = gapFillUsingAltSensor(x_measured_with_gaps,x_true,stdMultiplier,qaqcIn,true);
x_corrected_new(isnan(x_corrected_new)) = -9999;
% if ~qaqc.flag
%     fprintf(2,qaqc.msg);
% else
%     fprintf('Good fit!\n');
% end
%---------------------------------------------------------------
figure(1)
ax(1)=subplot(3,1,1);
plot(tv_dt,x_measured,'o',tv_dt,x_measured_with_gaps,'d',tv_dt,x_true,'k','LineWidth',3)
legend('Measured - no gaps','Measured + gaps','True')
grid on
zoom on
ax(2) = subplot(3,1,2);
plot(tv_dt(indGaps),x_measured(indGaps),'o')
legend('Points replaced with NaNs')
grid on
zoom on

ax(3) = subplot(3,1,3);
plot(tv_dt,x_corrected_cacl_avg - x_measured,'o',tv_dt,x_corrected_cacl_avg - x_corrected_new,'o')
legend('Error: x_gap_filled_calc_avg - x_measured','Error: x_gap_filled_new - x_gap_filled_calc_avg','interpreter','none')
grid on


linkaxes(ax,'x')


figure(2)
[x_filtered,y_filtered, p1, p2, slopeCoeff,thresholdFilter] = ...
    ta_clean_1to1_trace(x_true,x_measured_with_gaps,stdMultiplier);

plot(x_true,x_measured,'ko',x_true,y_filtered,'ro')
xlabel('x-true')
ylabel('Measured')
legend('Original points','Points used for polyfit')
title({sprintf('Target:          y = %6.4f * x + %6.2f ',[slopeTrue offsetTrue]),...
       sprintf('Original fit  :  y = %6.4f * x + %6.2f ',p1),...
       sprintf('Filtered fit  :  y = %6.4f * x + %6.2f ',p2)})
grid
zoom on

% figure(3)
% plot(x_filtered,y_filtered,'ro')
% xlabel('x-true-filtered')
% ylabel('y-filtered')
% grid
% zoom on



%% comparison of calc_avg_trace and gapFillUsingAltSensor for RH

% gap-filled RH
% calc_avg_trace
RH_upper_F = calc_avg_trace(tv,RH_1_1_1,RH_ECCC,-1); % upper RH measurement gap-filled using calc_avg_trace (cat)
RH_upper_F(RH_upper_F < 0) = NaN; RH_upper_F(RH_upper_F > 100) = 100;
RH_lower_F = calc_avg_trace(tv,RH_1_2_1,RH_ECCC,-1); % upper RH measurement gap-filled using calc_avg_trace (cat)
RH_lower_F(RH_lower_F < 0) = NaN; RH_lower_F(RH_lower_F > 100) = 100;

% new gap-filling function
% RH_1_1_1_F_upper_new = gapFillUsingAltSensor(tv,RH_1_1_1,RH_ECCC); % upper RH measurement gap-filled using new function
% RH_1_2_1_F_lower_new = gapFillUsingAltSensor(tv,RH_1_2_1,RH_ECCC); % upper RH measurement gap-filled using new function


%% visualize WTD data for BBS

yearIn = 2023;

tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Met/Manual'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearIn,siteID,'Met'));

% WTD
PSW_S_WTD_cm = read_bor(fullfile(filePath,'Manual/PSW_S_WTD_cm'));

% plot data
plot(PSW_S_WTD_cm,'o')
% plot(tv_dt,PSW_S_WTD_cm,'o')


% Pipe height
PSW_S_Pipe_Height_cm = read_bor(fullfile(filePath,'PSW_S_Pipe_Height_cm'));

% plot data
plot(tv_dt,PSW_S_Pipe_Height_cm,'o')

%% fix WTD data for BBS
% Ran 3 Dec 2025 by Rosie. Do not run again! (shouldn't change anything but
% just in case!)

yearIn = 2023;

tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Met/Manual'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearIn,siteID,'Met/Manual'));
s = dir(filePath);

for k = 1:length(s)
    var = s(k).name;
    if ~strcmp(var,'.') & ~strcmp(var,'..') & ~strcmp(var,'clean_tv')
        tmp=read_bor(fullfile(filePath,var));
        if s(k).bytes > 70080       % size of file with 17520 data points
            save_bor(fullfile(filePath,var),[],tmp(2:end));
            test = read_bor(fullfile(filePath,var));
            disp(['new length ' var ':' num2str(length(test))]);
        else
            continue
        end
    else
        continue
    end
end
    

%% visualize ECCC data

yearIn = 2023;
stationID_ECCC = '925';

tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_database_default,num2str(yearIn),'ECCC', stationID_ECCC, '30min');

% TA_ECCC
TA_ECCC = read_bor(fullfile(filePath,'Tair'));

% plot data
plot(tv_dt,TA_ECCC,'o')

%% test vapPressDeficit (VPD) function (moved all second stage "working" into one function)

yearIn = 2024;

tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearIn,siteID,'Clean/SecondStage'));

% VPD old
VPD_1_1_1 = read_bor(fullfile(filePath,'VPD_1_1_1'));

% plot
plot(tv_dt,VPD_1_1_1,'o')

%% test calcNetRad (NETRAD) function (moved all second stage "working" into one function)

yearIn = 2024;

tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearIn,siteID,'Clean/SecondStage'));

% NetRad 
NETRAD_1_1_1 = read_bor(fullfile(filePath,'NETRAD_1_1_1'));     % old                                                        
% NETRAD_new = read_bor(fullfile(filePath,'NETRAD_new'));         % new

% plot
plot(tv_dt,NETRAD_1_1_1,'o')
hold on
plot(tv_dt,NETRAD_new,'x')

%% test calcAlb (ALB) function (moved all second stage "working" into one function)

yearIn = 2024;

tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearIn,siteID,'Clean/SecondStage'));

% albedo 
ALB_1_1_1 = read_bor(fullfile(filePath,'ALB_1_1_1'));     % old                                                        
ALB_new = read_bor(fullfile(filePath,'ALB_new'));         % new

% plot
plot(tv_dt,ALB_1_1_1,'o')
hold on
plot(tv_dt,ALB_new,'x')

%% zthresh test

tv = read_bor(fullfile(biomet_path(yearsIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
folder = 'ThirdStage_2024DSM_zthresh7';
filePath = fullfile('/Users/rosie/Documents/Micromet/CANFLUX_Database/data_tests/thirdStageFilteringTesting/12Jan2026_zthresh',folder);

NEE = read_bor(fullfile(filePath,'NEE_PI_SC_JSZ_MAD_RP_uStar_orig'));
FCH4 = read_bor(fullfile(filePath,'FCH4_PI_SC_JSZ_MAD_RP_uStar_orig'));

missing_NEE = length(find(isnan(NEE)));
missing_FCH4 = length(find(isnan(FCH4)));

%% test first stage spike removal
% did this one year at a time because I'm not sure whether the
% non-parametric function uses all the data you give it to create
% statistics or just a small window (ask Paul...)

yearIn = 2020;
siteID = 'BB'; 
dataType = 'Met';

% if strcmp(dataType,'Flux')
%     pthOut = pthOutEC; %#ok<*UNRCH>
% elseif strcmp(dataType,'Met') 
%     pthOut = pthOutMet;
% end

list_files = dir(fullfile(biomet_database_default,num2str(yearIn),siteID,dataType));


for i = 1:length(list_files)
    baseFileName = list_files(i).name;
    if strcmp(baseFileName,'.') ...
            | strcmp(baseFileName,'..') ...
            | strcmp(baseFileName,'.DS_Store') ...
            | strcmp(baseFileName,'clean_tv') ...
            | strcmp(baseFileName,'TimeVector') ...
            | strcmp(baseFileName,'Clean')
        continue
    else
        value = baseFileName;
    end
    % load data
    var = read_bor(fullfile(pthOut,value),[],[],yearIn);
    mainTraceName = 'MET_HMP_T_2m_Avg';

    pthDatabase = fullfile('/Users/rosie/Documents/Micromet/Sara_MicrometSites/Database/yyyy',siteID);
    clean_tv = read_bor(fullfile(pthDatabase,'Met/Clean','clean_tv'),8,[],yearIn);
    tv_dt = datetime(clean_tv,'ConvertFrom','datenum');
    mainTrace = read_bor(fullfile(pthDatabase,'Met',mainTraceName),[],[],yearIn);

    wlen=24;
    thres=4;
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
    subplot(2,1,1)
    plot(tv_dt,mainTrace,tv_dt(indRemoved1),mainTrace(indRemoved1),'o')
    title('run_std_dev','Interpreter','none')
    if ~isempty(indRemoved1)
        legend('', [num2str(length(indRemoved2)) ' points removed'],'Interpreter','none')
    end

    subplot(2,1,2)
    plot(tv_dt,mainTrace,tv_dt(indRemoved2),mainTrace(indRemoved2),'o')
    title('remove_spikes_diurnal_nonParametric','Interpreter','none')
    if ~isempty(indRemoved2)
        legend('', [num2str(length(indRemoved2)) ' points removed'],'Interpreter','none')
    end

    sgtitle([num2str(yearIn) ' ' mainTraceName],'Interpreter','none');

end

%% test "data denial" with gapFillUsingAltSensor for SW_IN

yearIn = 2023;

tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
% filePath = fullfile(biomet_path(yearsIn,siteID,'Met'));
filePath = fullfile(biomet_path(yearIn,siteID,'Met/Clean'));
% filePath = fullfile(biomet_path(yearsIn,siteID,'Clean/SecondStage'));

% incoming solar radiation
SW_IN_1_1_1 = read_bor(fullfile(filePath,'SW_IN_1_1_1'));  % 3.5-m height 

SW_IN_partial = SW_IN_1_1_1;
SW_IN_partial(5000:end) = NaN;

% change amplitude of daytime signal slightly, and add noise, 
% to simulate another sensor at different location
SW_IN_partial(SW_IN_partial > 5) = SW_IN_partial(SW_IN_partial > 5)*1.05;
SW_IN_partial = SW_IN_partial + randn(length(SW_IN_partial),1);
SW_IN_partial(SW_IN_partial < 0) = 0;   % truncate like in first stage

% regress
ind = isnan(SW_IN_partial) | isnan(SW_IN_1_1_1);
SW_IN_partial_new = SW_IN_partial;
SW_IN_1_1_1_new = SW_IN_1_1_1;
SW_IN_partial_new(ind) = [];
SW_IN_1_1_1_new(ind) = [];
coefs = polyfit(SW_IN_1_1_1_new,SW_IN_partial_new,1);
mdl = fitlm(SW_IN_1_1_1_new,SW_IN_partial_new);
r2 = mdl.Rsquared.Ordinary;

% gapfill
% SW_IN_F = calc_avg_trace(tv,SW_IN_partial,SW_IN_1_1_1,1);
qaqc=[];
qaqcIn.minSlope = 0;
qaqcIn.maxSlope = 2;
% qaqcIn.r2min = 0;
SW_IN_F = gapFillUsingAltSensor(SW_IN_partial,SW_IN_1_1_1,[],qaqcIn,[],[]);


% plot
clf
subplot(3,1,1)
plot(tv_dt,SW_IN_1_1_1,'o')
hold on
plot(tv_dt,SW_IN_partial,'o')
grid on
legend('alt','orig')

subplot(3,1,2)
plot(SW_IN_1_1_1_new,SW_IN_partial_new,'x')
hold on
plot(SW_IN_1_1_1_new,coefs(2) + coefs(1)*SW_IN_partial_new,'r')
grid on

subplot(3,1,3)
plot(tv_dt,SW_IN_F,'o')
hold on
plot(tv_dt,SW_IN_partial,'o')
plot(tv_dt,SW_IN_1_1_1,'x')
grid on
legend('filled','orig','alt')


%% compare Precipitation for gap-filling 

yearsIn = 2025;
tv = read_bor(fullfile(biomet_path(yearsIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearsIn,siteID,'Met'));
filePath_firstStage = fullfile(biomet_path(yearsIn,siteID,'Met/Clean'));
filePath_secondStage = fullfile(biomet_path(yearsIn,siteID,'Clean/SecondStage'));

% P_1_1_1 = read_bor(fullfile(filePath_firstStage,'P_1_1_1'));
% P_ECCC = read_bor(fullfile(filePath_firstStage,'P_ECCC')); % ECCC for gap-filling
% ind = isnan(P_1_1_1) | isnan(P_ECCC);
% P_1_1_1(ind) = [];
% P_ECCC(ind) = [];
% P_coefs = polyfit(P_ECCC,P_1_1_1,1);
% P_mdl = fitlm(P_ECCC,P_1_1_1);
% P_r2 = P_mdl.Rsquared.Ordinary;

P_RAIN_1_1_1 = read_bor(fullfile(filePath_firstStage,'P_RAIN_1_1_1'));
P_ECCC = read_bor(fullfile(filePath_firstStage,'P_ECCC')); % ECCC for gap-filling
ind = isnan(P_RAIN_1_1_1) | isnan(P_ECCC);
P_RAIN_1_1_1(ind) = [];
P_ECCC(ind) = [];
P_RAIN_coefs = polyfit(P_ECCC,P_RAIN_1_1_1,1);
P_RAIN_mdl = fitlm(P_ECCC,P_RAIN_1_1_1);
P_RAIN_r2 = P_RAIN_mdl.Rsquared.Ordinary;

WS_1_1_1 = read_bor(fullfile(filePath_firstStage,'WS_1_1_1'));
WS_ECCC = read_bor(fullfile(filePath_firstStage,'WS_ECCC')); % ECCC for gap-filling
ind = isnan(WS_1_1_1) | isnan(WS_ECCC);
WS_1_1_1(ind) = [];
WS_ECCC(ind) = [];
WS_coefs = polyfit(WS_ECCC,WS_1_1_1,1);
WS_mdl = fitlm(WS_ECCC,WS_1_1_1);
WS_r2 = WS_mdl.Rsquared.Ordinary;

WD_1_1_1 = read_bor(fullfile(filePath_firstStage,'WD_1_1_1'));
WD_ECCC = read_bor(fullfile(filePath_firstStage,'WD_ECCC')); % ECCC for gap-filling
ind = isnan(WD_1_1_1) | isnan(WD_ECCC);
WD_1_1_1(ind) = [];
WD_ECCC(ind) = [];
[WD_coefs,S] = polyfit(WD_ECCC,WD_1_1_1,1);

WD_mdl = fitlm(WD_ECCC,WD_1_1_1);
WD_r2 = WD_mdl.Rsquared.Ordinary;

qaqc=[];
qaqc.minSlope = 0.9;
[WD_1_1_1_F,qaqcOut] = gapFillUsingAltSensor(WD_1_1_1,WD_ECCC,[],qaqc,1,"WD_1_1_1_F");

%% read ERA5 data

yearsIn = 2022;
tv = read_bor(fullfile(biomet_path(yearsIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_database_default,num2str(yearsIn),'ERA5/DSM');

TA_ERA5 = read_bor(fullfile(filePath,'t2m'));
TD_ERA5 = read_bor(fullfile(filePath,'d2m'));


%% test PPFD/SW for BB and BB2

yearsIn = 2015:2025;  % BB
% yearsIn = 2019:2025;    % BB2
count = 1;
for yearin = yearsIn
    tv = read_bor(fullfile(biomet_path(yearin,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
    tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

    % load data
    filePath = fullfile(biomet_path(yearin,siteID,'Met/Clean'));

    PPFD_IN_1_1_1 = read_bor(fullfile(filePath,'PPFD_IN_1_1_1'));
    SW_IN_1_1_1 = read_bor(fullfile(filePath,'SW_IN_1_1_1'));
    PPFD_OUT_1_1_1 = read_bor(fullfile(filePath,'PPFD_OUT_1_1_1'));
    SW_OUT_1_1_1 = read_bor(fullfile(filePath,'SW_OUT_1_1_1'));

    figure(1)
    subplot(3,4,count)
    plot(PPFD_IN_1_1_1,SW_IN_1_1_1,'o')
    hold on;
    grid on;
    % plot(tv_dt,PPFD_IN_1_1_1,'o')
    sgtitle([siteID ' PPFD IN']);

    count = count + 1;
end

% Multiple years
% yearsIn = 2015:2025;                                    % loading multiple years in one go
pth = biomet_path('yyyy',siteID,'Met/Clean');                   % find data base path for multiple years, BB2 site
tv = read_bor(fullfile(pth,'clean_tv'),8,[],yearsIn);   % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');           % convert to Matlab's datetime object (use for all new stuff)
PPFD_IN_1_1_1 = read_bor(fullfile(pth,'PPFD_IN_1_1_1'),[],[],yearsIn); 
PPFD_OUT_1_1_1 = read_bor(fullfile(pth,'PPFD_OUT_1_1_1'),[],[],yearsIn); 
SW_IN_1_1_1 = read_bor(fullfile(pth,'SW_IN_1_1_1'),[],[],yearsIn); 
SW_OUT_1_1_1 = read_bor(fullfile(pth,'SW_OUT_1_1_1'),[],[],yearsIn); 

% plot
figure(2)
subplot(2,1,1)
plot(tv_dt,PPFD_IN_1_1_1,'o')                                           
grid on; zoom on; hold on;
plot(tv_dt,SW_IN_1_1_1,'o')
legend('PPFD_IN','SW_IN','Interpreter','none')
subplot(2,1,2)
plot(tv_dt,SW_OUT_1_1_1,'o')                                           
grid on; zoom on; hold on;
plot(tv_dt,PPFD_OUT_1_1_1,'o')
legend('SW_OUT','PPFD_OUT','Interpreter','none')
sgtitle(siteID)

%% find number of missing data points each year for vars

yearsIn = 2015:2025;    % BB

missingRH1_allyears = [];
missingRH2_allyears = [];
for yearIn = yearsIn
    tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
    tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

    % load data
    filePath = fullfile(biomet_path(yearIn,siteID,'Met/Clean'));
    % filePath_firstStage = fullfile(biomet_path(yearsIn,siteID,'Met/Clean'));
    % filePath_secondStage = fullfile(biomet_path(yearsIn,siteID,'Clean/SecondStage'));

    % relative humidity
    RH_1_1_1 = read_bor(fullfile(filePath,'RH_1_1_1'));
    missingRH1 = length(find(isnan(RH_1_1_1)));

    if yearIn < 2023
        RH_1_2_1 = read_bor(fullfile(filePath,'RH_1_2_1'));
        missingRH2 = length(find(isnan(RH_1_2_1)));
    else
        missingRH2 = NaN;
    end

    missingRH1_allyears = [missingRH1_allyears; missingRH1];
    missingRH2_allyears = [missingRH2_allyears; missingRH2];
end

missingRH1RH2 = cat(2,missingRH1_allyears, missingRH2_allyears);

%% test to see if it is worth gapfilling VPD with TA_F and RH (unfilled) or if they have the same points missing always

yearsIn = 2021:2025;    % DSM

for yearIn = yearsIn
    tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
    tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

    % load data
    filePath = fullfile(biomet_path(yearIn,siteID,'Met/Clean'));

    TA_1_1_1 = read_bor(fullfile(filePath,'TA_1_1_1'));
    RH_1_1_1 = read_bor(fullfile(filePath,'RH_1_1_1'));

    TA_1_2_1 = read_bor(fullfile(filePath,'TA_1_2_1'));
    RH_1_2_1 = read_bor(fullfile(filePath,'RH_1_2_1'));

    tempvar = zeros(size(TA_1_1_1));

    indMissingTA1 = find(isnan(TA_1_1_1));
    indMissingRH1 = find(isnan(RH_1_1_1));

    indMissingTA2 = find(isnan(TA_1_2_1));
    indMissingRH2 = find(isnan(RH_1_2_1));

    figure(100)
    clf
    ax(1) = subplot(4,1,1);
    plot(tv_dt,TA_1_1_1,tv_dt(indMissingTA1),tempvar(indMissingTA1),'o')
    grid on
    title('TA_1_1_1',Interpreter='none')
    ax(2) = subplot(4,1,2);
    plot(tv_dt,RH_1_1_1,tv_dt(indMissingRH1),tempvar(indMissingRH1),'o')
    grid on
    title('RH_1_1_1',Interpreter='none')
    ax(3) = subplot(4,1,3);
    plot(tv_dt,TA_1_2_1,tv_dt(indMissingTA2),tempvar(indMissingTA2),'o')
    grid on
    title('TA_1_2_1',Interpreter='none')
    ax(4) = subplot(4,1,4);
    plot(tv_dt,RH_1_2_1,tv_dt(indMissingRH2),tempvar(indMissingRH2),'o')
    grid on
    title('RH_1_2_1',Interpreter='none')

    linkaxes(ax,'x')
end

%% inspect ERA5 time series 

yearIn = 2024;    % DSM

tv = read_bor(fullfile(biomet_path(yearIn,siteID,'Flux'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearIn,'ERA5',siteID));
% TA_ERA5_raw = read_bor(fullfile(filePath,'t2m'));
% PA_ERA5_raw = read_bor(fullfile(filePath,'sp'));
SW_IN_ERA5_raw = read_bor(fullfile(filePath,'ssrd'));   % raw ERA5

filePath = fullfile(biomet_path(yearIn,siteID,'Met'));
SW_IN_DSM_raw = read_bor(fullfile(filePath,'MET_CNR4_SWi_Avg'));    % raw DSM
SW_IN_RBM_raw = read_bor(fullfile('/Users/rosie/Documents/Micromet/Sara_MicrometSites/Database/',num2str(yearIn),'RBM/Met/MET_CNR4_SWi_Avg'));

filePath = fullfile(biomet_path(yearIn,siteID,'Met/Clean'));
% TA_ERA5 = read_bor(fullfile(filePath,'TA_ERA5'));
% PA_ERA5 = read_bor(fullfile(filePath,'PA_ERA5'));
SW_IN_ERA5 = read_bor(fullfile(filePath,'SW_IN_ERA5'));    % first stage ERA5
SW_IN_1_1_1 = read_bor(fullfile(filePath, 'SW_IN_1_1_1'));  % first stage DSM
RBM_SW_IN_1_1_1 = read_bor(fullfile(filePath, 'RBM_SW_IN_1_1_1')); % first stage RBM

figure(150)
clf
subplot(2,1,1)
plot(tv_dt,SW_IN_ERA5_raw)
hold on
plot(tv_dt,SW_IN_DSM_raw)
legend('ERA5 raw','DSM raw')
grid on
subplot(2,1,2)
plot(SW_IN_ERA5_raw,SW_IN_DSM_raw,'x')
grid on
sgtitle('ERA5 raw vs. DSM raw')

figure(151)
clf
subplot(2,1,1)
plot(tv_dt,SW_IN_ERA5_raw)
hold on
plot(tv_dt,SW_IN_ERA5)
legend('ERA5 raw','ERA5 first stage')
grid on
subplot(2,1,2)
plot(SW_IN_ERA5_raw,SW_IN_ERA5,'x')
xlabel('raw')
ylabel('first stage')
grid on
sgtitle([num2str(yearIn) ' ERA5 raw vs. ERA5 first stage'])

figure(152)
clf
subplot(2,1,1)
plot(tv_dt,SW_IN_ERA5)
hold on
plot(tv_dt,SW_IN_1_1_1)
legend('ERA5 first stage','DSM first stage')
grid on
subplot(2,1,2)
plot(SW_IN_ERA5,SW_IN_1_1_1,'x')
grid on
sgtitle('ERA5 first stage vs. DSM first stage')

figure(153)
clf
subplot(2,1,1)
plot(tv_dt,SW_IN_DSM_raw)
hold on
plot(tv_dt,SW_IN_1_1_1)
legend('DSM raw','DSM first stage')
grid on
subplot(2,1,2)
plot(SW_IN_DSM_raw,SW_IN_1_1_1,'x')
grid on
sgtitle('DSM raw vs. DSM first stage')

figure(154)
clf
subplot(2,1,1)
plot(tv_dt,SW_IN_RBM_raw)
hold on
plot(tv_dt,RBM_SW_IN_1_1_1)
legend('RBM raw','RBM first stage')
grid on
subplot(2,1,2)
plot(SW_IN_RBM_raw,RBM_SW_IN_1_1_1,'x')
grid on
sgtitle('RBM raw vs. RBM first stage')


%% test time shift shiftMyData.m generalized function

yearsIn = 2021;
tv = read_bor(fullfile(biomet_path(yearsIn,siteID,'Met'),'clean_tv'),8);      % load the time vector (Matlab's datenum format)
tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object

% load data
filePath = fullfile(biomet_path(yearsIn,siteID,'Flux'));
WS_raw = read_bor(fullfile(filePath,'wind_speed'));
TA_raw = read_bor(fullfile(filePath,'TA_1_1_1'));
TA_raw = TA_raw - 273.15;   % convert to degC

% filePath = fullfile(biomet_path(yearsIn,siteID,'Met'));
% TA_raw = read_bor(fullfile(filePath,'MET_HMP_T_350cm_Avg'));
% WS_met_raw = read_bor(fullfile(filePath,'MET_Young_WS_WVc1'));
% filePath = fullfile(biomet_path(yearsIn,siteID,'Flux'));
% WS_flux_raw = read_bor(fullfile(filePath,'wind_speed'));

filePath = fullfile(biomet_path(yearsIn,siteID,'Flux/Clean'));
% filePath = fullfile(biomet_path(yearsIn,siteID,'Met/Clean'));
TA_1_1_1 = read_bor(fullfile(filePath,'TA_1_1_1'));
WS_1_1_1 = read_bor(fullfile(filePath,'WS'));
% WD_1_1_1 = read_bor(fullfile(filePath,'WD_1_1_1'));

% filePath = fullfile(biomet_path(yearsIn,siteID,'Flux/Clean'));
% WS_1_2_1 = read_bor(fullfile(filePath,'WS_1_2_1'));
% WD_1_2_1 = read_bor(fullfile(filePath,'WD_1_2_1'));

% plot data
figure(200)
clf
plot(tv_dt,TA_raw,'-')
% ylim([-30 100])
hold on
grid on
plot(tv_dt,TA_1_1_1,'-')
title('TA raw and first stage')
legend('raw','first stage')

figure(201)
clf
plot(tv_dt,WS_raw,'-')
% ylim([-30 100])
hold on
grid on
plot(tv_dt,WS_1_1_1,'-')
title('WS flux raw and WS first stage')

% figure(202)
% clf
% plot(tv_dt,WD_1_1_1,'-')
% % ylim([-30 100])
% hold on
% grid on
% plot(tv_dt,WD_1_2_1,'-')

% figure(203)
% clf
% plot(WS_1_1_1,WS_1_2_1,'.')
% 
% figure(204)
% clf
% plot(tv_dt,WS_met_raw,'-')
% % ylim([-30 100])
% hold on
% grid on
% plot(tv_dt,WS_flux_raw,'-')
% title('WS RM Young and WS sonic (both raw)')




