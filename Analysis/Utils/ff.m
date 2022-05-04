function h = ff(varargin)
xpos = 0;
ypos = 0;
screensize = get(groot,'Screensize');
if isempty(varargin)
    h = figure('position',screensize);
elseif numel(varargin) == 1
    h = figure('position',[10 10 varargin{1} screensize(4)]);
elseif numel(varargin) == 2
    h = figure('position',[10 10 varargin{1} varargin{2}]);
elseif numel(varargin) == 3
    MP = get(0, 'MonitorPositions');
    if size(MP, 1) == 1 || varargin{3} == 1% Single monitor
        h = figure('position',[10 10 varargin{1} varargin{2}]);
    else % Multiple monitors
        Shift = MP(2, 1:2);
        h = figure('position',[10 10 varargin{1} varargin{2}]);
        set(h,'Units','pixels');
        pos = get(h,'Position');
        set(h,'Position',[pos(1:2) + Shift, varargin{1},varargin{2}]);
    end
else % random pos
    h_width = varargin{1};
    h_height = varargin{2};
    rnd1 = screensize(3) - h_width;
    rnd2 = screensize(4) - h_height;
    h = figure('position',[randi([0 rnd1]) randi([0 rnd2]) h_width h_height]);
end
set(gcf,'color','w');