function caxisauto(P,varargin)
alpha = 2; % percentile
if ~isempty(varargin)
    alpha = varargin{1};
end
minC = prctile(P(:),alpha);
maxC = prctile(P(:),100-alpha);
caxis([minC maxC]);