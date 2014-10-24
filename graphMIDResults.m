suffix='Mod2ExpandedBasicLock';
modelFID=fopen(['beckerModel' suffix '.txt']);
line=fgetl(modelFID);
measurements=0;
expMID=[];
labels={};
fluxLabels={};
while(line~=-1)
    if(sum(regexp(line,'^R'))~=0)
        words=strsplit(line,'\t');
        fluxLabels{end+1}=words{2};
    end
    if(sum(regexp(line,'measurements'))~=0)
        measurements=1;
    end
    if(sum(regexp(line,'error'))~=0)
        measurements=0;
    end
    if(measurements)
        words=strsplit(line,'\t');
        if(~strcmp(words{1},'##') && ~strcmp(words{1},''))
            expMID(end+1)=str2num(words{2});
            if(length(words)==4)
                labels{end+1}=words{3};
            else
                labels{end+1}=[words{3} ' ' words{4}];
            end
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

if(0)
modelFID=fopen('results_PELowChanged.txt');
line=fgetl(modelFID);
expLowFluxes=[];
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
        expLowFluxes(end+1)=str2num(words{2});
        %end
    end
    line=fgetl(modelFID);
end

modelFID=fopen('results_PEHighChanged.txt');
line=fgetl(modelFID);
expHighFluxes=[];
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
            expHighFluxes(end+1)=str2num(words{2});
        %end
    end
    line=fgetl(modelFID);
end

figure('Visible','off');
bar(1:length(expHighFluxes),expHighFluxes,1);
set(gcr,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2.5 .32*length(expHighFluxes) 6]);
set(gca,'XTick',[]);
set(gca,'units','centimeters','position',[1.25 5.5 .64*length(expHighFluxes) 6]);
ylabel('Flux');
ylim([-300 300]);
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(fluxLabels)
   t(i)=text(i,y+.02,fluxLabels{i},'fontSize',5);
end
set(t,'Rotation',90,'HorizontalAlignment','right');
%saveas(gcf,['fluxGraphLow' suffix '.png']);
end

modelFID=fopen('results_PE.txt');
line=fgetl(modelFID);
expFluxes=[];
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
        expFluxes(end+1)=str2num(words{2});
        %end
    end
    line=fgetl(modelFID);
end
fclose(modelFID);

figure('Visible','off','Renderer','zbuffer');
bar(1:length(expFluxes),expFluxes,1);
set(gcr,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2.5 .32*length(expFluxes) 6]);
set(gca,'XTick',[]);
set(gca,'units','centimeters','position',[1.25 5.5 .64*length(expFluxes) 6]);
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
bar(1:length(expFluxes),expFluxes,1);
set(gcr,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2.5 .32*length(expFluxes) 6]);
set(gca,'XTick',[]);
set(gca,'units','centimeters','position',[2.25 3.25 .64*length(expFluxes) 10]);
ylabel('Flux');
%ylim([0 10^-9]);
%ylim('manual')
%set(gca,'YLim',[0 .0000001])
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(fluxLabels)
   t(i)=text(i,y+.02,fluxLabels{i},'fontSize',5,'Interpreter','default');
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['fluxGraph' suffix '.png']);

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
for i=1:length(labels)
    t(i)=text(i,y+.02,labels{i});
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['MIDGraph' suffix '.png']);

movefile('results_PE.txt',['results_PE' suffix '.txt']);
movefile('results_mid.txt',['results_mid' suffix '.txt']);
movefile('MID_solution.txt',['MID_solution' suffix '.txt']);
