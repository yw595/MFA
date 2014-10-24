suffix='1OnlyRed';

inputFID=fopen(['MID_solution' suffix '.txt']);
line=fgetl(inputFID);
simMID=[];
while(line~=-1)
    simMID(end+1)=str2num(line);
    line=fgetl(inputFID);
end
fclose(inputFID);

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

KLArray=[];
KLMetabolites={};
currentMetabolite='';
for i=1:length(expMID)
    if(strcmp(currentMetabolite,metabolites{i})~=1)
        currentMetabolite=metabolites{i};
        KLMetabolites{end+1}=currentMetabolite;
        KLArray(end+1)=0;
    end
    KLArray(end)=KLArray(end)+expMID(i)*log2(expMID(i)/simMID(i));
end

figure('Visible','off');
bar(1:length(KLArray),KLArray);
set(gcf,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2.5 length(KLArray) 12]);
set(gca,'XTick',[]);
ylabel('KL Divergence');
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(KLMetabolites)
    t(i)=text(i,y+.02,KLMetabolites{i});
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,['KL' suffix '.png']);