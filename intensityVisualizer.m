function intensityVisualizer(outputDir, suffix)
if ~exist('outputDir','var')
    outputDir = 'outputMaster/Maria';
end
if ~exist('suffix','var')
    suffix='Maria';
end

[intensityData metNamesTable junk2] = xlsread([outputDir '/AllMetabolitesYiping' suffix '.xlsx']);
metNamesTable = metNamesTable(2:end,1);

currentMet = '';
currentMetIntensitiesVeh = [];
currentMetIntensitiesKA = [];
for i=1:length(metNamesTable)
    intensitiesVeh = intensityData(1:2:11);
    intensitiesKA = intensityData(13:2:23);
    if(~isempty(regexp( metNamesTable{i},'[13C]' )))
        currentMetIntensitiesVeh = currentMetIntensitiesVeh + intensitiesVeh;
        currentMetIntensitiesKA = currentMetIntensitiesKA + intensitiesKA;
    else
        currentMet = metNamesTable{i};
        currentMetIntensitiesVeh = intensitiesVeh;
        currentMetIntensitiesKA = intensitiesKA;
    end
end

end