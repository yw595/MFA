readFID=fopen('TargetedListNames.txt');
%writeFID=fopen('TargetedListNamesWithAbbr.csv','w');
line=fgetl(readFID);
writeBlock={};
while(line~=-1)
    words=strsplit(line,' ');
    words{end+1}=strrep(words{1},'-','_');
    words{end}=strrep(words{end},'^1','One');
    words{end}=strrep(words{end},'^2','Two');
    words{end}=strrep(words{end},'^3','Three');
    words{end}=strrep(words{end},'^4','Four');
    words{end}=strrep(words{end},'^5','Five');
    words{end}=strrep(words{end},'^6','Six');
    words{end}=strrep(words{end},'^7','Seven');
    words{end}=strrep(words{end},'^8','Eight');
    words{end}=strrep(words{end},'^9','Nine');
    writeBlock{end+1,1}='';
    for i=1:length(words)
        writeBlock{end,i}=words{i};
    end
    line=fgetl(readFID);
end
xlswrite('TargetedListNamesWithAbbr.xls',writeBlock,['A1:C' num2str(size(writeBlock,1))]);