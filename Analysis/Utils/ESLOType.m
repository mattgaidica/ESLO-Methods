function typeId = ESLOType(esloString,labels)
typeId = str2double(labels{ismember(labels(:,2),esloString),1});