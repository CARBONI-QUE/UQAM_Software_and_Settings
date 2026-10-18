%% test UQAM_2 frequent gaps in calcs
%[~,~,~,structOut]=fr_read_GHG_file('Z:\uqam-site\Sites\UQAM_2\HighFrequencyData\raw\2026\09\2026-09-25T070000_AIU-2496.ghg');
[~,~,~,structOut]=fr_read_GHG_file('Z:\uqam-site\Sites\UQAM_2\HighFrequencyData\raw\2026\09\2026-09-24T060000_AIU-2496.ghg');
tv_dt = datetime(structOut.TimeVector,'ConvertFrom','datenum');
%%
figure(1)
plot(tv_dt,[structOut.U structOut.V structOut.W])
legend('U','V','W')
%plot(tv_dt,[ structOut.W])
