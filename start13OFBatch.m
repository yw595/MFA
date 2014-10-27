%author Lake-Ee Quek, AIBN
clc;
global constraints_e constraints_r par options_r
addpath(genpath(fullfile(pwd,'model')));

a = dir(fullfile(pwd,'*.mat'));
CIFile = 0;
PEFile = 0;
MCFile = 0;
AAVFile = 0;
for i = 1:length(a)
    if strcmp(a(i).name, 'setting_CI.mat')
        CIFile = 1;
    end
    if strcmp(a(i).name, 'setting_PE.mat')
        PEFile = 1;
    end
    if strcmp(a(i).name, 'setting_MC.mat')
        MCFile = 1;
    end
    if strcmp(a(i).name, 'inputSubConfig.mat')
        AAVFile = 1;
    end
end

repeat = 0;
task=1;

%%%%%%%%%%%%%%loading default values%%%%%%%%%%%%%%%%%%%%%%%
check_ns = 0; regen_PE = 0; regen_CI = 0; regen_MC = 0; fowSim = 0; useFluxAsM = 0; activity='';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if task == 1
    activity = 'flux_estimate';
    task1Batch;
    disp(' ');
    MCrun=0;
    runNow=1;
    if runNow ==1
        base_driver
    end
end