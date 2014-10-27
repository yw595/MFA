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
outputDir = 'outputMaster/batch';
suffix = 'v0TwoLock';
renameSettingsFiles('v0TwoLock','v0','v0',outputDir)
for iterIdx=1:10
    eval(['cd ' outputDir]);
    pwd
    start13OFBatch;
    eval('cd ../..');
    movefile([outputDir '/MID_solution.txt'],[outputDir '/MID_solution' suffix num2str(iterIdx) '.txt']);
    movefile([outputDir '/results_mid.txt'],[outputDir '/results_mid' suffix num2str(iterIdx) '.txt']);
    movefile([outputDir '/results_PE.txt'],[outputDir '/results_PE' suffix num2str(iterIdx) '.txt']);
end