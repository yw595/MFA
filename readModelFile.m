function [measurements errors expMID expSTD metabolites isotopomers reactionLabels1 reactionLabels2]=readModelFile(modelFile)

inputFID=fopen(modelFile);

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

end