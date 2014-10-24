suffix='1OnlyRedTemp';
modelEquationsToDiagramEquations=containers.Map;
modelEquations={};

%read in model equations, reversibility for each one, and map to diagram
%equations. For Marc, calculate all of the edge names that should be
%created.
modelFID=fopen(['model' suffix '.txt']);
line=fgetl(modelFID);
writeFID2=fopen(['model' suffix 'ForMarc.csv'],'w');
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        
        equation=words{2};
        modelEquations{end+1}=words{1};
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
                fprintf(writeFID2,'%s,%s\n',reactantWords{1},[reactantWords{1} '__' productWords{i}]);
                fprintf(writeFID2,'%s,%s\n',[reactantWords{1} '__' productWords{i}],productWords{i});
            end
        else
            allReactantsString='';
            for i=1:length(reactantWords)
                allReactantsString=[allReactantsString reactantWords{i} '_'];
            end
            allReactantsString=allReactantsString(1:end-1);
            for i=1:length(reactantWords)
                diagramEquations{end+1}=[reactantWords{i} ',' allReactantsString ','];
                fprintf(writeFID2,'%s,%s\n',reactantWords{1},[reactantWords{1} '__' allReactantsString]);
                fprintf(writeFID2,'%s,%s\n',[reactantWords{1} '__' allReactantsString],allReactantsString);
            end
            for i=1:length(productWords)
                diagramEquations{end+1}=[allReactantsString ',' productWords{i} ','];
                fprintf(writeFID2,'%s,%s\n',allReactantsString,[allReactantsString '__' productWords{i}]);
                fprintf(writeFID2,'%s,%s\n',[allReactantsString '__' productWords{i}],productWords{i});
            end
        end
        modelEquationsToDiagramEquations(modelEquations{end})=diagramEquations;
    end
    line=fgetl(modelFID);
end
fclose(modelFID);
fclose(writeFID2);

%read in corresponding results_PE file, map fluxes for each diagramEquation
modelFID=fopen(['results_PE' suffix '.txt']);
writeFID=fopen(['model' suffix '.csv'],'w');
line=fgetl(modelFID);
simFluxes=[];
fluxes=0;
prevwords={};
while(line~=-1)
    %look for data between 'estimated fluxes' and 'chi-square cut off'
    if(sum(regexp(line,'estimated fluxes')))
        fluxes=1;
        line=fgetl(modelFID);
        continue;
    end
    if(sum(regexp(line,'chi-square cut off')))
        fluxes=0;
    end
    
    %parse reactionNum for first word, use to index into
    %modelEquations.
    if(fluxes)
        words=strsplit(line,'\t');
        reactionNum=words{1};
        diagramEquations=modelEquationsToDiagramEquations(modelEquations{str2num(reactionNum(2:end))});
        for i=1:length(diagramEquations)
            fprintf(writeFID,'%s%f\n',diagramEquations{i},str2num(words{2}));
        end
    end
    line=fgetl(modelFID);
end
fclose(modelFID);
fclose(writeFID);

modelID = ['model' suffix];
fluxInFile = ['model' suffix '.csv'];
sbmlOutFile = [modelID '.xml'];
[fluxdata, sources, targets] = C13flux(modelID, fluxInFile,sbmlOutFile);
xmlOutFile = [modelID 'Fluxes.xml'];
fluxdata2XML(fluxdata,xmlOutFile);
jsonOutFile = [modelID 'Fluxes.json'];
fluxdata2JSON(fluxdata,jsonOutFile);