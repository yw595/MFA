function graphMIDResults(outputDir,suffix)

if ~exist(outputDir,'var')
    outputDir = 'outputMaster';
end
if ~exist(suffix,'var')
    suffix='v0';
end

%reactionLabels1 contains R name, reactionLabels2 contains equation name
%metabolites contains metabolite names for all isotopomers, isotopomers
%contains m numbers
inputFile=[outputDir '/model' suffix '.txt'];
[measurements errors expMID expSTD metabolites isotopomers reactionLabels1 reactionLabels2]=readModelFile(inputFile);

%get simulation MID distribution
inputFID=fopen([outputDir '/MID_solution' suffix '.txt']);
line=fgetl(inputFID);
simMID=[];
while(line~=-1)
    simMID(end+1)=str2num(line);
    line=fgetl(inputFID);
end
fclose(inputFID);

%interleave experimental and simulated in combMID
combMID=[];combMID(1:2:(2*length(expMID)-1))=expMID;combMID(2:2:(2*length(expMID)))=simMID;

%get simulated flux distribution
inputFID=fopen([outputDir '/results_PE' suffix '.txt']);
line=fgetl(inputFID);
simFluxes=[];
fluxes=0;
while(line~=-1)
    if(sum(regexp(line,'estimated fluxes')))
        fluxes=1;
        line=fgetl(inputFID);
        continue;
    end
    if(sum(regexp(line,'chi-square cut off')))
        fluxes=0;
    end
    if(fluxes)
        words=strsplit(line,'\t');
        simFluxes(end+1)=str2num(words{2});
    end
    line=fgetl(inputFID);
end
fclose(inputFID);

%select labels and fluxes for exchange reactions
exchangeFluxes=[];
exchangeLabels={};
for i=1:length(reactionLabels1)
    if(sum(regexp(reactionLabels1{i},'Exchange'))~=0)
        %if there is an FR and R pair, subtract the flux for the reverse
        %from the forward, else just add the exchange label and flux
        if(sum(regexp(reactionLabels1{i},'FR$'))~=0)
            ithReactionLabel=reactionLabels1{i};
            exchangeLabels{end+1}=ithReactionLabel(1:end-2);
            exchangeFluxes(end+1)=simFluxes(i);
        elseif(sum(regexp(reactionLabels1{i},'R$'))~=0)
            exchangeFluxes(end)=exchangeFluxes(end)-simFluxes(i);
        else
            ithReactionLabel=reactionLabels1{i};
            exchangeLabels{end+1}=ithReactionLabel(1:end-2);
            exchangeFluxes(end+1)=simFluxes(i);
        end
    end
end

%select the top 10 of everything based on experimental deviation divided by
%experimental error, interleave experimental and simulated in selectCombMID
[junk sortIdxs]=sort(abs((expMID-simMID)./expSTD));
selectExpSTD=expSTD(sortIdxs);selectExpSTD=selectExpSTD(end-9:end);
selectExpMID=expMID(sortIdxs);selectExpMID=selectExpMID(end-9:end);
selectSimMID=simMID(sortIdxs);selectSimMID=selectSimMID(end-9:end);
selectMetabolites=metabolites(sortIdxs);selectMetabolites=selectMetabolites(end-9:end);
selectIsotopomers=isotopomers(sortIdxs);selectIsotopomers=selectIsotopomers(end-9:end);
selectCombMID=[];selectCombMID(1:2:19)=selectExpMID;selectCombMID(2:2:20)=selectSimMID;

makeGraph(reactionLabels1,simFluxes,'Flux',[0 .0000001], ...
    [.25 2.5 .32*length(simFluxes) 6],[1.25 5.5 .64*length(simFluxes) 6], ...
    1,5,[outputDir '/fluxGraphZoom' suffix '.png'],'fluxGraphZoom');

makeGraph(reactionLabels1,simFluxes,'Flux',[], ...
    [.25 2.5 .32*length(simFluxes) 6],[2.25 3.25 .64*length(simFluxes) 10], ...
    1,5,[outputDir '/fluxGraph' suffix '.png'],'fluxGraph');

makeGraph(exchangeLabels,exchangeFluxes,'Flux',[], ...
    [.25 2.5 .32*length(exchangeFluxes) 6],[2.25 3.25 .64*length(exchangeFluxes) 10], ...
    1,5,[outputDir '/fluxGraphExchange' suffix '.png'],'fluxGraphExchange');

shortenedMetabolites={};
for i=1:length(metabolites)
    shortenedMetabolite=metabolites{i};
    shortenedMetabolite=shortenedMetabolite(1:regexp(shortenedMetabolite,'#')-1);
    if(~strcmp(isotopomers{i},'m'))
        shortenedMetabolite='';
    end
    shortenedMetabolites{i}=shortenedMetabolite;
end

makeGraph(shortenedMetabolites,combMID,'MID Proportion',[], ...
    [0 0 .3*length(expMID) 20],[], ...
    1,25,[outputDir '/MIDGraph' suffix '.png'],'MIDGraph');

for i=1:length(selectMetabolites)
    selectMetabolites{i}=[selectMetabolites{i} ' ' selectIsotopomers{i}];
end

makeGraph(selectMetabolites,selectCombMID,'MID Proportion',[], ...
    [.25 2 .50*length(selectCombMID) 12],[], ...
    1,25,[outputDir '/MIDGraphSelect' suffix '.png'],'MIDGraphSelect');

makeGraph(selectMetabolites,(selectExpMID-selectSimMID)./selectExpSTD,'MID Proportion',[], ...
    [.25 2 .50*length(selectCombMID) 12],[], ...
    1,25,[outputDir '/MIDErrorSelect' suffix '.png'],'MIDErrorSelect');
end