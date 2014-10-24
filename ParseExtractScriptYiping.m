%min1Percent controls whether all errors have absolute floor of .01.
min1Percent=1;
[c13mfa metNamesTable junk2] = xlsread('XiaojingTargetedYiping.xlsx');
metNamesTable=metNamesTable(2:end,1);

%read in list of targeted metabolites
metNamesList={};
listFID=fopen('TargetedListNames.txt');
line=fgetl(listFID);
while(line~=-1)
    words=strsplit(line,' ');
    if(~strcmp(words{1},'ID'))
        metNamesList{end+1}=words{1};
    end
    line=fgetl(listFID);
end
fclose(listFID);

%determine indices of where the plain metabolite names from
%metNamesList, that is without m+1,+2,..., occur in metNamesTable
%sort metNamesList accordingly
metNamesMatchIdxs=[];
for i=1:length(metNamesList)
    tempMatrix=find(strcmp(metNamesTable,metNamesList{i}));
    metNamesMatchIdxs(end+1)=tempMatrix(1);
end
[metNamesMatchIdxs sortIdxs]=sort(metNamesMatchIdxs);
metNamesList=metNamesList(sortIdxs);

%colIdxs contain locations of replicate columns for high and low glucose
colIdxsHighGlucose=[1:3; 7:9; 13:15; 19:21; 25:27; 31:33; 37:39; 43:45];
colIdxsLowGlucose=[4:6; 10:12; 16:18; 22:24; 28:30; 34:36; 40:42; 46:48];
bigMatrix=zeros(1720,4);
for h=1:2
    discardedNumMean=0;
    discardedNumError=0;
    boostedNumError=0;
    colIdxs=[];
    if(h==1)
        colIdxs=colIdxsHighGlucose;
    end
    if(h==2)
        colIdxs=colIdxsLowGlucose;
    end
    
    numToDivideByMean=zeros(1720,1);
    numToDivideByError=zeros(1720,1);
    for z = size(colIdxs,1)
        %determine submatrix of mfa measurements corresponding to zth
        %set of replicates from colIdxs
        c13mfaSub = c13mfa(:,colIdxs(z,:));
        
        MID = zeros(1720,3);
        MIDGood=zeros(1720,3);
        
        MIDMean = zeros(1720,1);
        MIDError = zeros(1720,1);
        for i=1:length(metNamesList)
            %get row indices of all mass isotopomers corresponding to ith
            %name in metNamesList
            if(i~=length(metNamesList))
                metIdxs=metNamesMatchIdxs(i):(metNamesMatchIdxs(i+1)-1);
            else
                metIdxs=metNamesMatchIdxs(i):length(metNamesTable);
            end
            
            %determine MID for ith metName, zth set of replicates, set
            %MIDGood to 1 for a replicate only if measurements for are not
            %all zero
            for j = 1:3
                MID(metIdxs,j) = c13mfaSub(metIdxs,j)/sum(c13mfaSub(metIdxs,j));
                if(sum(c13mfaSub(metIdxs,j))~=0)
                    MIDGood(metIdxs,j)=1;
                end
            end
            
            %if MIDGood==1 for mass isotopomers of a metName, set MIDMean
            %as average of three replicates, else set to NaN
            if(sum(MIDGood(metIdxs(1),:)~=0))
                MIDMean(metIdxs,:) = mean(MID(metIdxs,:),2);
            else
                discardedNumMean=discardedNumMean+1;
                MIDMean(metIdxs,:) = NaN;
            end
            
            %If two or more good replicates, std can be calculated and put 
            %in MIDError, else set to NaN
            if(sum(MIDGood(metIdxs(1),:))>=2)
                MIDError(metIdxs) = std(MID(metIdxs,:),0,2);
            else  
                discardedNumError=discardedNumError+1;
                MIDError(metIdxs) =  NaN;
            end
            
            %boost MIDError<.01 to .01, if necessary boost mean of
            %corresponding mass isotopomer to .01, subtract sub of boosted
            %means from largest mass isotopomer mean
            if(min1Percent)
                if(sum(MIDGood(metIdxs(1),:))>=2)
                    decreaseMax=0;
                    for j=1:length(metIdxs)
                        if(MIDError(metIdxs(j))<.01)
                            MIDError(metIdxs(j))=.01;
                            if(MIDMean(metIdxs(j))<.01)
                                decreaseMax=decreaseMax+(.01-MIDMean(metIdxs(j)));
                                MIDMean(metIdxs(j))=.01;
                            end
                        end
                    end
                    [junk maxIdx]=max(MIDMean);
                    MIDMean(maxIdx)=MIDMean(maxIdx)-decreaseMax;
                    if(decreaseMax>0)
                        boostedNumError=boostedNumError+1;
                    end
                end
            end
        end
        
        %increment numToDivideBy and bigMatrix for Mean and Error for 
        %mass isotopomers that had good means and errors
        numToDivideByMean(~isnan(MIDMean))=numToDivideByMean(~isnan(MIDMean))+1;
        numToDivideByError(~isnan(MIDError))=numToDivideByError(~isnan(MIDError))+1;
        bigMatrix(~isnan(MIDMean),h*2-1)=bigMatrix(~isnan(MIDMean),h*2-1)+MIDMean(~isnan(MIDMean));
        bigMatrix(~isnan(MIDError),h*2)=bigMatrix(~isnan(MIDError),h*2)+MIDError(~isnan(MIDError));
    end
    
    %average bigMatrix Mean and Error
    bigMatrix(:,h*2-1)=bigMatrix(:,h*2-1)./numToDivideByMean;
    bigMatrix(:,h*2)=bigMatrix(:,h*2)./numToDivideByError;
end

%add heads and metNames to bigMatrix, write to output file
bigCellArray={};
bigCellArray{1,1}='';
bigCellArray{1,2}='MeanHighGlucose';bigCellArray{1,3}='ErrorHighGlucose';
bigCellArray{1,4}='MeanLowGlucose';bigCellArray{1,5}='ErrorLowGlucose';
for i=1:1720
    bigCellArray{i+1,1}=metNamesTable{i};
    for j=2:5
        bigCellArray{i+1,j}=bigMatrix(i,j-1);
    end
end
xlswrite('AllMetabolitesYipingMin1Percent.xlsx',bigCellArray,'A1:E1721')