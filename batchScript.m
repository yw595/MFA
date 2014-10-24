if(0)
clear all;
suffixes={'1OnlyRedZeroBGHigh','1OnlyRedZeroBGLow','1OnlyRedZeroBGMin1PercentHigh', ...
    '1OnlyRedZeroBGMin1PercentLow'};
suffixIdx=1;
for iterIdx=41:50
    copyfile(['dee_x_sim' suffixes{suffixIdx} '.m'],'dee_x_sim.m');
    copyfile(['error' suffixes{suffixIdx} '.txt'],'error.txt');
    copyfile(['measurements' suffixes{suffixIdx} '.txt'],'measurements.txt');
    copyfile(['substrate_EMU' suffixes{suffixIdx} '.m'],'substrate_EMU.m');
    copyfile(['x_sim' suffixes{suffixIdx} '.m'],'x_sim.m');
    start13OFbatch;
    movefile('MID_solution.txt',['MID_solution' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_mid.txt',['results_mid' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_PE.txt',['results_PE' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
end

clear all;
suffixes={'1OnlyRedZeroBGHigh','1OnlyRedZeroBGLow','1OnlyRedZeroBGMin1PercentHigh', ...
    '1OnlyRedZeroBGMin1PercentLow'};
suffixIdx=2;
for iterIdx=41:50
    copyfile(['dee_x_sim' suffixes{suffixIdx} '.m'],'dee_x_sim.m');
    copyfile(['error' suffixes{suffixIdx} '.txt'],'error.txt');
    copyfile(['measurements' suffixes{suffixIdx} '.txt'],'measurements.txt');
    copyfile(['substrate_EMU' suffixes{suffixIdx} '.m'],'substrate_EMU.m');
    copyfile(['x_sim' suffixes{suffixIdx} '.m'],'x_sim.m');
    start13OFbatch;
    movefile('MID_solution.txt',['MID_solution' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_mid.txt',['results_mid' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_PE.txt',['results_PE' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
end


clear all;
suffixes={'1OnlyRedZeroBGHigh','1OnlyRedZeroBGLow','1OnlyRedZeroBGMin1PercentHigh', ...
    '1OnlyRedZeroBGMin1PercentLow'};
suffixIdx=3;
for iterIdx=32:40
    copyfile(['dee_x_sim' suffixes{suffixIdx} '.m'],'dee_x_sim.m');
    copyfile(['error' suffixes{suffixIdx} '.txt'],'error.txt');
    copyfile(['measurements' suffixes{suffixIdx} '.txt'],'measurements.txt');
    copyfile(['substrate_EMU' suffixes{suffixIdx} '.m'],'substrate_EMU.m');
    copyfile(['x_sim' suffixes{suffixIdx} '.m'],'x_sim.m');
    start13OFbatch;
    movefile('MID_solution.txt',['MID_solution' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_mid.txt',['results_mid' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_PE.txt',['results_PE' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
end

clear all;
suffixes={'1OnlyRedZeroBGHigh','1OnlyRedZeroBGLow','1OnlyRedZeroBGMin1PercentHigh', ...
    '1OnlyRedZeroBGMin1PercentLow'};
suffixIdx=4;
for iterIdx=1:40
    copyfile(['dee_x_sim' suffixes{suffixIdx} '.m'],'dee_x_sim.m');
    copyfile(['error' suffixes{suffixIdx} '.txt'],'error.txt');
    copyfile(['measurements' suffixes{suffixIdx} '.txt'],'measurements.txt');
    copyfile(['substrate_EMU' suffixes{suffixIdx} '.m'],'substrate_EMU.m');
    copyfile(['x_sim' suffixes{suffixIdx} '.m'],'x_sim.m');
    start13OFbatch;
    movefile('MID_solution.txt',['MID_solution' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_mid.txt',['results_mid' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_PE.txt',['results_PE' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
end
end

clear all;
suffixes={'1OnlyRedZeroBGHigh','1OnlyRedZeroBGLow','1OnlyRedZeroBGMin1PercentHigh', ...
    '1OnlyRedZeroBGMin1PercentLow','1OnlyRedZeroBGMin1PercentHighAllLock'};
suffixIdx=3;
copyfile('setting_PETwoIterBasis100Limits1000.mat','setting_PE.mat');
for iterIdx=1:40
    copyfile(['dee_x_sim' suffixes{suffixIdx} '.m'],'dee_x_sim.m');
    copyfile(['error' suffixes{suffixIdx} '.txt'],'error.txt');
    copyfile(['measurements' suffixes{suffixIdx} '.txt'],'measurements.txt');
    copyfile(['substrate_EMU' suffixes{suffixIdx} '.m'],'substrate_EMU.m');
    copyfile(['x_sim' suffixes{suffixIdx} '.m'],'x_sim.m');
    start13OFbatch;
    movefile('MID_solution.txt',['MID_solution' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_mid.txt',['results_mid' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_PE.txt',['results_PE' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
end

clear all;
suffixes={'1OnlyRedZeroBGHigh','1OnlyRedZeroBGLow','1OnlyRedZeroBGMin1PercentHigh', ...
    '1OnlyRedZeroBGMin1PercentLow','1OnlyRedZeroBGMin1PercentHighAllLock'};
suffixIdx=5;
copyfile('setting_PETwoIterBasis100Limits1000AllLock.mat','setting_PE.mat');
for iterIdx=1:40
    copyfile(['dee_x_sim' suffixes{suffixIdx} '.m'],'dee_x_sim.m');
    copyfile(['error' suffixes{suffixIdx} '.txt'],'error.txt');
    copyfile(['measurements' suffixes{suffixIdx} '.txt'],'measurements.txt');
    copyfile(['substrate_EMU' suffixes{suffixIdx} '.m'],'substrate_EMU.m');
    copyfile(['x_sim' suffixes{suffixIdx} '.m'],'x_sim.m');
    start13OFbatch;
    movefile('MID_solution.txt',['MID_solution' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_mid.txt',['results_mid' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
    movefile('results_PE.txt',['results_PE' suffixes{suffixIdx} num2str(iterIdx) '.txt']);
end