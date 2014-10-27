function graphFluxResultsBatch(outputDir,suffix)

if ~exist(outputDir,'var')
    outputDir = 'outputMaster/batch';
end
if ~exist(suffix,'var')
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

for i=1:40
    inputFID=fopen(['MID_solution' suffix num2str(i) '.txt']);
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
end

simFluxesMatrix1=[];
suffix1='1OnlyRedZeroBGHigh';
for i=1:40
    inputFID=fopen(['MID_solution' suffix num2str(i) '.txt']);
    line=fgetl(inputFID);
    simMID=[];
    while(line~=-1)
        simMID(end+1)=str2num(line);
        line=fgetl(inputFID);
    end
    simMIDMatrix(:,i)=simMID';
    fclose(inputFID);
    
    %read in corresponding results_PE file, map net fluxes, subtracting reverse, for each diagramEquation
    modelFile=[outputDir '/results_PE' suffix1 num2str(i) '.txt'];
    writeFile=[outputDir '/model' suffix1 num2str(i) '.csv'];
    simFluxes=writeFluxesCSV(modelFile,writeFile,modelEquationsToDiagramEquations,modelEquations,modelEquationsReversibility);
    simFluxesMatrix1(:,i)=simFluxes';
end

simFluxesMatrixComb=zeros(size(simFluxesMatrix,1)*2,size(simFluxesMatrix,2));
simFluxesMatrixComb(1:2:2*size(simFluxesMatrix,1)-1,:)=simFluxesMatrix;
simFluxesMatrixComb(2:2:2*size(simFluxesMatrix,1),:)=simFluxesMatrix1;
makeGraph(reactionLabels1,simFluxesMatrixComb','Flux',[], ...
    [0 2 12 8],[], ...
    1,5,[outputDir '/fluxVariabilityCompareGraph' suffix '.png'],'fluxVariabilityCompare');

for i=1:length(reactionLabels1)
    for j=1:length(reactionLabels1)
        simFluxCorr(i,j)=corr(simFluxesMatrix(i,:)',simFluxesMatrix(j,:)');
    end
end

%figure('Visible','off','Renderer','zbuffer');
%HeatMap(simFluxCorr);
%saveas(gcf,['fluxCorrelationGraph' suffix '.png']);

end