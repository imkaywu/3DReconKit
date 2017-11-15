function drawColorbar(mat, textmat, varargin)

p = parseInputs(varargin{:});
% Add colorbar if selected
addColorbar(p, mat, textmat);

end

function param = parseInputs(varargin) 

p = inputParser;
p.addParamValue('Colormap',[]); %#ok<*NVREPL>
p.addParamValue('ColorLevels',[]);
p.addParamValue('TextColor',[0 0 0]);
p.addParamValue('UseFigureColormap',true);
p.addParamValue('UseLogColormap',false);
p.addParamValue('Parent',NaN);
p.addParamValue('FontSize',[]);
p.addParamValue('Colorbar',[]);
p.addParamValue('GridLines','none');
p.addParamValue('TickAngle',0);
p.addParamValue('ShowAllTicks',false);
p.addParamValue('TickFontSize',[]);
p.addParamValue('TickTexInterpreter',false);
p.addParamValue('NaNColor', [NaN NaN NaN], @(x)isnumeric(x) && length(x)==3 && all(x>=0) && all(x<=1));
p.addParamValue('MinColorValue', nan, @(x)isnumeric(x) && isscalar(x));
p.addParamValue('MaxColorValue', nan, @(x)isnumeric(x) && isscalar(x));
p.parse(varargin{:});

param = p.Results;

if ~ishandle(param.Parent) || ~strcmp(get(param.Parent,'type'), 'axes')
    param.Parent = gca;
end

% ind = ~isinf(mat(:)) | isnan(mat(:));
% if isnan(param.MinColorValue)
%     param.MinColorValue = min(mat(ind));
% end
% if isnan(param.MaxColorValue)
%     param.MaxColorValue = max(mat(ind));
% end

% Add a few other parameters
param.hAxes = param.Parent;
param.hFig = ancestor(param.hAxes, 'figure');
param.IsGraphics2 = ~verLessThan('matlab','8.4');
param.ExplicitlyComputeImage = ~all(isnan(param.NaNColor)) ... NaNColor is specified
                         || ~param.IsGraphics2 && ~param.UseFigureColormap;

end

% Add color bar
function addColorbar(p, mat, textmat)

if isempty(p.Colorbar)
    return;
elseif iscell(p.Colorbar)
%     c = colorbar(p.Colorbar{:});
    hp = p.Colorbar{1};
    c = colorbar('Position', [hp(1)+hp(3)+0.01, hp(2)+0.093, 0.02, hp(4)*0.84]);
else
    c = colorbar;
end
if p.IsGraphics2
    c.Limits = p.hAxes.CLim;
    ticks = get(c,'Ticks');
else
    if p.ExplicitlyComputeImage || ~p.UseFigureColormap
        d = findobj(get(c,'Children'),'Tag','TMW_COLORBAR'); % Image
        set(d,'YData', get(p.hAxes,'CLim'));
        set(c,'YLim', get(p.hAxes,'CLim'));
    end
    ticks = get(c,'YTick');
    tickAxis = 'Y';
    if isempty(ticks)
        ticks = get(c,'XTick');
        tickAxis = 'X';
    end
end
  
if ~isempty(ticks)
    
    if ischar(textmat) % If format string, format colorbar ticks in the same way
        ticklabels = arrayfun(@(x){sprintf(textmat,x)},ticks);
    else
        ticklabels = num2str(ticks(:));
    end
    if p.IsGraphics2
        set(c, 'TickLabels', ticklabels);
    else
        set(c, [tickAxis 'TickLabel'], ticklabels);
    end
    
end

end