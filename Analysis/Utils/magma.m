function cmap = magma(varargin)
cmapPath = 'magma.png';
if ~isempty(varargin) % set nColors
    cmap = mycmap(cmapPath,varargin{1});
else
    cmap = mycmap(cmapPath);
end