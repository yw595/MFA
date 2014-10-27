function renameOutputFiles2(suffix,inputAndOutputDir)
if ~exist(suffix,'var')
    suffix='v0';
end
if ~exist(inputAndOutputDir,'var')
    inputAndOutputDir='outputMaster';
end
movefile([inputAndOutputDir '/MID_solution' suffix '.txt'],[inputAndOutputDir '/MID_solution.txt']);
movefile([inputAndOutputDir '/results_mid' suffix '.txt'],[inputAndOutputDir '/results_mid.txt']);
movefile([inputAndOutputDir '/results_PE' suffix '.txt'],[inputAndOutputDir '/results_PE.txt']);
end