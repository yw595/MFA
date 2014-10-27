function renameOutputFiles(suffix,inputAndOutputDir)
if ~exist(suffix,'var')
    suffix='v0';
end
if ~exist(inputAndOutputDir,'var')
    inputAndOutputDir='outputMaster';
end
movefile([inputAndOutputDir '/MID_solution.txt'],[inputAndOutputDir '/MID_solution' suffix '.txt']);
movefile([inputAndOutputDir '/results_mid.txt'],[inputAndOutputDir '/results_mid' suffix '.txt']);
movefile([inputAndOutputDir '/results_PE.txt'],[inputAndOutputDir '/results_PE' suffix '.txt']);
end