function writeXiaojingMeas(outputDir,suffix)

if ~exist(outputDir,'var')
    outputDir = 'outputMaster';
end
if ~exist(suffix,'var')
    suffix='v0';
end
readFile=[outputDir '/AllMetabolitesYiping' suffix '.xlsx'];
copyfile(['model' suffix '.xls'],[outputDir 's/model' suffix '.xls'])
writeFile=[outputDir '/model' suffix '.xls'];
errorCompareGraph=[outputDir '/errorCompareGraph' suffix '.png'];
meanOffset=1;errorOffset=2;

%overwriteError controls whether errors1 or errors2 is used (see below on
%error writing section)
%uniformError controls whether errors2 has arbitrary floor of .1
overwriteError=1;uniformError=0;
[junk1 junk2 rawReadFile]=xlsread(readFile);
[junk1 junk2 rawWriteFile]=xlsread(writeFile);

modelMetsToXiaojingMets=containers.Map({'GLC6P#111111','F6P#111111','F16BP#111111','DHAP#111','G3P#111','ThreePG#111', ...
    'PYR#111','LAC#111','P5P#11111','E4P#1111','S7P#1111111','SER#111','GLY#11','VALX#11111','PHEX#111111111', ...
    'TYRX#111111111','TRPX#11111111111','OAA#1111','CIT#111111','AKG#11111','SUC#1111','GLN#11111','GLU#11111', ...
    'ALA#111','ASP#1111','ORN#11111','CITR#111111','PRO#11111','ARG#111111','ASN#1111'}, ...
    {'hexose-phosphate','hexose-phosphate','fructose-16-bisphosphate', ...
    'dihydroxy-acetone-phosphate','D-glyceraldehdye-3-phosphate','3-phosphoglycerate','pyruvate','lactate','ribose-phosphate', ...
    'D-erythrose-4-phosphate','D-sedoheptulose-7-phosphate','serine','Glycine','valine','phenylalanine','tyrosine','tryptophan', ...
    'oxaloacetate','citrate-isocitrate','a-ketoglutarate','succinate','glutamine','glutamate','alanine','aspartate', ...
    'ornithine','citrulline','proline','arginine','asparagine'});

%read in modelMets, with carbon numbers, of simulatedMDVs section
modelMets={};
[temp1 temp2]=find(strcmp(rawWriteFile,'simulatedMDVs'));
modelMetsCoords=[temp1 temp2];
i=modelMetsCoords(1)+1;
while(strcmp(rawWriteFile{i,1},'#'))
    modelMets{end+1}=rawWriteFile{i,2};
    i=i+1;
end

%read in inputSubstrates section, just to initialize endBlankRow
[temp1 temp2]=find(strcmp(rawWriteFile,'inputSubstrates'));
inputSubstratesCoords=[temp1 temp2];
i=inputSubstratesCoords(1)+1;
while(i<=size(rawWriteFile,1) && strcmp(rawWriteFile{i,1},'#'))
    i=i+1;
end
endBlankRow=i;

%write measurements header
xlswrite(writeFile,{'##','measurements'},['A' num2str(endBlankRow+1) ':' 'B' num2str(endBlankRow+1)]);
endBlankRow=endBlankRow+2;

writeBlock={};
writeBlockRow=1;
labels={};
means=[];
%for each modelMet, find corresponding XiaojingMet, read in
%measurements for each isotope, saving labels and mean values for graph
%later
for i=1:length(modelMets)
    XiaojingMet=modelMetsToXiaojingMets(modelMets{i});
    numOnes=length(modelMets{i})-regexp(modelMets{i},'#');
    
    %write measurements for labeled and unlabeled metabolite
    for j=0:numOnes
        if(j==0)
            [temp1 temp2]=find(strcmp(rawReadFile,XiaojingMet));
        else
            [temp1 temp2]=find(strcmp(rawReadFile,[num2str(j) '[13C]' XiaojingMet]));
        end
        writeBlock{writeBlockRow,1}='#';
        writeBlock{writeBlockRow,2}=rawReadFile{temp1,temp2+meanOffset};
        if(j==0)
            writeBlock{writeBlockRow,3}=modelMets{i};
            writeBlock{writeBlockRow,4}='m';
            labels{end+1}=XiaojingMet;
        else
            writeBlock{writeBlockRow,3}='';
            writeBlock{writeBlockRow,4}=['m+' num2str(j)];
            labels{end+1}=['m+' num2str(j)];
        end
        means(end+1)=rawReadFile{temp1,temp2+meanOffset};    
        writeBlockRow=writeBlockRow+1;
    end
end
%write blank line
xlswrite(writeFile,writeBlock,['A' num2str(endBlankRow) ':' 'D' num2str(endBlankRow+size(writeBlock,1)-1)]);
endBlankRow=endBlankRow+size(writeBlock,1);

%write errors header
xlswrite(writeFile,{'##','error'},['A' num2str(endBlankRow+1) ':' 'B' num2str(endBlankRow+1)]);
endBlankRow=endBlankRow+2;

writeBlock={};
writeBlockRow=1;
errors1=[];
errors2=[];
%for each modelMet, find corresponding XiaojingMet, read in
%errors for each isotope, saving labels and error values for graph
%later, both plain (errors1) and with floor of 10 percent of mean value
%(errors2)
%errors2 set to floor of at least .1 if uniformError==1
for i=1:length(modelMets)
    XiaojingMet=modelMetsToXiaojingMets(modelMets{i});
    numOnes=length(modelMets{i})-regexp(modelMets{i},'#');
    
    %write errors for labeled and unlabeled metabolites
    for j=0:numOnes
        if(j==0)
            [temp1 temp2]=find(strcmp(rawReadFile,XiaojingMet));
        else
            [temp1 temp2]=find(strcmp(rawReadFile,[num2str(j) '[13C]' XiaojingMet]));
        end
        errors1(end+1)=rawReadFile{temp1,temp2+errorOffset};
        errors2(end+1)=rawReadFile{temp1,temp2+errorOffset};
        if(errors1(end)==0)
            errors1(end)=.000001;errors2(end)=.000001;
        end
        writeBlock{writeBlockRow,1}='#';
        writeBlock{writeBlockRow,2}=errors1(end);
        
        if(writeBlock{writeBlockRow,2}<=.1*rawReadFile{temp1,temp2+meanOffset})
            errors2(end)=.1*rawReadFile{temp1,temp2+meanOffset};
        end
        if(uniformError)
            if(writeBlock{writeBlockRow,2}<=.1)
                errors2(end)=.1;
            end
        end
        if(overwriteError)
            writeBlock{writeBlockRow,2}=errors2(end);
        end
        
        writeBlockRow=writeBlockRow+1;
    end
end
%write blank line
xlswrite(writeFile,writeBlock,['A' num2str(endBlankRow) ':' 'B' num2str(endBlankRow+size(writeBlock,1)-1)]);
endBlankRow=endBlankRow+size(writeBlock,1);

%write blank lines for all remaining lines that might have data from
%previous version
writeBlock={};
for i=1:size(rawWriteFile,1)-endBlankRow
    writeBlock{i,1}='';
    writeBlock{i,2}='';
end
if(length(writeBlock)~=0)
    xlswrite(writeFile,writeBlock,['A' num2str(endBlankRow) ':' 'B' num2str(endBlankRow+size(writeBlock,1)-1)]);
    endBlankRow=endBlankRow+size(writeBlock,1);
end

makeGraph(labels,(errors2./means)','Error/Mean',[],[.25 2.5 .16*length(means) 12], ...
    [],2,10,errorCompareGraph,'errorCompare');
end