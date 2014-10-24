suffix='1OnlyRedZeroBGMin1PercentHigh';
if(0)
movefile('x_solution.txt',['x_solution' suffix '.txt']);
movefile('x_sim.m',['x_sim' suffix '.m']);
movefile('substrate_EMU.m',['substrate_EMU' suffix '.m']);
%movefile('setting_PE.mat',['setting_PE' suffix '.mat']);
%movefile('setting_CI.mat',['setting_CI' suffix '.mat']);
movefile('resultsCI_raw.mat',['resultsCI_raw' suffix '.mat']);
movefile('results_x0.txt',['results_x0' suffix '.txt']);
movefile('results_x.txt',['results_x' suffix '.txt']);
movefile('results_fval.txt',['results_fval' suffix '.txt']);
movefile('results_flux.txt',['results_flux' suffix '.txt']);
movefile('results_exitflag.txt',['results_exitflag' suffix '.txt']);
movefile('results_CI.txt',['results_CI' suffix '.txt']);
movefile('measurements.txt',['measurements' suffix '.txt']);
movefile('inputSubEMU.mat',['inputSubEMU' suffix '.mat']);
%movefile('inputSubConfig.mat',['inputSubConfig' suffix '.mat']);
movefile('error.txt',['error' suffix '.txt']);
movefile('dee_x_sim.m',['dee_x_sim' suffix '.m']);
movefile('allBasis_soln.txt',['allBasis_soln' suffix '.txt']);
end
movefile('MID_solution.txt',['MID_solution' suffix '.txt']);
movefile('results_mid.txt',['results_mid' suffix '.txt']);
movefile('results_PE.txt',['results_PE' suffix '.txt']);