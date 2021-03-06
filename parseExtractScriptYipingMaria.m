function parseExtractScriptYipingMaria(pageNumber,outputDir,suffix)
%pageNumber must be first, so that outputDir and suffix can be optional
%arguments

if ~exist('outputDir','var')
    outputDir = 'outputMaster/Maria';
end
if ~exist('suffix','var')
    suffix='MariaNoMin1Percent';
end

%min1Percent controls whether all errors have absolute floor of .01.
%use pageNumber since Maria's data has pos and neg parts
min1Percent=0;
[c13mfa metNamesTable junk2] = xlsread(['data' suffix '.xlsx'],pageNumber);
%Since we do not remove extra row as we did for Xiaojing, Excel sheet
%column headers start at 2 and met names end at 968, for page 2.
%For some reason, metNamesTable has the column headers in the first row, so
%metNames start at second row, continue till 967. Similar for page 1
if(pageNumber==2)
    metNamesTable=metNamesTable(2:967,52);
else
    metNamesTable=metNamesTable(2:324,52);
end

%read in list of targeted metabolites (note need to make script to make
%such a targeted list direct from excel table)
metNamesList={};
listFID=fopen(['TargetedListNames' suffix '.txt']);
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
    if(numel(tempMatrix)~=0)
        metNamesMatchIdxs(end+1)=tempMatrix(1);
    end
end
[metNamesMatchIdxs sortIdxs]=sort(metNamesMatchIdxs);
metNamesList=metNamesList(sortIdxs);

%if we use above code block from Xiaojing, seems only seven met names match
%therefore, just add plain met names to list as we find them in table, and
%build matchIdxs accordingly
metNamesList = {};
metNamesMatchIdxs = [];
for i=1:length(metNamesTable)
    if(isempty(regexp( metNamesTable{i},'[13C]' )))
        metNamesMatchIdxs(end+1) = i;
        metNamesList{end+1} = metNamesTable{i};
    end
end

%colIdxs contain locations of replicate columns for high and low glucose
colIdxsVeh=[54:56; 57:59; 60:62; 63:65; 66:68; 69:71] - 1;
colIdxsKA=[72:74; 75:77; 78:80; 81:83; 84:86; 87:89] - 1;
%outputMatrix contains 24 columns for vehicle and KA, six time points,
%mean and error
outputMatrix=zeros(length(metNamesTable),24);
for h=1:2
    discardedNumMean=0;
    discardedNumError=0;
    boostedNumError=0;
    colIdxs=[];
    if(h==1)
        colIdxs=colIdxsVeh;
    end
    if(h==2)
        colIdxs=colIdxsKA;
    end
    
    numToDivideByMean=zeros(length(metNamesTable),1);
    numToDivideByError=zeros(length(metNamesTable),1);
    for z = 1:size(colIdxs,1)
        %determine submatrix of mfa measurements corresponding to zth
        %set of replicates from colIdxs
        c13mfaSub = c13mfa(:,colIdxs(z,:));
        
        MID = zeros(length(metNamesTable),3);
        MIDGood = zeros(length(metNamesTable),3);   
        MIDMean = zeros(length(metNamesTable),1);
        MIDError = zeros(length(metNamesTable),1);
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
            %corresponding mass isotopomer to .01, subtract sum of boosted
            %means from largest mass isotopomer mean
            if(min1Percent)
                if(sum(MIDGood(metIdxs(1),:))>=2)
                    decreaseMax=0;
                    for j=1:length(metIdxs)
                        if(MIDError(metIdxs(j))<.01)
                            MIDError(metIdxs(j))=.01;
                            if(MIDMean(metIdxs(j))<.01)
                                decreaseMax = decreaseMax+(.01-MIDMean(metIdxs(j)));
                                MIDMean(metIdxs(j)) = .01;
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
        
        %increment numToDivideBy and outputMatrix for Mean and Error for 
        %mass isotopomers that had good means and errors
        numToDivideByMean(~isnan(MIDMean)) = numToDivideByMean(~isnan(MIDMean))+1;
        numToDivideByError(~isnan(MIDError)) = numToDivideByError(~isnan(MIDError))+1;
        outputMatrix(~isnan(MIDMean), (h-1)*12+(z-1)*2+1) = MIDMean(~isnan(MIDMean));
        outputMatrix(~isnan(MIDError), (h-1)*12+(z-1)*2+2) = MIDError(~isnan(MIDError));
    end
end

fractionalLabeling = [];
for i=1:2
    currentLabeling = 0;
    currentMetNum = 1;
    for j=1:length(metNamesTable)
        jthMetName = metNamesTable{j};
        
        % strip out " in front of "clupanodonic acid/docosa-4 and "(R, so
        % we can parse MI numbers below
        if(strcmp( jthMetName(1),'"' ))
            jthMetName = jthMetName(2:end);
        end
        
        labelingIndex = regexp( jthMetName,'\[13C\]' );
        if(~isempty(labelingIndex))
            currentLabeling = str2num(jthMetName(1: labelingIndex(1)-1 ));
        else
            %for the first metabolite, there are no processed MIs behind
            %it, thus we skip it
            if(j~=1)
                %currentLabeling should be the highest MI number of the
                %preceding metabolite, representing total number of
                %carbons, which we use to weight the barePercent
                total = totalLabeled + barePercent*currentLabeling;
                fractionalLabeling(currentMetNum,i) = totalLabeled/total;
                currentMetNum = currentMetNum+1;
            end
            currentLabeling = 0;
        end
        
        % use i*12-1 to get last 4 hour time point for either vehicle or KA
        if(currentLabeling~=0)
            totalLabeled = totalLabeled + currentLabeling*outputMatrix(j,i*12-1);
        else
            barePercent = outputMatrix(j,i*12-1);
            totalLabeled = 0;
        end
        
        %at end of data, we must process MI data of last metabolite
        %although there are more bare met names to anchor on
        if(j==length( metNamesTable ))
            total = totalLabeled + barePercent*currentLabeling;
            fractionalLabeling(currentMetNum,i) = totalLabeled/total;
            currentMetNum = currentMetNum+1;
        end
    end
end

fractionalLabeling

%add headers and metNames to outputMatrix, write to output file
conditions = {'Veh','KA'};
times = {'0min','15min','30min','1h','2h','4h'};
outputCellArray={};
outputCellArray{1,1}='';
for i=1:length(conditions)
    for j=1:length(times)
        outputCellArray{1,(i-1)*12 + (j-1)*2 + 1 + 1} = ['Mean' conditions{i} times{j}];
        outputCellArray{1,(i-1)*12 + (j-1)*2 + 2 + 1} = ['Error' conditions{i} times{j}];
    end
end
for i=1:length(metNamesTable)
    outputCellArray{i+1,1}=metNamesTable{i};
    for j=2:size(outputMatrix,2)+1
        outputCellArray{i+1,j}=outputMatrix(i,j-1);
    end
end

%either write out all negative data to new sheet, or append positive data
%based on hardcoded length of previous negative data
if(pageNumber==2)
    xlswrite([outputDir '/AllMetabolitesYiping' suffix '.xlsx'], outputCellArray)
else
    xlswrite([outputDir '/AllMetabolitesYiping' suffix '.xlsx'], outputCellArray(2:end,:), 'A968:Y1290')
end
end