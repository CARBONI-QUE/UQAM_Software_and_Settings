kill
profile on;
fr_automated_cleaning(2026,'MCGILL_1',[1 2]);
profile off
S = profile('info');
%%
for cnt = 1:length(S.FunctionTable)
    fileName = S.FunctionTable(cnt).FileName;
    if      ~isempty(fileName) ...
            && ~contains(fileName,"C:\Program Files\MATLAB\R2024a\toolbox\matlab",'IgnoreCase',true) ...
            && ~contains(fileName,"biomet.net",'IgnoreCase',true)
        fprintf('%6d - %s\n',cnt,fileName);
    end
end
