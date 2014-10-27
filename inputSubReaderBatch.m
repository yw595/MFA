function outputY = inputSubReaderbatch(AAVFile)
outputY=1;
%author Lake-Ee Quek, AIBN
%to read input substrate EMU list
%and to input AAV

txt = fopen('inputSubstratesEMU.txt');
dataS = textscan(txt, '%s %s', 'delimiter', '#');
fclose(txt);

inputS={};
inputS{1,1}=dataS{1}{1};

inputS{1,2}=length(dataS{2}{1});
for i = 1:length(dataS{1})
    hitFound = 0;
    for j = 1:size(inputS,1)
        if strcmp(dataS{1}{i},inputS{j,1})
            hitFound = 1;
            break;
        end
    end
    if hitFound==0
        inputS{end+1,1} = dataS{1}{i};
        inputS{end,2} = length(dataS{2}{i});
    end
end

choose = 1;
if AAVFile == 1 && choose == 1
    load inputSubConfig.mat;
end

genInSubEMU(substrateInfo,dataS);
