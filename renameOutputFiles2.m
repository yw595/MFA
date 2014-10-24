suffix='1OnlyRedZeroBGHigh';
if(0)
movefile(['x_solution' suffix '.txt'],'x_solution.txt');
movefile(['x_sim' suffix '.m'],'x_sim.m');
movefile(['substrate_EMU' suffix '.m'],'substrate_EMU.m');
%movefile(['setting_PE' suffix '.mat'],'setting_PE.mat');
%movefile(['setting_CI' suffix '.mat'],'setting_CI.mat');
movefile(['resultsCI_raw' suffix '.mat'],'resultsCI_raw.mat');
movefile(['results_x0' suffix '.txt'],'results_x0.txt');
movefile(['results_x' suffix '.txt'],'results_x.txt');
movefile(['results_fval' suffix '.txt'],'results_fval.txt');
movefile(['results_flux' suffix '.txt'],'results_flux.txt');
movefile(['results_exitflag' suffix '.txt'],'results_exitflag.txt');
movefile(['results_CI' suffix '.txt'],'results_CI.txt');
movefile(['measurements' suffix '.txt'],'measurements.txt');
movefile(['inputSubEMU' suffix '.mat'],'inputSubEMU.mat');
%movefile(['inputSubConfig' suffix '.mat'],'inputSubConfig.mat');
movefile(['error' suffix '.txt'],'error.txt');
movefile(['dee_x_sim' suffix '.m'],'dee_x_sim.m');
movefile(['allBasis_soln' suffix '.txt'],'allBasis_soln.txt');
end
movefile(['MID_solution' suffix '.txt'],'MID_solution.txt');
movefile(['results_mid' suffix '.txt'],'results_mid.txt');
movefile(['results_PE' suffix '.txt'],'results_PE.txt');