suffix='Mod2ExpandedHighRawAllLock';
beckerEquationsToDiagramEquations=containers.Map;
beckerEquations={};
beckerEquationsReversibility={};

modelFID=fopen(['beckerModel' suffix '.txt']);
line=fgetl(modelFID);
fluxLabels={};
writeFID2=fopen(['beckerModel' suffix 'ForMarc.csv'],'w');
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        fluxLabels{end+1}=words{2};
        
        equation=words{2};
        beckerEquations{end+1}=equation;
        beckerEquationsReversibility{end+1}=words{4};
        if(strcmp(beckerEquationsReversibility{end},'R'))
        else            
            equationWords=strsplit(equation,' ');
            equalsSignIdx=0;
            reactantWords={};
            productWords={};
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
            beckerEquationsToDiagramEquations(equation)=diagramEquations;
        end
    end
    line=fgetl(modelFID);
end
fclose(modelFID);
fclose(writeFID2);

modelFID=fopen(['results_PE' suffix '.txt']);
writeFID=fopen(['beckerModel' suffix '.csv'],'w');
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
    if(fluxes)
        words=strsplit(line,'\t');
        reactionNum=words{1};
        reversibility=beckerEquationsReversibility{str2num(reactionNum(2:end))};
        if(strcmp(reversibility,'F'))
            diagramEquations=beckerEquationsToDiagramEquations(beckerEquations{str2num(reactionNum(2:end))});
            for i=1:length(diagramEquations)
                fprintf(writeFID,'%s%f\n',diagramEquations{i},str2num(words{2}));
            end
        elseif(strcmp(reversibility,'R'))
            diagramEquations=beckerEquationsToDiagramEquations(beckerEquations{str2num(reactionNum(2:end))-1});
            for i=1:length(diagramEquations)
                fprintf(writeFID,'%s%f\n',diagramEquations{i},str2num(prevwords{2})-str2num(words{2}));
            end
        end
        prevwords=words;
    end
    line=fgetl(modelFID);
end
fclose(modelFID);
fclose(writeFID);

modelID = ['beckerModel' suffix];
fluxInFile = ['beckerModel' suffix '.csv'];
sbmlOutFile = [modelID '.xml'];
[fluxdata, sources, targets] = C13flux(modelID, fluxInFile,sbmlOutFile);
xmlOutFile = [modelID 'Fluxes.xml'];
fluxdata2XML(fluxdata,xmlOutFile);
jsonOutFile = [modelID 'Fluxes.json'];
fluxdata2JSON(fluxdata,jsonOutFile);