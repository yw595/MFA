function [fluxPars opVals minsMaxes lowsHighs flags] = readCIFile(CIFile)
    fluxPars = {};
    opVals = [];
    minsMaxes = [];
    lowsHighs = [];
    flags = {};
    
    inputFID = fopen(CIFile);
    line = fgetl(inputFID);
    while(line~=-1)
        words = strsplit(line,'\t');
        if(strcmp( words{1},'fluxPar' ))
            continue;
        end
        
        fluxPars{end+1} = words{1};
        opVals(end+1) = str2num(words{2});
        minsMaxes(end+1,1) = str2num(words{3});
        minsMaxes(end+1,2) = str2num(words{4});
        lowsHighs(end+1,1) = str2num(words{5});
        lowsHighs(end+1,2) = str2num(words{7});
        flags{end+1,1} = words{6};
        flags{end+1,2} = words{8};
    end
    fclose(CIFile);
end