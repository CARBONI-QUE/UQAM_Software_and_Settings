tv=read_bor(fullfile('Z:\uqam-site\Database\2026\UQAM_3\Met','clean_tv'),8);
tv_dt = datetime(tv,'ConvertFrom','datenum');
trace_name = 'TA_1_1_1_avg';trace_nan  = 'nan_counter_TA_1_1_1';
%trace_name = 'PA_avg';trace_nan  = 'nan_counter_PA';
trc     = read_bor(fullfile('Z:\uqam-site\Database\2026\UQAM_3\Met',trace_name));
trc_nan = read_bor(fullfile('Z:\uqam-site\Database\2026\UQAM_3\Met',trace_nan));

ax = [];
figure(1)
clf
ax(1)= subplot(2,1,1);
plot(tv_dt,trc,'o')
title(trace_name)
ax(2)= subplot(2,1,2);
plot(tv_dt,trc_nan,tv_dt(trc_nan>=180),trc_nan(trc_nan>=180),'or')
title(trace_nan)
ylim(ax(2),[0 200]);

linkaxes(ax,'x')
zoom on
ylim(ax(2),[0 200]);