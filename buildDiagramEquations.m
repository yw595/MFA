function [modelEquationsToDiagramEquations modelEquations modelEquationsReversibility]=buildDiagramEquations(inputFile,outputFile)

modelEquationsToDiagramEquations=containers.Map;
modelEquations={};
modelEquationsReversibility={};

modelFID=fopen(inputFile);
line=fgetl(modelFID);
writeFID2=fopen(outputFile,'w');
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        
        equation=words{2};
        modelEquations{end+1}=equation;
        modelEquationsReversibility{end+1}=words{4};
        %skip all reverse equations, as the FR version should already have
        %been processed for modelEquations to diagramEquations
        if(strcmp(modelEquationsReversibility{end},'R'))
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
            modelEquationsToDiagramEquations(equation)=diagramEquations;
        end
    end
    line=fgetl(modelFID);
end
fclose(modelFID);
fclose(writeFID2);

end