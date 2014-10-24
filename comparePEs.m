suffix='Mod2ExpandedHighRaw';

PEFID1=fopen('results_PE.txt','w');
PEFID2=fopen('results_PE.txt','w');

modelFID=fopen(['beckerModel' suffix '.txt']);
line=fgetl(modelFID);
fluxLabels={};
reactionLabels={};
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        fluxLabels{end+1}=words{2};
        reactionLabels{end+1}=words{1};
        
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

line=fgetl(PEFID1);
simFluxes1=[];
fluxes=0;
while(line~=-1)  
    if(sum(regexp(line,'estimated fluxes')))
        fluxes=1;
        line=fgetl(PEFID1);
        continue;
    end
    if(sum(regexp(line,'chi-square cut off')))
        fluxes=0;
    end
    if(fluxes)
        words=strsplit(line,'\t');
        reactionNum=words{1};
        reversibility=beckerEquationsReversibility{str2num(reactionNum(2:end))};
        if(sum(regexp(reactionLabels{str2num(reactionNum)},'Exchange'))==0 && ...
                sum(regexp(reactionLabels{str2num(reactionNum)},'R01'))==0)
            simFluxes1(end+1)=str2num(words{2});
        end
    end
    line=fgetl(PEFID1);
end
fclose(PEFID1);

line=fgetl(PEFID2);
simFluxes2=[];
fluxes=0;
while(line~=-1)  
    if(sum(regexp(line,'estimated fluxes')))
        fluxes=1;
        line=fgetl(PEFID1);
        continue;
    end
    if(sum(regexp(line,'chi-square cut off')))
        fluxes=0;
    end
    if(fluxes)
        words=strsplit(line,'\t');
        reactionNum=words{1};
        reversibility=beckerEquationsReversibility{str2num(reactionNum(2:end))};
        if(sum(regexp(reactionLabels{str2num(reactionNum)},'Exchange'))==0 && ...
                sum(regexp(reactionLabels{str2num(reactionNum)},'R01'))==0)
            simFluxes2(end+1)=str2num(words{2});
        end
    end
    line=fgetl(PEFID2);
end
fclose(PEFID2);