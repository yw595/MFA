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
%basisIdxs=[10 12 14 16 18 28 3 30 32 41 43 45 47 49 5 8 26 39 6 24 33 36 2 11];
%basisIdxs=sort(basisIdxs);
reactionLabels2{basisIdxs};
%basisFlux=[0 0 0 50 0 0 25 0 25 0 0 0 10 10 30 30 30 30 100 100 100 0 20 20 20 0 0 20 30 100 ...
%    30 30 30 50 50 30 10 50 100 10];
basisFlux=simFluxes(basisIdxs);
for i=1:length(basisIdxs)
    if(abs(basisFlux(i))<1)
    %if(strcmp(reversibility{basisIdxs(i)},'R') || strcmp(reversibility{basisIdxs(i)},'FR'))
        basisFlux(i)=basisFlux(i)*100/(1-abs(basisFlux(i)));
    end
end
%basisFlux(end)=basisFlux(end)*100/(1-abs(basisFlux(end)));basisFlux(end-1)= ...
%    basisFlux(end-1)*100/(1-abs(basisFlux(end-1)));
%basisFlux(end-1)=68;
%basisFlux(end)=26.8;
simMID=mdvGenerator(fluxGenerator(basisFlux'));
combMID=[];combMID(1:2:(2*length(expMID)-1))=expMID;combMID(2:2:(2*length(expMID)))=simMID;

figure('Visible','off');
hold on;
for i=1:length(combMID)
    if (rem(i,2)==1)
        bar(i,combMID(i),'r');
    else
        bar(i,combMID(i),'b');
    end
end
set(gcf,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2 .5*length(expMID) 12]);
set(gca,'XTick',[]);
ylabel('MID Proportion');
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(metabolites)
    t(i)=text(2*i-1,y+.02,[metabolites{i} ' ' isotopomers{i}]);
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['MIDGraphTask8' suffix '.png']);

figure('Visible','off');
[a1 a2]=mdvGenerator(fluxGenerator(basisFlux'));
bar3(a2,'blue');
saveas(gcf,'testbar3analytical.png');

originalSimMID=simMID;
MIDChangeMatrix=[];
for i=1:length(basisFlux)
    changeBasisFlux=basisFlux;
    changeBasisFlux(i)=1.1*changeBasisFlux(i);
    changeSimMID=mdvGenerator(fluxGenerator(changeBasisFlux'));
    MIDChangeMatrix(i,:)=changeSimMID-originalSimMID;
end

figure('Visible','off');
bar3(MIDChangeMatrix,'blue');
set(gcf,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[0 0 .2*size(MIDChangeMatrix,2) .5*size(MIDChangeMatrix,1)]);
ylim([1 length(reactionLabels1(basisIdxs))]);
set(gca,'YTickLabel',reactionLabels1(basisIdxs));
combinedNames={};
for i=1:length(metabolites)
    combinedNames{i}=[metabolites{i} isotopomers{i}];
end
xlim([1 length(combinedNames)]);
set(gca,'XTickLabel',combinedNames);
zlim([-10 10]);
saveas(gcf,'testbar3.png');