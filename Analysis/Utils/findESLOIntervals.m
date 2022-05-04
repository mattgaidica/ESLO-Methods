function dataIntervals = findESLOIntervals(data,type,labels,useTypes)
recInterval = 60; % seconds, for battery, time, temperature
refIds = find(type == ESLOType("BatteryVoltage",labels));
nBetween = 5;
onLocs = refIds(diff(diff(refIds) > nBetween) == 1);
offLocs = refIds(diff(diff(refIds) > nBetween) == -1);
if onLocs(1) > offLocs(1) 
    onLocs = [1 onLocs]; % started ON, catch this segment
end
if offLocs(end) < onLocs(end)
    offLocs = [offLocs max(onLocs)]; % ened ON, place end id
end
if numel(onLocs) ~= numel(offLocs) || ~all(sign(offLocs - onLocs) == 1)
    error("Check on/off times")
end

dataIntervals = table;
dataCount = 0;
warning ('off','all');
timeIds = find(type == ESLOType("AbsoluteTime",labels));
for iType = 1:numel(useTypes)
    useType = ESLOType(useTypes(iType),labels);
    theseTypeIds = find(type == useType);
    
    for iOnOff = 1:numel(onLocs)
        theseDataIds = theseTypeIds(theseTypeIds > onLocs(iOnOff) & theseTypeIds <= offLocs(iOnOff));
        if isempty(theseDataIds)
            continue;
        end
        dataCount = dataCount + 1;
        t1Id = closest(timeIds,onLocs(iOnOff));
        % add 0x61000000 for unix/posix time !! may change based on deployment date
        t1 = data(timeIds(t1Id));
        t2Id = closest(timeIds,offLocs(iOnOff));

        dataIntervals.segment(dataCount) = iOnOff;
        dataIntervals.type(dataCount) = useType;
        dataIntervals.label(dataCount) = useTypes(iType);
        dataIntervals.time(dataCount) = datetime(t1,'ConvertFrom','posixtime',...
            'Format','dd-MMM-yyyy HH:mm:ss','TimeZone','America/Detroit');
        dataIntervals.duration(dataCount) = (t2Id - t1Id) * recInterval;
        dataIntervals.range(dataCount) = {theseDataIds};
    end
end
warning ('on','all');