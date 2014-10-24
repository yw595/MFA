suffixes={'1OnlyRedZeroBGLow', ...
    '1OnlyRedZeroBGMin1PercentLow','1OnlyRedZeroBGHigh','1OnlyRedZeroBGMin1PercentHigh'};
KLArrayAll=[];
KLMetabolitesAll={};
for z=1:length(suffixes)
    suffix=suffixes{z};
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
    
    for k=1:40
        inputFID=fopen(['MID_solution' suffix num2str(k) '.txt']);
        line=fgetl(inputFID);
        simMID=[];
        while(line~=-1)
            simMID(end+1)=str2num(line);
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
            %if(expMID(i)>0)
            %    KLArray(end)=KLArray(end)+expMID(i)*log2(expMID(i)/simMID(i));
            if(~(k==34 && z==3))
                KLArray(end)=KLArray(end)+abs(expMID(i)-simMID(i));
                if(isnan(KLArray(end)))
                    i
                    k
                    z
                end
            end
            %end
        end
        
        if(length(KLMetabolitesAll)==0)
            first=1;
        end
        for i=1:length(KLMetabolites)
            if(first)
                KLMetabolitesAll{end+1}=KLMetabolites{i};
                KLArrayAll(end+1,z)=KLArray(i);
            else
                if(size(KLArrayAll,2)<z)
                    KLArrayAll(:,z)=zeros(size(KLArrayAll,1),1);
                end
                if(strcmp(KLMetabolites{i},KLMetabolitesAll{i}))
                    KLArrayAll(i,z)=KLArrayAll(i,z)+KLArray(i);
                else
                    KLMetabolitesAll((i+1):(end+1))=KLMetabolitesAll(i:end);
                    KLMetabolitesAll{i}=KLMetabolites{i};
                    KLArrayAll((i+1):(end+1),:)=KLArrayAll(i:end,:);
                    KLArrayAll(i,:)=zeros(1,z);
                    KLArrayAll(i,z)=KLArray(i);
                end
            end
        end
        if(first==1)
            first=0;
        end
    end
end

KLArrayAll=KLArrayAll/40;

KLArrayAllComb=[];
for i=1:size(KLArrayAll,1)
    for j=1:size(KLArrayAll,2)
        KLArrayAllComb(end+1)=KLArrayAll(i,j);
    end
end

figure('Visible','off');
hold on
xIndex=1;
for i=1:length(KLArrayAllComb)
if(rem(i,4)==1)
    bar(xIndex,KLArrayAllComb(i),'r');
    xIndex=xIndex+1;
elseif(rem(i,4)==2)
    bar(xIndex,KLArrayAllComb(i),'g');
    xIndex=xIndex+1;
end
end
set(gca,'FontSize',10)
legend('Mode 1','Mode 2')
set(gcf,'Units','centimeters');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperPosition',[0 0 18 12]);
set(gca,'XTick',[]);
ylabel('Total Difference in Distribution','FontSize',10);
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
writeFID1=fopen('diffDistForMarcLow.txt','w');
for i=1:length(KLMetabolitesAll)
    t(i)=text(2*i-1,y+.02,KLMetabolitesAll{i});
    shortenedMetabolite=KLMetabolites{i};
    shortenedMetabolite=shortenedMetabolite(1:regexp(shortenedMetabolite,'#')-1);
    fprintf(writeFID1,'%s\t%f\t%f\n',shortenedMetabolite,KLArrayAllComb(i*4-3),KLArrayAllComb(i*4-2));
end
fclose(writeFID1);
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,'KLCombinedLow.png');

figure('Visible','off');
hold on
xIndex=1;
for i=1:length(KLArrayAllComb)
if(rem(i,4)==3)
    bar(xIndex,KLArrayAllComb(i),'r');
    xIndex=xIndex+1;
elseif(rem(i,4)==0)
    bar(xIndex,KLArrayAllComb(i),'g');
    xIndex=xIndex+1;
end
end
set(gca,'FontSize',10)
legend('Mode 1','Mode 2')
set(gcf,'Units','centimeters');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperPosition',[0 0 18 12]);
set(gca,'XTick',[]);
ylabel('Total Difference in Distribution','FontSize',10);
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
writeFID2=fopen('diffDistForMarcHigh.txt','w');
for i=1:length(KLMetabolitesAll)
    t(i)=text(2*i-1,y+.02,KLMetabolitesAll{i});
    shortenedMetabolite=KLMetabolites{i};
    shortenedMetabolite=shortenedMetabolite(1:regexp(shortenedMetabolite,'#')-1);
    fprintf(writeFID2,'%s\t%f\t%f\n',shortenedMetabolite,KLArrayAllComb(i*4-1),KLArrayAllComb(i*4));
end
fclose(writeFID2);
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,'KLCombinedHigh.png');