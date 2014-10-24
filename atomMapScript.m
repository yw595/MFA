molFID1=fopen('test1.mol');
line=fgetl(molFID1);
linenum=0;
carbonnums1=[];
while(line~=-1)
    line=fgetl(molFID1);
    linenum=linenum+1;
    if(sum(regexp(line,'C'))~=0)
        carbonnums1(end+1)=linenum;
    end
end
numsToLetters=containers.Map;
numsToLetters(1)='a';numsToLetters(2)='b';numsToLetters(3)='c';numsToLetters(4)='d';numsToLetters(5)='e';
numsToLetters(6)='f';numsToLetters(7)='g';numsToLetters(8)='h';numsToLetters(9)='i';numsToLetters(10)='j';
[junk sortIdxs]=sort(carbonnums1);
numsToLetters2=containers.Map;
for i=1:length(sortIdxs)
    numsToLetters2(carbonnums1(i))=numsToLetters(sortIdxs(i));
end

if(0)
molFID2=fopen('test2.mol');
line=fgetl(molFID2);
linenum=0;
carbonnums2=[];
while(line~=-1)
    line=fgetl(molFID2);
    linenum=linenum+1;
    if(sum(regexp(line,'C'))~=0)
        carbonnums2(end+1)=linenum;
    end
end
end
atomMapNums=carbonnums1;atomMapNums(1:2:2*length(carbonnums)-1)=2*carbonnums-1;
%atomMapNums(2:2:2*length(carbonnums))=2*carbonnums;

mapFID=fopen('PGI.txt');
line=fgetl(mapFID);
atomMaps={};
while(line~=-1)
    words=strsplit(line,{'], [',', ','[[',']]'},'CollapseDelimiters',true);
    %firstWord=words{1};words{1}=firstWord(3:end);
    %lastWord=words{end};words{end}=lastWord(1:end-2);
    atomMap=str2double(words);
    if(length(atomMaps)==0)
        atomMaps{end+1}=atomMap(atomMapNums);
    else
        matchesPrevMap=0;
        for i=1:length(atomMaps)
            if(atomMap(atomMapNums)==atomMaps{i})
                matchesPrevMap=1;
                break;
            end
        end
        if(matchesPrevMap==0)
            atomMaps{end+1}=atomMap(atomMapNums);
        end
    end
end

reactantString='';
productString='';
for i=1:length(atomMaps)
    ithAtomMap=atomMaps{i};
    for j=1:length(ithAtomMap)
        if(rem(j,2)==1)
            reactantString=[reactantString numsToLetters2(ithAtomMap(j))];
        else
            productString=[productString numsToLetters2(ithAtomMap(j))];
        end
    end
end
fullString=[reactantString ' = ' productString];