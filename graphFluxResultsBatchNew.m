function graphFluxResultsBatchNew(outputDir,suffix)

if ~exist('outputDir','var')
    outputDir = 'outputMaster/batch';
end
if ~exist('suffix','var')
    suffix='v0';
end

%reactionLabels1 contains R name, reactionLabels2 contains equation name
%metabolites contains metabolite names for all isotopomers, isotopomers
%contains m numbers
inputFile=[outputDir '/model' suffix '.txt'];
[measurements errors expMID expSTD metabolites isotopomers reactionLabels1 reactionLabels2]=readModelFile(inputFile);

simMIDMatrix=[];
simFluxesMatrix=[];

modelFile=[outputDir '/model' suffix '.txt'];
writeFile=[outputDir '/model' suffix 'ForMarc.csv'];
[modelEquationsToDiagramEquations modelEquations modelEquationsReversibility]=buildDiagramEquations(modelFile,writeFile);

for i=1:10
    inputFID=fopen([outputDir '/MID_solution' suffix num2str(i) '.txt']);
    line=fgetl(inputFID);
    simMID=[];
    while(line~=-1)
        simMID(end+1)=str2num(line);
        line=fgetl(inputFID);
    end
    simMIDMatrix(:,i)=simMID';
    fclose(inputFID);
    
    %read in corresponding results_PE file, map net fluxes, subtracting reverse, for each diagramEquation
    modelFile=[outputDir '/results_PE' suffix num2str(i) '.txt'];
    writeFile=[outputDir '/model' suffix num2str(i) '.csv'];
    simFluxes=writeFluxesCSV(modelFile,writeFile,modelEquationsToDiagramEquations,modelEquations,modelEquationsReversibility);
    simFluxesMatrix(:,i)=simFluxes';
    
    modelID = ['model' suffix];
    fluxInFile = [outputDir '/' modelID num2str(i) '.csv'];
    sbmlOutFile = [outputDir '/' modelID '.xml'];
    [fluxdata, sources, targets] = C13flux(modelID, fluxInFile,sbmlOutFile);
    xmlOutFile = [outputDir '/' modelID num2str(i) 'Fluxes.xml'];
    fluxdata2XML(fluxdata,xmlOutFile);
    jsonOutFile = [outputDir '/' modelID num2str(i) 'Fluxes.json'];
    fluxdata2JSON(fluxdata,jsonOutFile);
end

%read in corresponding results_PE file, map net fluxes, subtracting reverse, for each diagramEquation
modelFile=[outputDir '/results_PE' suffix '1.txt'];
writeFile=[outputDir '/model' suffix 'Median.csv'];
[simFluxes totalVariability]=writeFluxesCSV(modelFile,writeFile,modelEquationsToDiagramEquations,modelEquations,modelEquationsReversibility,simFluxesMatrix);

disp('Total Variability: ')
disp(totalVariability)

modelID = ['model' suffix];
fluxInFile = [outputDir '/' modelID 'Median.csv'];
sbmlOutFile = [outputDir '/' modelID '.xml'];
[fluxdata, sources, targets] = C13flux(modelID, fluxInFile,sbmlOutFile);
xmlOutFile = [outputDir '/' modelID 'MedianFluxes.xml'];
fluxdata2XML(fluxdata,xmlOutFile);
jsonOutFile = [outputDir '/' modelID 'MedianFluxes.json'];
fluxdata2JSON(fluxdata,jsonOutFile);

makeGraph(reactionLabels1,simFluxesMatrix','Flux',[], ...
    [0 2 12 8],[], ...
    1,5,[outputDir '/fluxVariabilityGraph' suffix '.png'],'fluxVariability');

end