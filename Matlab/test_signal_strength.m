structProject = get_TAB_project;
yearIn=2026;
tv = read_bor(fullfile(structProject.databasePath,'yyyy','UQAM_3','Met','clean_tv'),8,[],yearIn);
tv_dt = datetime(tv,'ConvertFrom','datenum');

%%
UQAM_1 = read_bor(fullfile(structProject.databasePath,'yyyy','UQAM_1','Flux','avg_signal_strength_7200_mean'),[],[],yearIn);
UQAM_2 = read_bor(fullfile(structProject.databasePath,'yyyy','UQAM_2','Flux','avg_signal_strength_7200_mean'),[],[],yearIn);
UQAM_3 = read_bor(fullfile(structProject.databasePath,'yyyy','UQAM_3','Flux','avg_signal_strength_7200_mean'),[],[],yearIn);
UQAM_4 = read_bor(fullfile(structProject.databasePath,'yyyy','UQAM_4','Flux','avg_signal_strength_7200_mean'),[],[],yearIn);
MCGILL_1 = read_bor(fullfile(structProject.databasePath,'yyyy','MCGILL_1','Flux','avg_signal_strength_7200_mean'),[],[],yearIn);

%%
figure(1)
plot(tv_dt,[UQAM_1 UQAM_2 UQAM_3 UQAM_4 MCGILL_1])
legend('UQAM_1','UQAM_2','UQAM_3','UQAM_4','MCGILL_1');
