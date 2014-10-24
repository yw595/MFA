suffix='1OnlyRedZeroBGMin1PercentHigh';
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
reversibility={};
heatMapLabels={};
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        reactionLabels1{end+1}=words{1};
        reactionLabels2{end+1}=words{2};
        reversibility{end+1}=words{4};
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
                heatMapLabels{end+1}='';
                metabolites{end+1}=currentMetabolite;
                isotopomers{end+1}=words{3};
            else
                currentMetabolite=words{3};
                heatMapLabels{end+1}=words{3};
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

averageJacobian=[];
inputFID=fopen(['results_PE' suffix '.txt']);
line=fgetl(inputFID);
simFluxes=[];
fluxes=0;
while(line~=-1)
    if(sum(regexp(line,'best free fluxes')))
        fluxes=1;
        line=fgetl(inputFID);
        continue;
    end
    if(sum(regexp(line,'fval')))
        fluxes=0;
    end
    if(fluxes)
        words=strsplit(line,'\t');
        rxnNum=words{1};
        meanAndStd=words{2};
        meanFlux=meanAndStd(1:regexp(meanAndStd,'(')-2);
        simFluxes(str2num(rxnNum(2:end)))=str2num(meanFlux);
    end
    line=fgetl(inputFID);
end
fclose(inputFID);

basisIdxs=[10 12 14 15 18 20 21 23 25 28 3 30 33 35 37 39 41 43 44 46 5 58 ...
    60 62 64 67 8 51 59 31 6 49 50 52 55 68 73 2 7 11];
%basisIdxs=[10 12 14 16 18 20 22 24 26 28 3 30 33 35 37 39 41 43 45 47 5 58 ...
%    61 63 65 67 8 51 59 6 31 49 50 52 55 68 73 2 7 11];
basisFlux=simFluxes(basisIdxs);
for i=1:length(basisIdxs)
    if(abs(basisFlux(i))<1)
        basisFlux(i)=basisFlux(i)*100/(1-abs(basisFlux(i)));
    end
end

[a1 a2]=mdvGenerator(fluxGenerator(basisFlux'));

figure('Visible','off')
HeatMap(a2,'ColumnLabels',reactionLabels1(basisIdxs),'RowLabels',heatMapLabels)
saveas(gcf,['averageJacobian' suffix '.png']);