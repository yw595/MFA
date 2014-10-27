function renameSettingsFiles(suffix1,suffix2,suffix3,outputDir)

if ~exist('suffix1','var')
suffix='v0';

suffix1=suffix;
suffix2=suffix;
suffix3=suffix;

%suffix1='TwoIterBasis100Limits1000';
%suffix2='Basis100Limits1000OnlyGlucose';
%suffix3='Test';
end
if ~exist('outputDir','var')
    outputDir='outputMaster';
end

copyfile(['setting_PE' suffix1 '.mat'],[outputDir '/setting_PE.mat']);
copyfile(['setting_CI' suffix2 '.mat'],[outputDir '/setting_CI.mat']);
copyfile(['inputSubConfig' suffix3 '.mat'],[outputDir '/inputSubConfig.mat']);
end