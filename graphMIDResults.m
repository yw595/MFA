suffix='v0';
inputFID=fopen(['outputMaster/model' suffix '.txt']);

%reactionLabels1 contains R name, reactionLabels2 contains equation name
%metabolites contains metabolite names for all isotopomers, isotopomers
%contains m numbers
line=fgetl(inputFID);
measurements=0;
errors=0;
expMID=[];
expSTD=[];
metabolites={};
isotopomers={};
reactionLabels1={};
reactionLabels2={};
currentMetabolite='';
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        reactionLabels1{end+1}=words{1};
        reactionLabels2{end+1}=words{2};
    end
    if(sum(regexp(line,'measurements'))~=0)
        measurements=1;
    end
    if(sum(regexp(line,'error'))~=0)
        measurements=0;
        errors=1;
    end
    
    if(measurements)
        words=strsplit(line,'\t');
        %check if line is actual measurements label, check if line is empty
        %since always '' at end of strsplit array
        if(~strcmp(words{1},'##') && ~strcmp(words{1},''))
            expMID(end+1)=str2num(words{2});
            
            %if no metabolite name so length==4, add to metabolites and
            %isotopomers, else also change current Metabolite
            if(length(words)==4)
                metabolites{end+1}=currentMetabolite;
                isotopomers{end+1}=words{3};
            else
                currentMetabolite=words{3};
                metabolites{end+1}=currentMetabolite;
                isotopomers{end+1}=words{4};
            end
        end
    end
    
    if(errors)
        words=strsplit(line,'\t');
        if(~strcmp(words{1},'##') && ~strcmp(words{1},''))
            expSTD(end+1)=str2num(words{2});
        end
    end
    line=fgetl(inputFID);
end
fclose(inputFID);

%get simulation MID distribution
inputFID=fopen(['outputMaster/MID_solution' suffix '.txt']);
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
inputFID=fopen(['outputMaster/results_PE' suffix '.txt']);
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
    1,5,['outputMaster/fluxGraphZoom' suffix '.png'],'fluxGraphZoom');

makeGraph(reactionLabels1,simFluxes,'Flux',[], ...
    [.25 2.5 .32*length(simFluxes) 6],[2.25 3.25 .64*length(simFluxes) 10], ...
    1,5,['outputMaster/fluxGraph' suffix '.png'],'fluxGraph');

makeGraph(exchangeLabels,exchangeFluxes,'Flux',[], ...
    [.25 2.5 .32*length(exchangeFluxes) 6],[2.25 3.25 .64*length(exchangeFluxes) 10], ...
    1,5,['outputMaster/fluxGraphExchange' suffix '.png'],'fluxGraphExchange');

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
    1,25,['outputMaster/MIDGraph' suffix '.png'],'MIDGraph');

for i=1:length(selectMetabolites)
    selectMetabolites{i}=[selectMetabolites{i} ' ' selectIsotopomers{i}];
end

makeGraph(selectMetabolites,selectCombMID,'MID Proportion',[], ...
    [.25 2 .50*length(selectCombMID) 12],[], ...
    1,25,['outputMaster/MIDGraphSelect' suffix '.png'],'MIDGraphSelect');

makeGraph(selectMetabolites,(selectExpMID-selectSimMID)./selectExpSTD,'MID Proportion',[], ...
    [.25 2 .50*length(selectCombMID) 12],[], ...
    1,25,['outputMaster/MIDErrorSelect' suffix '.png'],'MIDErrorSelect');