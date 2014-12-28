function fluxNetDiagram(outputDir,suffix)

if ~exist('outputDir','var')
    outputDir = 'outputMaster';
end
if ~exist('suffix','var')
    suffix='v0';
end

%read in model equations, reversibility for each one, and map to diagram
%equations. For Marc, calculate all of the edge names that should be
%created.
modelFile=[outputDir '/model' suffix '.txt'];
writeFile=[outputDir '/model' suffix 'ForMarc.csv'];
[modelEquationsToDiagramEquations modelEquations modelEquationsReversibility]=buildDiagramEquations(modelFile,writeFile);

%read in corresponding results_PE file, map net fluxes, subtracting reverse, for each diagramEquation
modelFile=[outputDir '/results_PE' suffix '.txt'];
writeFile=[outputDir '/model' suffix '.csv'];
writeFluxesCSV(modelFile,writeFile,modelEquationsToDiagramEquations,modelEquations,modelEquationsReversibility);

%This code is modeled on C13_example.m under examples/c13_flux in CyFluxViz
modelID = ['model' suffix];
fluxInFile = [outputDir '/' modelID '.csv'];
sbmlOutFile = [outputDir '/' modelID '.xml'];
[fluxdata, sources, targets] = C13flux(modelID, fluxInFile,sbmlOutFile);
xmlOutFile = [outputDir '/' modelID 'Fluxes.xml'];
fluxdata2XML(fluxdata,xmlOutFile);
jsonOutFile = [outputDir '/' modelID 'Fluxes.json'];
fluxdata2JSON(fluxdata,jsonOutFile);
end