%author Lake-Ee Quek, AIBN
check = 1;

TCases = [1 2 3 4 5 7 8 9 10 11 12 13 19];
TCounter = [1 1 1 2 2 1 1 1 1 1 1 1 1];
report={};
if check == 1
    load setting_PE.mat
end

errorFile = report{1};
if errorFile == 0
    rel_error = report{2}/100;
end
%report
par = report{3};
rev_lb = report{4};
rev_ub_h = report{5};
fow_lb = report{6};
fow_ub = report{7};
itt_e = report{8};
useRand = report{9};
options_e = optimset('LargeScale', 'off','TolFun',report{10}, 'TolCon', report{11},...
    'Display', 'iter', 'GradObj','off','DerivativeCheck', 'off', 'MaxIter', 800, 'MaxFunEvals', 15000);
clusterNo = report{12};
saveClusSoln = report{13};
outlier_cutoff = report{14};
useFluxAsM = report{15};
constraints_e = report{16};


global guidedInSub
guidedInSub = 0;

inputSubReaderbatch(AAVFile);
guidedInSub =1;
        