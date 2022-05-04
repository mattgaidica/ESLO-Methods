function SDreport(type,labels)
clc
for iType = 0:size(labels,1)-1
    fprintf("%02d (%s) - %1.0f samples\n",iType,labels{iType+1,2},sum(type==iType));
end