function [simFluxes totalVariability]=writeFluxesCSV(inputFile,outputFile,modelEquationsToDiagramEquations,modelEquations,modelEquationsReversibility,simFluxesMatrix,writeMedian,writeVariability)

medianOrVariability=0;
if exist('simFluxesMatrix','var')
    medianOrVariability=1;
end

%read in corresponding results_PE file, map net fluxes, subtracting reverse, for each diagramEquation
modelFID=fopen(inputFile);
writeFID=fopen(outputFile,'w');
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
    %modelEquationsReversibility. If forward, we may simply append flux to
    %all diagramEquations and write to file. If R, use prevwords from previous line to
    %and subtract reverse fluxes, then append and write flux.
    if(fluxes)
        words=strsplit(line,'\t');
        reactionNum=words{1};
        reversibility=modelEquationsReversibility{str2num(reactionNum(2:end))};
        if(medianOrVariability)
            totalVariability=totalVariability+max(simFluxesMatrix(simFluxIdx,:))-min(simFluxesMatrix(simFluxIdx,:));
        end
        if(strcmp(reversibility,'F'))
            diagramEquations=modelEquationsToDiagramEquations(modelEquations{str2num(reactionNum(2:end))});
            simFluxes(end+1)=str2num(words{2});
            for i=1:length(diagramEquations)
                if(medianOrVariability)
                    if(writeMedian)
                        median(simFluxesMatrix(simFluxIdx,:))
                        fprintf(writeFID,'%s%f\n',diagramEquations{i},median(simFluxesMatrix(simFluxIdx,:)));
                    elseif(writeVariability)
                        fprintf(writeFID,'%s%f\n',diagramEquations{i},max(simFluxesMatrix(simFluxIdx,:))-min(simFluxesMatrix(simFluxIdx,:)));
                    end
                else
                    fprintf(writeFID,'%s%f\n',diagramEquations{i},str2num(words{2}));
                end
            end
            simFluxIdx=simFluxIdx+1;
        elseif(strcmp(reversibility,'R'))
            diagramEquations=modelEquationsToDiagramEquations(modelEquations{str2num(reactionNum(2:end))-1});
            simFluxes(end+1)=str2num(prevwords{2})-str2num(words{2});
            for i=1:length(diagramEquations)
                if(medianOrVariability)
                    if(writeMedian)
                        fprintf(writeFID,'%s%f\n',diagramEquations{i},median(simFluxesMatrix(simFluxIdx,:)));
                    elseif(writeVariability)
                        fprintf(writeFID,'%s%f\n',diagramEquations{i},max(simFluxesMatrix(simFluxIdx,:))-min(simFluxesMatrix(simFluxIdx,:)));
                    end
                else
                    fprintf(writeFID,'%s%f\n',diagramEquations{i},str2num(prevwords{2})-str2num(words{2}));
                end
            end
            simFluxIdx=simFluxIdx+1;
        end
        prevwords=words;
    end
    line=fgetl(modelFID);
end
fclose(modelFID);
fclose(writeFID);

end