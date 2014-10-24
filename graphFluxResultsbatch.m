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

modelFID=fopen(['model' suffix '.txt']);
line=fgetl(modelFID);
beckerEquations={};
beckerEquationsReversibility={};
simFluxLabels={};
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        equation=words{2};
        beckerEquations{end+1}=equation;
        beckerEquationsReversibility{end+1}=words{4};
        if(strcmp(words{4},'FR') || strcmp(words{4},'F'))
            simFluxLabels{end+1}=words{1};
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

simFluxesMatrix1=[];
suffix1='1OnlyRedZeroBGHigh';
for i=1:40
    
    %read in corresponding results_PE file, map net fluxes, subtracting reverse, for each diagramEquation
    modelFID=fopen(['results_PE' suffix1 num2str(i) '.txt']);
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
    simFluxesMatrix1(:,i)=simFluxes';
end

simFluxesMatrixComb=zeros(size(simFluxesMatrix,1)*2,size(simFluxesMatrix,2));
simFluxesMatrixComb(1:2:2*size(simFluxesMatrix,1)-1,:)=simFluxesMatrix;
simFluxesMatrixComb(2:2:2*size(simFluxesMatrix,1),:)=simFluxesMatrix1;
figure('Visible','off','Renderer','zbuffer');
hold on;
boxplot(simFluxesMatrixComb','whisker',1/eps,'colors','gr','boxstyle','filled');
set(gcr,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[0 2 12 8]);
set(gca,'XTick',[]);
%set(gca,'units','centimeters','position',[2.25 3.25 .64*size(simFluxesMatrix,2) 10]);
set(gca,'XTickLabel',[]);
ylabel('Flux');
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(simFluxLabels)
    t(i)=text(2*i-1,y+.01,simFluxLabels{i},'fontSize',5,'Interpreter','default');
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['fluxVariabilityGraph' suffix suffix1 '.png']);

for i=1:length(simFluxLabels)
    for j=1:length(simFluxLabels)
        simFluxCorr(i,j)=corr(simFluxesMatrix(i,:)',simFluxesMatrix(j,:)');
    end
end

%figure('Visible','off','Renderer','zbuffer');
%HeatMap(simFluxCorr);
%saveas(gcf,['fluxCorrelationGraph' suffix '.png']);