suffix='Mod2ExpandedHighRawAllLock';
modelFID=fopen(['beckerModel' suffix '.txt']);
line=fgetl(modelFID);
measurements=0;
errors=0;
expMID=[];
expSTD=[];
metabolites={};
isotopomers={};
fluxLabels={};
reactionLabels={};
currentMetabolite='';
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        fluxLabels{end+1}=words{2};
        reactionLabels{end+1}=words{1};
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
        if(~strcmp(words{1},'##') && ~strcmp(words{1},''))
            expMID(end+1)=str2num(words{2});
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
    line=fgetl(modelFID);
end
fclose(modelFID);

modelFID=fopen('MID_solution.txt');
line=fgetl(modelFID);
simMID=[];
while(line~=-1)
    simMID(end+1)=str2num(line);
    line=fgetl(modelFID);
end
fclose(modelFID);

modelFID=fopen('results_PE.txt');
line=fgetl(modelFID);
simFluxes=[];
fluxes=0;
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
        %if(length(words)==6)
        simFluxes(end+1)=str2num(words{2});
        %end
    end
    line=fgetl(modelFID);
end
fclose(modelFID);

figure('Visible','off','Renderer','zbuffer');
bar(1:length(simFluxes),simFluxes,1);
set(gcr,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2.5 .32*length(simFluxes) 6]);
set(gca,'XTick',[]);
set(gca,'units','centimeters','position',[1.25 5.5 .64*length(simFluxes) 6]);
ylabel('Flux');
%ylim([0 10^-9]);
ylim('manual')
set(gca,'YLim',[0 .0000001])
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(fluxLabels)
   t(i)=text(i,y,fluxLabels{i},'fontSize',5,'Interpreter','default');
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['fluxGraphZoom' suffix '.png']);

figure('Visible','off','Renderer','zbuffer');
bar(1:length(simFluxes),simFluxes,1);
set(gcr,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2.5 .32*length(simFluxes) 6]);
set(gca,'XTick',[]);
set(gca,'units','centimeters','position',[2.25 3.25 .64*length(simFluxes) 10]);
ylabel('Flux');
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(fluxLabels)
   t(i)=text(i,y+.02,fluxLabels{i},'fontSize',5,'Interpreter','default');
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['fluxGraph' suffix '.png']);

exchangeFluxes=[];
exchangeLabels={};
for i=1:length(reactionLabels)
    if(strcmp(reactionLabels{i},'R01'))
        exchangeLabels{end+1}=reactionLabels{i};
        exchangeFluxes(end+1)=simFluxes(i);
    end
    if(sum(regexp(reactionLabels{i},'Exchange'))~=0)
        if(sum(regexp(reactionLabels{i},'FR$'))~=0)
            ithReactionLabel=reactionLabels{i};
            exchangeLabels{end+1}=ithReactionLabel(1:end-2);
            exchangeFluxes(end+1)=simFluxes(i);
        else
            exchangeFluxes(end)=exchangeFluxes(end)-simFluxes(i);
        end
    end
end
figure('Visible','off','Renderer','zbuffer');
bar(1:length(exchangeFluxes),exchangeFluxes,1);
set(gcr,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2.5 .32*length(exchangeFluxes) 6]);
set(gca,'XTick',[]);
set(gca,'units','centimeters','position',[2.25 3.25 .64*length(exchangeFluxes) 10]);
ylabel('Flux');
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(exchangeLabels)
   t(i)=text(i,y+.02,exchangeLabels{i},'fontSize',5,'Interpreter','default');
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['fluxGraphExchange' suffix '.png']);

figure('Visible','off');
bar(1:length(expMID),[expMID' simMID'],2);
set(gcf,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2.5 .16*length(expMID) 12]);
set(gca,'XTick',[]);
ylabel('MID Proportion');
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(metabolites)
    t(i)=text(i,y+.02,[metabolites{i} ' ' isotopomers{i}]);
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['MIDGraph' suffix '.png']);

[junk sortIdxs]=sort(abs((expMID-simMID)./expSTD));
selectExpSTD=expSTD(sortIdxs);selectExpSTD=selectExpSTD(end-9:end);
selectExpMID=expMID(sortIdxs);selectExpMID=selectExpMID(end-9:end);
selectSimMID=simMID(sortIdxs);selectSimMID=selectSimMID(end-9:end);
selectMetabolites=metabolites(sortIdxs);selectMetabolites=selectMetabolites(end-9:end);
selectIsotopomers=isotopomers(sortIdxs);selectIsotopomers=selectIsotopomers(end-9:end);
combMID=[];combMID(1:2:19)=selectExpMID;combMID(2:2:20)=selectSimMID;

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
set(gcf,'PaperPosition',[.25 2 .50*length(combMID) 12]);
set(gca,'XTick',[]);
ylabel('MID Proportion');
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(selectMetabolites)
    t(i)=text(2*i-1,y,[selectMetabolites{i} ' ' selectIsotopomers{i}]);
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['MIDGraphSelect' suffix '.png']);

figure('Visible','off');
hold on;
bar((selectExpMID-selectSimMID)./selectExpSTD,'g');
set(gcf,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2 .50*length(combMID) 12]);
set(gca,'XTick',[]);
ylabel('MID Proportion');
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(selectMetabolites)
    t(i)=text(i,y,[selectMetabolites{i} ' ' selectIsotopomers{i}]);
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['MIDErrorSelect' suffix '.png']);

movefile('results_PE.txt',['results_PE' suffix '.txt']);
movefile('results_mid.txt',['results_mid' suffix '.txt']);
movefile('MID_solution.txt',['MID_solution' suffix '.txt']);
