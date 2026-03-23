function [t,x] = uqam_pl(ind, yearIn, siteID, select, fig_num_inc,flgPause) 
%
% [t,x] = UQAM_pl(ind, yearIn,siteID, select, fig_num_incflgPause)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
% (c) c) Nesic Zoran         File created:       Jul 15, 2024      
%                            Last modification:  Jan 15, 2026
%           
%

% Revisions:
%
% Jan 16, 2026 (Zoran)
%   - made ECCC plotting site-specific. (there was a bug - it plotted
%     always the same station)
%   - added special cases for UQAM_4b logger
% Dec 18, 2025 (Zoran)
%   - Added wind direction comparison Sonic vs RMYOUNG
%   - Added plotting of spin and pump motors as well as the heaters for LI-7700
%   - added shading of "out of range" measurements (see shadeBadZone())
% Nov 29, 2025 (Zoran)
%   - Added battery temperatures for MCGILL_1
% Nov 14, 2025 (Zoran)
%   - Improved power plotting
% Sep 2, 2025 (Zoran)
%   - added Power plotting
% Jul 23, 2025 (Zoran)
%   - Automatically generate allSites as a default siteIN
% Apr 11, 2025 (Zoran)
%   - added UQAM-3
%   - chaged input variable name "year" to "yearIn"
%   - chagned how default year is created (used datetime)
% Jan 2, 2025 (Zoran)
%   - added try/catch/end when setting up xlim for cumulative precip.
%     Otherwise the program doesn't work well at the beginning of a new yearIn.

structProject = get_TAB_project;
allSites = get_TAB_site_names;
arg_default('siteID',allSites);        % default - all sites
arg_default('fig_num_inc',1);
arg_default('select',1);
arg_default('flgPause',1);              % default is show one figure and pause

arg_default('yearIn',year(datetime));              % assume current yearIn

pthSite = biomet_path('yyyy',siteID);

if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 0/24;                            % offset to convert GMT to PST
siteID = upper(siteID);                     % convert to uppercase

st = min(ind);                              % first day of measurements
ed = max(ind)+1;                            % last day of measurements (approx.)
ind = st:ed; %#ok<*NASGU>

datesTmp = datenum(yearIn,1,[st ed]);
[rangeYears,~,~,~,~,~] = datevec(datesTmp);
rangeYears = rangeYears(1):rangeYears(2);

tv=fr_round_time(read_bor(fullfile(pthSite,'MET','TimeVector'),8,[],rangeYears)); % get time from the data base
t = tv - datenum(yearIn,1,0) - GMTshift;               % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;

allAxes = [];
indAxes = 0;
%----------------------------------------------------------
% HMP air temperatures
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Air Temperature');
pathECCC = sprintf('yyyy\\ECCC\\%d\\30min',structProject.sites.(siteID).dataSources.eccc(1).stationsID);
trace_path  = char(fullfile(pthSite,'MET','TA_1_1_1_AVG'),...
                   fullfile(pthSite,'MET','TA_1_2_1_AVG'),...
                   fullfile(db_pth_root,pathECCC,'Tair'),...
                   fullfile(pthSite,'Flux','air_temperature')...                   
                   );
tempOffset = [0 0 0 273.15];   %273.15 273.15];
trace_legend = char('T_{HMP-1}','T_{HMP-2}','ECCC 10732','SonicT');
trace_units = 'T_{air}(degC)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[],tempOffset );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% HMP RH
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Relative Humidity');

trace_path  = char(fullfile(pthSite,'MET','RH_1_1_1_AVG'),...
                   fullfile(pthSite,'MET','RH_1_2_1_AVG'),...
                   fullfile(db_pth_root,pathECCC,'RH')...
                   );
trace_legend = char('RH_{HMP-1}','RH_{HMP-2}','ECCC 10732');
trace_units = 'RH (%)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;


%----------------------------------------------------------
% Rain gauges
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Precipitation');

trace_path  = char(fullfile(pthSite,'MET','P_1_1_1_tot'),...
                   fullfile(db_pth_root,pathECCC,'Precip')...
                   );
trace_legend = char('TB-Site','TB-ECCC');

trace_units = 'Precipitation (mm/30-min)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
% remember xlim, you'll need it to rescale cumulative rain
originalXlim = xlim;

%----------------------------------------------------------
% Cumulative rain
%----------------------------------------------------------
% *** in case of multiple-yearIn plots it plots only the last yearIn
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the last yearIn
indNew = [1:length(indx)]+round(GMTshift*48);               % use GMTshift to align the data with time vector


trace_name  = sprintf('%s: %s',siteID,'Cumulative Rain (current yearIn only)');
trace_units = 'Precipitation (mm)';
trace_legend = char('TB-Site','TB-ECCC');
y_axis      = [];

trace_path  = char(fullfile(pthSite,'MET','P_1_1_1_tot'));
[x1,tx_new] = read_sig(trace_path(1,:), indNew,yearIn, tx,0); %#ok<*ASGLU>
x1(isnan(x1)) = 0; % replace NaNs with 0 so that cumsum can work

trace_path  = char(fullfile(db_pth_root,pathECCC,'Precip'));
[x2,tx_new] = read_sig(trace_path(1,:), indNew,yearIn, tx,0); %#ok<*ASGLU>
x2(isnan(x2)) = 0; % replace NaNs with 0 so that cumsum can work

fig_num = fig_num + fig_num_inc;
x = plt_msig( [cumsum(x1) cumsum(x2)], ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
try
    xlim(originalXlim);
    indAxes = indAxes+1; allAxes(indAxes) = gca;
catch
    close(fig_num);
    fig_num = fig_num - fig_num_inc;
end


%----------------------------------------------------------
% CNR4 components
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' CNR4 components');
switch siteID
    case 'UQAM_4'
        trace_path  = char(fullfile(pthSite,'MET/B','SYS_SW_IN_AVG'),...
                           fullfile(pthSite,'MET/B','SYS_SW_OUT_AVG'),...
                           fullfile(pthSite,'MET/B','SYS_LW_IN_AVG'),...
                           fullfile(pthSite,'MET/B','SYS_LW_OUT_AVG')...
                           );
    otherwise
        trace_path  = char(fullfile(pthSite,'MET','SW_IN_AVG'),...
                           fullfile(pthSite,'MET','SW_OUT_AVG'),...
                           fullfile(pthSite,'MET','LW_IN_AVG'),...
                           fullfile(pthSite,'MET','LW_OUT_AVG')...
                           );
end
trace_legend = char('SW_{IN}','SW_{OUT}','LW_{IN}','LW_{OUT}');
trace_units = '(W)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% NET radiation
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' NETRAD');
switch siteID
    case 'UQAM_4'
        trace_path  = char(fullfile(pthSite,'MET/B','SYS_NETRAD_AVG')...
                   );
    otherwise
        trace_path  = char(fullfile(pthSite,'MET','NETRAD_AVG')...
                           );
end
trace_legend = [];
trace_units = '(µmol/m2/s)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([-150 800])

%----------------------------------------------------------
% PPFD
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' PPFD');
switch siteID
    case 'UQAM_4'
         trace_path  = char(fullfile(pthSite,'MET/B','SYS_PPFD_IN_AVG'),...
                            fullfile(pthSite,'MET/B','SYS_PPFD_OUT_AVG')...
                            );
    otherwise
        trace_path  = char(fullfile(pthSite,'MET','PPFD_IN_AVG'),...
                           fullfile(pthSite,'MET','PPFD_OUT_AVG')...
                            );
end
trace_legend = char('PPFD_{IN}','PPFD_{OUT}');
trace_units = '(µmol/m2/s)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Wind Speed
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Wind Speed');
trace_path  = char(fullfile(pthSite,'MET','WS_AVG'),...
                   fullfile(pthSite,'MET','WS_MAX'),...
                   fullfile(db_pth_root,pathECCC,'WindSpeed')...
                  );
trace_legend = char('MET (avg)','MET (max)','ECCC');
trace_units = '(m/s)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Wind Direction
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Wind Direction');
trace_path  = char(fullfile(pthSite,'MET','WD'),...
                   fullfile(pthSite,'flux','wind_dir'),...
                   fullfile(db_pth_root,pathECCC,'WindDir')...
                   );
trace_legend = char('MET','Sonic','ECCC');
trace_units = 'deg';
unitCorrection = [1 1 10];
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,unitCorrection );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Samples collected
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Samples in 30min');
trace_path  = char(fullfile(pthSite,'flux','file_records'),fullfile(pthSite,'flux','used_records'));
trace_legend = char('Collected','Used');
trace_units = '# of Samples';
y_axis      = [34000 37000];
fig_num = fig_num + fig_num_inc;
[x, dTV]= plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indNans = find(isnan(sum(x,2)));
if ~isempty(indNans)
    line(dTV(indNans,1),ones(length(indNans),1)*36000,...
        'LineStyle','none','Marker','x','Color','k','MarkerSize',10,...
        'DisplayName','Missing')
end
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([35000 Inf])

%----------------------------------------------------------
% 24V Battery Voltage
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Battery Voltage');
switch siteID
    case 'UQAM_4'
        trace_path  = char( fullfile(pthSite,'flux','hit_vin_mean'),...
                            fullfile(pthSite,'met','Voltage_24V_avg'),...
                            fullfile(pthSite,'Met\B','SYS_Logger_Batt_Min')...
                           );
        trace_legend = char('hit-vin-mean','Main','Logger B');
    otherwise
        trace_path  = char( fullfile(pthSite,'flux','hit_vin_mean'),...
                            fullfile(pthSite,'met','Voltage_24V_avg'),...
                            fullfile(pthSite,'Met\SYS','SYS_PBox_Batt_Volt_Avg')...
                           );
        trace_legend = char('hit-vin-mean','Main','SYS_{PBox}');
end

trace_units = '24V Battery Voltage (V)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
sysVoltage24 = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([23 30.3])

%----------------------------------------------------------
% Battery Current
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Battery Current');
coeffSign = 0;
if strcmp(siteID,'MCGILL_1')
    trace_path = char( fullfile(pthSite,'Met','PowerBox_Current_Avg'),...
                       fullfile(pthSite,'Met\SYS','SYS_Batt_DCCurrent_Min'),...
                       fullfile(pthSite,'Met\SYS','SYS_Batt_DCCurrent_Max'),...
                       fullfile(pthSite,'Met\SYS','SYS_Batt_DCCurrent_Avg'));
    trace_legend = char('Tower','Batt_{Min}','Batt_{Max}','Batt_{Avg}');
else
    trace_path = char(fullfile(pthSite,'Met','PowerBox_Current_Avg'));
    trace_legend = [];
end

trace_units = '24V Battery Current (Amps)';

y_axis      = [];
fig_num = fig_num + fig_num_inc;
sysCurrent = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num ); 
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([-5 Inf])

%----------------------------------------------------------
% Cumulative Battery Current
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Cumulative Battery Current');
switch siteID
    case 'MCGILL_1'
        Ibb1 = read_sig( fullfile(pthSite,'Met\SYS', 'SYS_Batt_DCCurrent_Avg'), ind,yearIn, t, 0 );
        Ibb1(isnan(Ibb1))=0;
        trace_path = (1+cumsum(Ibb1/2)/2600)*100;    % Ah / Ah
        trace_legend = [];
    otherwise
        Ibb1 = read_sig( fullfile(pthSite,'Met', 'PowerBox_Current_Avg'), ind,yearIn, t, 0 );
        Ibb1(isnan(Ibb1))=0;
        trace_path = (1+cumsum(Ibb1/2)/2600)*100;    % Ah / Ah
        trace_legend = [];
end
trace_units = 'Cummulative Current (%)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;


%----------------------------------------------------------
% Logger Voltage
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Logger Voltage');
switch siteID
    case 'UQAM_4'
        trace_path  = char(fullfile(pthSite,'flux','Voltage_12V_Avg'),...
                           fullfile(pthSite,'met','SYS_Logger_Batt_Min'),...
                           fullfile(pthSite,'met\B','SYS_BattV_Avg'));
        trace_legend = char('Voltage 12V Avg','Logger - A', 'Logger - B');
    otherwise
        trace_path  = char(fullfile(pthSite,'flux','Voltage_12V_Avg'),...
                           fullfile(pthSite,'met','SYS_Logger_Batt_Min'));
        trace_legend = char('Voltage 12V Avg','SmartFlux V','SYS Logger Batt Min');
end
      
trace_units = 'Instrument Voltage (V)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
sysVoltage = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([11.8 15.1])

%----------------------------------------------------------
% System Power
%----------------------------------------------------------

trace_name  = sprintf('%s: %s',siteID,' System Power');
switch siteID
    case 'MCGILL_1'
        trace_path = [sum(sysVoltage24(:,3).*sysCurrent(:,4),2,'omitnan') ...
                      sum(sysVoltage24(:,2).*sysCurrent(:,1),2,'omitnan')];
        trace_legend = char('Total Power','Tower Power'); 
    otherwise
        % trace_path = [];
        % fig_num = fig_num-1;
        trace_path = [sum(sysVoltage24(:,2).*sysCurrent(:,1),2,'omitnan')];
        trace_legend = [];
end

trace_units = 'System Power (W)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
sysPower = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([-100 Inf])

%----------------------------------------------------------
% System Energy
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' System Energy');
switch siteID
    case {'HOGG','YOUNG','OHM'}
        trace_path = [];
        fig_num = fig_num-1;
    otherwise
        trace_path = cumsum(sysPower(:,1)/2,'omitnan');
end
trace_units = 'System Energy (Wh)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
sysEnergy = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% System Temperatures
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' System Temperatures');
switch siteID
    case {'MCGILL_1'}
        trace_path  = char(fullfile(pthSite,'MET','SYS_Logger_Temp_Avg'),...
                           fullfile(pthSite,'MET\SYS','SYS_BatteryBoxTC_Avg'),...
                           fullfile(pthSite,'MET\SYS','SYS_chargerTC_Avg'),...
                           fullfile(pthSite,'MET\SYS','SYS_PanelT_CR1000_Avg')...
                   );
        trace_legend = char('CR1000x','Battery','Charger','Battery Logger');
    case {'UQAM_4'}
        trace_path  = char(fullfile(pthSite,'MET','SYS_Logger_Temp_Avg'),...
                           fullfile(pthSite,'MET\B','SYS_PTemp_C_Avg')...
                   );
        trace_legend = char('CR1000x','Battery','Charger','Battery Logger');    
    otherwise
        trace_path  = char(fullfile(pthSite,'MET','SYS_Logger_Temp_Avg')...  
                   );
        trace_legend = char('CR1000x');
end

trace_units = 'Temperature (\circC)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([-20 45])

%----------------------------------------------------------
% LI-7200 Thermocouples
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' LI-7200 Thermocouples');
trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.tempIn.avg',siteID)),...
                   fullfile(pthSite,'monitorSites',sprintf('%s.tempOut.avg',siteID)));
trace_legend = char('T_{in}','T_{out}');
trace_units = 'Temperature (\circC)'; % flowrate_min needs to be converted from m^3/sec *1000*60 (L/min)
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, ...
              trace_legend, yearIn, trace_units, ...
              y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;


%----------------------------------------------------------
% LI-7200 Flow rate
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' LI-7200 Flow Rate');
switch siteID
    case {'HOGG','YOUNG','OHM'}
        trace_path = [];
        fig_num = fig_num-1;
    otherwise
        trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.flowRate.avg',siteID)),...
                           fullfile(pthSite,'Flux','flowrate_mean'));
end
trace_legend = char('Monitor','EddyPro');
trace_units = 'Flow (lpm)'; % flowrate_min needs to be converted from m^3/sec *1000*60 (L/min)
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[1 1000*60] );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([12 Inf])

%----------------------------------------------------------
% Flow Drive
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Flow Drive');
switch siteID
    case {'HOGG','YOUNG','OHM'}
        trace_path = [];
        fig_num = fig_num-1;
    otherwise
        trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.FlowDrive.avg',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.FlowDrive.min',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.FlowDrive.max',siteID))...
        );
        trace_legend = char('Avg','Min','Max');
end
trace_units = 'Flow Drive (%)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([30 98])

%----------------------------------------------------------
% Head Pressure
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Head Pressure');
switch siteID
    case {'HOGG','YOUNG','OHM'}
        trace_path = [];
        fig_num = fig_num-1;
    otherwise
        trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.Phead.avg',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.Phead.min',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.Phead.max',siteID))...
        );
        trace_legend = char('Avg','Min','Max');
end
trace_units = 'Phead (kPa)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([-3.6 -0.8])

%----------------------------------------------------------
% Air pressure
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Air Pressure');
trace_path  = char(fullfile(pthSite,'Flux','air_pressure'),...
                   fullfile(pthSite,'Flux','air_p_mean'),...
                   fullfile(pthSite,'Met','PA_avg')...
    );
trace_legend = char('air\_pressure','air\_P\_mean','Met PA');
trace_mult = [ 1 1 100] * 0.001;
trace_units = 'Barometric Pressure (kPa)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num, trace_mult );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Spikes
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Spikes');
trace_path = char(fullfile(pthSite,'Flux','w_spikes'),...
                  fullfile(pthSite,'Flux','ts_spikes'),...
                  fullfile(pthSite,'Flux','co2_spikes'),...
                  fullfile(pthSite,'Flux','h2o_spikes'),...
                  fullfile(pthSite,'Flux','ch4_spikes')...
                  );
trace_legend = char('w_{spikes}','ts_{spikes}','co2_{spikes}','h2o_{spikes}','ch4_{spikes}');
trace_units = 'Number of spikes';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([-Inf 4000])

%----------------------------------------------------------
% Diagnostics
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Diagnostics');
switch siteID
    case {'HOGG','YOUNG','OHM'}
        trace_path  = char(fullfile(pthSite,'Flux','chopper_LI_7500'),...
                          fullfile(pthSite,'Flux','detector_LI_7500'),...
                          fullfile(pthSite,'Flux','pll_LI_7500'),...
                          fullfile(pthSite,'Flux','sync_LI_7500'),...
                          fullfile(pthSite,'Flux','not_ready_LI_7700'),...
                          fullfile(pthSite,'Flux','no_signal_LI_7700'),...
                          fullfile(pthSite,'Flux','bad_temp_LI_7700'),...
                          fullfile(pthSite,'Flux','laser_temp_unregulated_LI_7700'),...
                          fullfile(pthSite,'Flux','motor_failure_LI_7700'),...
                          fullfile(pthSite,'Flux','block_temp_unregulated_LI_7700')...
                           );
        trace_legend = char('chopper_{LI-7500}','detector_{LI-7500}',...
                            'pll_{LI-7500}','sync_{LI-7500}','notReady_{LI-7700}',...
                            'nosignal_{LI-7700}','badTemp_{LI-7700}',...
                            'laserTemp_{LI-7700}','motor_{LI-7700}',...
                            'blockTemp_{LI-7700}');
    otherwise
        trace_path  = char(fullfile(pthSite,'Flux','head_detect_LI_7200'),...
                          fullfile(pthSite,'Flux','t_in_LI_7200'),...
                          fullfile(pthSite,'Flux','t_out_LI_7200'),...
                          fullfile(pthSite,'Flux','chopper_LI_7200'),...
                          fullfile(pthSite,'Flux','detector_LI_7200'),...
                          fullfile(pthSite,'Flux','pll_LI_7200'),...
                          fullfile(pthSite,'Flux','sync_LI_7200'),...
                          fullfile(pthSite,'Flux','not_ready_LI_7700'),...
                          fullfile(pthSite,'Flux','no_signal_LI_7700'),...
                          fullfile(pthSite,'Flux','bad_temp_LI_7700'),...
                          fullfile(pthSite,'Flux','laser_temp_unregulated_LI_7700'),...
                          fullfile(pthSite,'Flux','motor_failure_LI_7700'),...
                          fullfile(pthSite,'Flux','block_temp_unregulated_LI_7700')...
                           );
        trace_legend = char('head_{LI-7200}','Tin_{LI-7200}',...
                            'Tout_{LI-7200}','chopper_{LI-7200}',...
                            'detector_{LI-7200}','pll_{LI-7200}','sync_{LI-7500}',...                            
                            'detector_{LI-7700}',...
                            'nosignal_{LI-7700}','badTemp_{LI-7700}',...
                            'laserTemp_{LI-7700}','motor_{LI-7700}',...
                            'blockTemp_{LI-7700}');
end
trace_units = 'Num of errors';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Signal Strength
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Signal Strength');
switch siteID
    case {'HOGG','YOUNG'}
        trace_path = char(fullfile(pthSite,'monitorSites',sprintf('%s.signalStrength7200.avg',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.signalStrength7700.avg',siteID)),...
                           fullfile(pthSite,'Flux','mean_value_LI_7500'),...
                          fullfile(pthSite,'Flux','rssi_77_mean')...
                          );
        trace_legend = char('7500_{MO}','7700_{MO}','7500_{EP}','7700_{EP}');
    case {'OHM'}
        trace_path = char(fullfile(pthSite,'Flux','mean_value_LI_7500'),...
                          fullfile(pthSite,'Flux','rssi_77_mean')...
                          );
        trace_legend = char('7500_{EP}','7700_{EP}');
    otherwise
        trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.signalStrength7200.avg',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.signalStrength7700.avg',siteID)),...
                           fullfile(pthSite,'Flux','avg_signal_strength_7200_mean'),...
                           fullfile(pthSite,'Flux','rssi_77_mean')...                           
                           );
        trace_legend = char('7200_{MO}','7700_{MO}','7200_{EP}','7700_{EP}');
end
trace_units = 'Signal Strength (%)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
shadeBadZone([15 Inf])

%----------------------------------------------------------
% LI700 Washer pump
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' LI-7700 Washer pump');
trace_path  = char(fullfile(pthSite,'Flux','pump_on_LI_7700'));
trace_legend = [];
trace_units = 'Washer Pump ON (Samples)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[],[],char('o') );
% Add a shaded area where the trace should not exist (above 500)
shadeBadZone([-Inf 500])
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% LI7700 spin motor
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' LI7700 spin motor');
trace_path  = char(fullfile(pthSite,'Flux','motor_spinning_LI_7700'));
trace_legend = [];
trace_units = 'Spin Motor ON (Samples)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[],[],char('o') );
% Add a shaded area where the trace should not exist (above 500)
shadeBadZone([-Inf 700])
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% LI7700 heaters
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' LI7700 Heaters');
trace_path  = char(fullfile(pthSite,'Flux','top_heater_on_LI_7700'),...
                  fullfile(pthSite,'Flux','bottom_heater_on_LI_7700')...
                  );
trace_legend = char('Top','Bottom');
trace_units = 'Heaters ON (Samples)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[],[],char('o','d') );
% Add a shaded area where the trace should not exist (above 500)
shadeBadZone([-Inf 37000])
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Delay times
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Delay Times');
trace_path  = char(fullfile(pthSite,'Flux','h2o_time_lag'),...
                   fullfile(pthSite,'Flux','co2_time_lag'),...
                   fullfile(pthSite,'Flux','ch4_time_lag')...
                   );
trace_legend = char('h_2o','co_2','ch_4');
trace_units = 'Delay Times (Seconds)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[],[],char('o') );
shadeBadZone([-0.3 0.3])
indAxes = indAxes+1; allAxes(indAxes) = gca;
%----------------------------------------------------------
% Delay times histogram
%----------------------------------------------------------
fig_num = fig_num + fig_num_inc;
figure(fig_num)
set(fig_num,'menubar','none',...
            'numbertitle','off',...
            'Name',[siteID ': Delay Times Histogram']);
pos = get(0,'screensize');
set(fig_num,'position',[8 pos(4)/2-20 pos(3)-20 pos(4)/2-35]);      
clf
subplot(3,1,1)
histogram(x(:,1),'binwidth',0.05,Normalization="percentage")
xlim([-2 2])
grid on
ytickformat("percentage");
title([siteID ': H_2O'])
subplot(3,1,2)
histogram(x(:,2),'binwidth',0.05,Normalization="percentage");
xlim([-2 2])
grid on
title([siteID ': CO_2'])
ytickformat("percentage");
subplot(3,1,3)
histogram(x(:,3),'binwidth',0.05,Normalization="percentage"); 
xlim([-2 2])
title([siteID ': CH_4'])
ytickformat("percentage");
% hold off
grid on
xlabel('Seconds')


%----------------------------------------------------------
% Soil moisture
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Soil Moisture');
switch siteID
    case 'UQAM_4'
        trace_path  = char( fullfile(pthSite,'met/B','a_CS650_1_1_1_Avg'),...
                            fullfile(pthSite,'met/B','a_CS650_1_2_1_Avg'),...
                            fullfile(pthSite,'met/B','a_CS650_1_3_1_Avg'),...
                            fullfile(pthSite,'met/B','a_CS650_1_4_1_Avg')...
                            );
    otherwise
        trace_path  = char( fullfile(pthSite,'met','a_CS650_1_1_1_Avg'),...
                            fullfile(pthSite,'met','a_CS650_1_2_1_Avg'),...
                            fullfile(pthSite,'met','a_CS650_1_3_1_Avg'),...
                            fullfile(pthSite,'met','a_CS650_1_4_1_Avg')...
                            );
end

trace_legend = char('1','2','3','4');
trace_units = '(%)'; 
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% CO2
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' CO_2');

trace_path  = char( fullfile(pthSite,'flux','co2_mixing_ratio')...
                   );

trace_legend = [];
trace_units = '(umol/mol)'; 
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% CH4
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' CH_4');

trace_path  = char( fullfile(pthSite,'flux','ch4_mixing_ratio')...
                   );

trace_legend = [];
trace_units = '(umol/mol)'; 
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% H2O
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' H_2O');

trace_path  = char( fullfile(pthSite,'flux','h2o_mixing_ratio')...
                   );

trace_legend = [];
trace_units = '(mmol/mol)'; 
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

linkaxes(allAxes,'x');


if flgPause ~= 1
    return
end
%------------------------------------------
if select == 1 %diagnostics only
    childn = get(0,'children');
    allFig = {childn.Number};
    allfFig = cell2mat(allFig);
    allfFig = sort(allfFig);
    N = length(allfFig);
    for i=1:N
        if i < 200
            figNum = get(allfFig(i),'number');
            figure(figNum);
            pause;
        end
    end
    return
end

end


