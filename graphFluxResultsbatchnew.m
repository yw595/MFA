suffix='1OnlyRedZeroBGMin1PercentHighAllLock';
inputFID=fopen(['model' suffix '.txt']);

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

simMIDMatrix=[];
simFluxesMatrix=[];

beckerEquationsToDiagramEquations=containers.Map;
beckerEquations={};
beckerEquationsReversibility={};

%read in model equations, reversibility for each one, and map to diagram
%equations. For Marc, calculate all of the edge names that should be
%created.
modelFID=fopen(['model' suffix '.txt']);
line=fgetl(modelFID);
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        
        equation=words{2};
        beckerEquations{end+1}=equation;
        beckerEquationsReversibility{end+1}=words{4};
        %skip all reverse equations, as the FR version should already have
        %been processed for beckerEquations to diagramEquations
        if(strcmp(beckerEquationsReversibility{end},'R'))
        else            
            equationWords=strsplit(equation,' ');
            equalsSignIdx=0;
            reactantWords={};
            productWords={};
            
            %parse equation for equals sign, anything before that has not
            %been seen before in reactants or products respectively and is
            %not a decimal number is added reactant and productWords
            for i=1:length(equationWords)
                if(strcmp(equationWords{i},'='))
                    equalsSignIdx=i;
                elseif(~strcmp(equationWords{i},'+'))
                    if(equalsSignIdx==0)
                        if(sum(strcmp(reactantWords,equationWords{i}))==0 && sum(regexp(equationWords{i},'\.'))==0)
                            reactantWords{end+1}=equationWords{i};
                        end
                    else
                        if(sum(strcmp(productWords,equationWords{i}))==0 && sum(regexp(equationWords{i},'\.'))==0)
                            productWords{end+1}=equationWords{i};
                        end
                    end
                end
            end
            
            %if only one reactant, make separate reactions leading to each
            %product. If multiple reactant, let them all go a node
            %allReactantsString, which then goes to multiple products. All
            %of these diagramEquations are mapped to the beckerEquation.
            %Note that diagramEquations are in reactant,product format, for
            %later csv writing
            diagramEquations={};
            if(length(reactantWords)==1)
                for i=1:length(productWords)
                    diagramEquations{end+1}=[reactantWords{1} ',' productWords{i} ','];
                end
            else
                allReactantsString='';
                for i=1:length(reactantWords)
                    allReactantsString=[allReactantsString reactantWords{i} '_'];
                end
                allReactantsString=allReactantsString(1:end-1);
                for i=1:length(reactantWords)
                    diagramEquations{end+1}=[reactantWords{i} ',' allReactantsString ','];
                end
                for i=1:length(productWords)
                    diagramEquations{end+1}=[allReactantsString ',' productWords{i} ','];
                end
            end
            beckerEquationsToDiagramEquations(equation)=diagramEquations;
        end
    end
    line=fgetl(modelFID);
end
fclose(modelFID);

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
    modelFID=fopen(['results_PE' suffix num2str(i) '.txt']);
    line=fgetl(modelFID);
    simFluxes=[];
    fluxes=0;
    prevwords={};
    while(line~=-1)
        if(sum(regexp(line,'estimated fluxes')))
            fluxes=1;
            line=fgetl(modelFID);
            continue;
        end
        if(sum(regexp(line,'chi-square cut off')))
            fluxes=0;
        end
        
        %parse reactionNum for first word, use to index into
        %beckerEquationsReversibility. If forward, we may simply append flux to
        %all diagramEquations and write to file. If R, use prevwords from previous line to
        %and subtract reverse fluxes, then append and write flux.
        if(fluxes)
            words=strsplit(line,'\t');
            reactionNum=words{1};
            reversibility=beckerEquationsReversibility{str2num(reactionNum(2:end))};
            if(strcmp(reversibility,'F'))
                simFluxes(end+1)=str2num(words{2});
            elseif(strcmp(reversibility,'R'))
                simFluxes(end+1)=str2num(prevwords{2})-str2num(words{2});
            end
            prevwords=words;
        end
        line=fgetl(modelFID);
    end
    fclose(modelFID);
    simFluxesMatrix(:,i)=simFluxes';
end

%read in corresponding results_PE file, map net fluxes, subtracting reverse, for each diagramEquation
modelFID=fopen(['results_PE' suffix '1.txt']);
writeFID=fopen(['modelMean' suffix '.csv'],'w');
line=fgetl(modelFID);
simFluxes=[];
fluxes=0;
prevwords={};
simFluxIdx=1;
totalVariability=0;
while(line~=-1)
    
    if(sum(regexp(line,'estimated fluxes')))
        fluxes=1;
        line=fgetl(modelFID);
        continue;
    end
    if(sum(regexp(line,'chi-square cut off')))
        fluxes=0;
    end
    
    %parse reactionNum for first word, use to index into
    %beckerEquationsReversibility. If forward, we may simply append flux to
    %all diagramEquations and write to file. If R, use prevwords from previous line to
    %and subtract reverse fluxes, then append and write flux.
    if(fluxes)
        words=strsplit(line,'\t');
        reactionNum=words{1};
        reversibility=beckerEquationsReversibility{str2num(reactionNum(2:end))};
        totalVariability=totalVariability+max(simFluxesMatrix(simFluxIdx,:))-min(simFluxesMatrix(simFluxIdx,:));
        if(strcmp(reversibility,'F'))
            diagramEquations=beckerEquationsToDiagramEquations(beckerEquations{str2num(reactionNum(2:end))});
            for i=1:length(diagramEquations)
                fprintf(writeFID,'%s%f\n',diagramEquations{i},median(simFluxesMatrix(simFluxIdx,:)));
            end
            simFluxIdx=simFluxIdx+1;
        elseif(strcmp(reversibility,'R'))
            diagramEquations=beckerEquationsToDiagramEquations(beckerEquations{str2num(reactionNum(2:end))-1});
            for i=1:length(diagramEquations)
                fprintf(writeFID,'%s%f\n',diagramEquations{i},median(simFluxesMatrix(simFluxIdx,:)));
            end
            simFluxIdx=simFluxIdx+1;
        end
        prevwords=words;
    end
    line=fgetl(modelFID);
end
fclose(modelFID);
fclose(writeFID);

totalVariability

modelID = ['modelMean' suffix];
fluxInFile = ['modelMean' suffix '.csv'];
sbmlOutFile = [modelID '.xml'];
[fluxdata, sources, targets] = C13flux(modelID, fluxInFile,sbmlOutFile);
xmlOutFile = [modelID 'Fluxes.xml'];
fluxdata2XML(fluxdata,xmlOutFile);
jsonOutFile = [modelID 'Fluxes.json'];
fluxdata2JSON(fluxdata,jsonOutFile);