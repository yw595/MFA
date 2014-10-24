readfile='All13CMetabolitesHCT116HighLowGlucose_MID_and_ErrorErythroseInterchanged.xlsx';
suffix='Mod2ExpandedHighUniform';
writefile=['beckerModel' suffix '.xls'];
errorCompareGraph=['errorCompareGraph' suffix '.png'];
meanOffset=1;errorOffset=2;overwriteError=1;
[junk1 junk2 rawread]=xlsread(readfile);
[junk1 junk2 rawwrite]=xlsread(writefile);

beckerMetsToXiaojingMets=containers.Map({'GLC6P#111111','F6P#111111','F16BP#111111','DHAP#111','G3P#111','ThreePG#111', ...
    'PYR#111','LAC#111','P5P#11111','E4P#1111','S7P#1111111','SER#111','GLY#11','VALX#11111','PHEX#111111111', ...
    'TYRX#111111111','TRPX#11111111111','OAA#1111','CIT#111111','AKG#11111','SUC#1111','GLN#11111','GLU#11111', ...
    'ALA#111','ASP#1111','ORN#11111','CITR#111111','PRO#11111','ARG#111111'}, ...
    {'hexose-phosphate','hexose-phosphate','fructose-16-bisphosphate', ...
    'dihydroxy-acetone-phosphate','D-glyceraldehdye-3-phosphate','3-phosphoglycerate','pyruvate','lactate','ribose-phosphate', ...
    'D-erythrose-4-phosphate','D-sedoheptulose-7-phosphate','serine','Glycine','valine','phenylalanine','tyrosine','tryptophan', ...
    'oxaloacetate','citrate-isocitrate','a-ketoglutarate','succinate','glutamine','glutamate','alanine','aspartate', ...
    'ornithine','citrulline','proline','arginine'});

%read in beckerModel names, with carbon numbers, of simulatedMDVs section
simulatedMDVs={};
[temp1 temp2]=find(strcmp(rawwrite,'simulatedMDVs'));
simulatedMDVsCoords=[temp1 temp2];
i=simulatedMDVsCoords(1)+1;
while(strcmp(rawwrite{i,1},'#'))
    simulatedMDVs{end+1}=rawwrite{i,2};
    i=i+1;
end

%read in inputSubstrates section, just to adjust endBlankRow
[temp1 temp2]=find(strcmp(rawwrite,'inputSubstrates'));
inputSubstratesCoords=[temp1 temp2];
i=inputSubstratesCoords(1)+1;
while(i<=size(rawwrite,1) && strcmp(rawwrite{i,1},'#'))
    i=i+1;
end
endBlankRow=i;

%write measurements header
xlswrite(writefile,{'##','measurements'},['A' num2str(endBlankRow+1) ':' 'B' num2str(endBlankRow+1)]);
endBlankRow=endBlankRow+2;

beckerMets=keys(beckerMetsToXiaojingMets);
writeBlock={};
writeBlockRow=1;
labels={};
means=[];
errors1=[];
errors2=[];
%for each simulatedMDV, find corresponding XiaojingMet, read in
%measurements for each isotope, saving labels and mean values for graph
%later
for i=1:length(simulatedMDVs)
    XiaojingMet=beckerMetsToXiaojingMets(simulatedMDVs{i});
    numOnes=length(simulatedMDVs{i})-regexp(simulatedMDVs{i},'#');
    %write measurements for unlabeled metabolite
    [temp1 temp2]=find(strcmp(rawread,XiaojingMet));
    writeBlock{writeBlockRow,1}='#';
    writeBlock{writeBlockRow,2}=rawread{temp1,temp2+meanOffset};
    writeBlock{writeBlockRow,3}=simulatedMDVs{i};
    writeBlock{writeBlockRow,4}='m';
    labels{end+1}=[XiaojingMet ' m'];
    means(end+1)=rawread{temp1,temp2+meanOffset};
    writeBlockRow=writeBlockRow+1;
    %write measurements for each labeled metabolite
    for j=1:numOnes
        [temp1 temp2]=find(strcmp(rawread,[num2str(j) '[13C]' XiaojingMet]));
        writeBlock{writeBlockRow,1}='#';
        writeBlock{writeBlockRow,2}=rawread{temp1,temp2+meanOffset};
        writeBlock{writeBlockRow,3}='';
        writeBlock{writeBlockRow,4}=['m+' num2str(j)];
        labels{end+1}=['m+' num2str(j)];
        means(end+1)=rawread{temp1,temp2+meanOffset};
        writeBlockRow=writeBlockRow+1;
    end
end
%write blank line
xlswrite(writefile,writeBlock,['A' num2str(endBlankRow) ':' 'D' num2str(endBlankRow+size(writeBlock,1)-1)]);
endBlankRow=endBlankRow+size(writeBlock,1);

%write errors header
xlswrite(writefile,{'##','error'},['A' num2str(endBlankRow+1) ':' 'B' num2str(endBlankRow+1)]);
endBlankRow=endBlankRow+2;

beckerMets=keys(beckerMetsToXiaojingMets);
writeBlock={};
writeBlockRow=1;
%for each simulatedMDV, find corresponding XiaojingMet, read in
%errors for each isotope, saving labels and error values for graph
%later, both plain and set to 10 percent if too low
for i=1:length(simulatedMDVs)
    XiaojingMet=beckerMetsToXiaojingMets(simulatedMDVs{i});
    numOnes=length(simulatedMDVs{i})-regexp(simulatedMDVs{i},'#');
    %write errors for unlabeled metabolite
    [temp1 temp2]=find(strcmp(rawread,XiaojingMet));
    writeBlock{writeBlockRow,1}='#';
    writeBlock{writeBlockRow,2}=rawread{temp1,temp2+errorOffset};
    errors1(end+1)=rawread{temp1,temp2+errorOffset};
    errors2(end+1)=rawread{temp1,temp2+errorOffset};
    if(errors1(end)==0)
        errors1(end)=.000001;errors2(end)=.000001;
    end
    if(writeBlock{writeBlockRow,2}<=.1)
        if(overwriteError)
            writeBlock{writeBlockRow,2}=.1;
            errors2(end)=.1;
        end
    end
    if(0)
    if(writeBlock{writeBlockRow,2}<=.1*rawread{temp1,temp2+meanOffset})
        if(overwriteError)
            writeBlock{writeBlockRow,2}=.1*rawread{temp1,temp2+meanOffset};
            errors2(end)=.1*rawread{temp1,temp2+meanOffset};
        end
    end
    end
    writeBlockRow=writeBlockRow+1;
    %write errors for each labeled metabolite
    for j=1:numOnes
        [temp1 temp2]=find(strcmp(rawread,[num2str(j) '[13C]' XiaojingMet]));
        writeBlock{writeBlockRow,1}='#';
        writeBlock{writeBlockRow,2}=rawread{temp1,temp2+errorOffset};
        errors1(end+1)=rawread{temp1,temp2+errorOffset};
        errors2(end+1)=rawread{temp1,temp2+errorOffset};
        if(errors1(end)==0)
            errors1(end)=.000001;errors2(end)=.000001;
        end
        if(writeBlock{writeBlockRow,2}<=.1)
            if(overwriteError)
                writeBlock{writeBlockRow,2}=.1;
                errors2(end)=.1;
            end
        end
        if(0)
        if(writeBlock{writeBlockRow,2}<=.1*rawread{temp1,temp2+meanOffset})
            if(overwriteError)
                writeBlock{writeBlockRow,2}=.1*rawread{temp1,temp2+meanOffset};
                errors2(end)=.1*rawread{temp1,temp2+meanOffset};
            end
        end
        end
        writeBlockRow=writeBlockRow+1;
    end
end
%write blank line
xlswrite(writefile,writeBlock,['A' num2str(endBlankRow) ':' 'B' num2str(endBlankRow+size(writeBlock,1)-1)]);
endBlankRow=endBlankRow+size(writeBlock,1);

figure('Visible','off');
hold on;
bar(1:length(means),(errors2./means)',2);
if(overwriteError==0)
    plot(1:length(means),.1*ones(1,length(means)),'-r','LineWidth',3);
    disp(['Total number of errors < .1: ' num2str(sum(errors2./means<.1)) ' out of ' num2str(length(means))])
end
set(gcf,'Units','centimeters');
set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperPosition',[.25 2.5 .16*length(means) 12]);
set(gca,'XTick',[]);
ylabel('Error/Mean');
hx=get(gca,'XLabel');
set(hx,'Units','data');
pos=get(hx,'Position');
y=pos(2);
for i=1:length(labels)
    t(i)=text(i,y+.02,labels{i});
end
set(t,'Rotation',90,'HorizontalAlignment','right');
saveas(gcf,errorCompareGraph)