suffix='v0';

suffix1=suffix;
suffix2=suffix;
suffix3=suffix;

%suffix1='TwoIterBasis100Limits1000';
%suffix2='Basis100Limits1000OnlyGlucose';
%suffix3='Test';

copyfile(['setting_PE' suffix1 '.mat'],'outputMaster/setting_PE.mat');
copyfile(['setting_CI' suffix2 '.mat'],'outputMaster/setting_CI.mat');
copyfile(['inputSubConfig' suffix3 '.mat'],'outputMaster/inputSubConfig.mat');