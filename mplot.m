function fig = mplot(varargin)
% Multiple plots in a single figure with list box selection.
% 
% Creates a figure with a list box and axes. The list box contains
% references to plot instructions to sketch data on the axes. Plot
% instructions are added to the list box with successive calls to mplot.
% 
% When an item is selected in the list box, the corresponding instructions
% are used to plot data on the right-hand side axes. When an item is
% double-clicked, a new figure window opens and data are plotted on a new
% pair of axes. This is useful when the axes are to be saved or exported.
% 
% A plot instruction is either a function handle that takes a single
% argument, which is an axes handle; or a series of additional arguments
% passed to mplot, which are delegated unchanged to the built-in plot
% function.
%
% Input arguments:
% fig (optional):
%    handle of the mplot figure to add the new plot to
% caption (optional):
%    caption of the new plot in the plot selection list box
% fun (optional):
%    a function handle accepting an axes as a single argument that plots
%    data on the axes
% args (optional):
%    arguments to pass to the plot function for the new plot; if fun is
%    specified, the arguments are passed to fun instead of plot
%
% Examples:
% mplot;
%    creates an empty mplot figure if current figure is not already one
% fig = mplot;
%    returns the current figure handle in fig if it is an mplot figure,
%    creating a new figure if needed
% fig = mplot('new')
%    unconditionally creates an empty mplot figure
% x = 1:100; y = rand(1,100); mplot(x, y, 'kx');
%    adds a new plot to the currently active mplot figure; whenever the
%    corresponding list item is clicked, plot(x,y,'kx') is executed
% x = 1:100; y = rand(1,100); mplot(fig, x, y, 'kx');
%    uses the specified mplot figure instead of the currently active one
% x = 1:100; y = rand(1,100); mplot('my caption', x, y, 'kx');
%    assigns the given caption to the newly added plot
% fun = @(ax) plot(ax, x, y, 'k.'); mplot(fun);
%    adds a new plot instruction given by a user function
%
% See also: plot, subplot

% Copyright 2010 Levente Hunyadi

k = 1;  % parameter counter
if k <= numel(varargin) && isscalar(varargin{k}) && ishandle(varargin{k})  % re-use existing figure
    fig = varargin{k};
    tag = get(fig, 'Tag');
    assert(~isempty(tag) && strcmp(tag, '__mplot__'), ...  % verify figure tag
        'mplot:ArgumentTypeMismatch', 'An mplot figure is expected.');
    k = k + 1;
elseif k <= numel(varargin) && ischar(varargin{k}) && isvector(varargin{k}) && strcmp('new', varargin{k})  % force creation of new figure
    fig = mplot_figure();
    k = k + 1;
else
    curfig = get(0,'CurrentFigure');
    h = findobj('Type', 'figure', 'Tag', '__mplot__');
    if isempty(h)  % create new figure if no mplot figure exists yet
        fig = mplot_figure();
    elseif isscalar(h)  % a single mplot figure exists
        if ~isempty(curfig) && h == curfig  % currently active figure is an mplot figure
            fig = curfig;
        else
            fig = h;
            figure(fig);  % currently active figure is not an mplot figure, activate the only mplot figure
        end
    else  % multiple mplot figures exist
        if ~isempty(curfig)
            ix = find(h == curfig);  % ix is either empty or a scalar
        else
            ix = [];
        end
        if isscalar(ix)  % current figure is an mplot figure
            fig = curfig;
        else  % isempty(ix)
            fig = h(1);  % use mplot figure topmost in stacking order
            figure(fig);
            warning('mplot:InvalidOperation', ...
                'Currently active figure is not an mplot figure, the topmost mplot figure has been activated.');
        end
    end
end

if k <= numel(varargin) && ischar(varargin{k})  % use specified caption, syntax mplot('v6',...) for old-style plots is not supported
    caption = varargin{k};
    k = k + 1;
else  % use default caption
    caption = [];
end

if k > numel(varargin)  % nothing to plot
    if ~isempty(caption)
        warning('mplot:InvalidOperation', ...
            'A caption is specified but no data to plot has been passed.');
        return;
    end
    return;
end
varargin = varargin(k:end);  % drop preprocessed arguments

listbox = findobj(fig, 'Type', 'uicontrol', 'Style', 'listbox');
string = get(listbox, 'String');
userdata = get(listbox, 'UserData');

if numel(string) > 100
    warning('mplot:InvalidOperation', ...
        'There are too many plots, new plot has not been added.');
    return;
end

if numel(string) == 1 && strcmp(string, '[empty]')  % there is only the placeholder item in the list
    string = {};  % clear placeholder item
    userdata = {};
end

userdata{numel(userdata)+1} = varargin;  % add arguments to plot function
if isempty(caption)
    caption = sprintf('Plot %d', numel(userdata));
end
string{numel(string)+1} = caption;  % add caption used in list box
set(listbox, ...
    'String', string, ...
    'TooltipString', 'Double-click item (or hit ENTER) to plot in new figure window.', ...
    'UserData', userdata);
if numel(string) <= 1
    mplot_onselectionchange(listbox);  % show first selection by default
end

function fig = mplot_figure()
% Creates a new mplot figure.

fig = figure( ...
    'Tag', '__mplot__');  % ensures that all necessary controls are present

try
    % try to use uisplitter if available
    % see http://www.mathworks.co.uk/matlabcentral/fileexchange/28841-uisplitter
    [leftpanel,rightpanel] = uisplitpane(fig, ...
        'DividerWidth', 2, ...
        'DividerLocation', 0.2);
catch %#ok<CTCH> % fallback to default layout
    leftpanel = uipanel(fig, ...
        'Position', [0 0 0.2 1.0]);
    rightpanel = uipanel(fig, ...
        'Units', 'normalized', ...
        'Position', [0.2 0 0.8 1.0]);
end
    
listbox = uicontrol(leftpanel, ...  % allows selection of data to plot
    'Style', 'listbox', ...
    'Units', 'normalized', ...
    'Position', [0 0 1.0 1.0], ...
    'String', {'[empty]'}, ...  % placeholder item
    'Callback', @mplot_onselectionchange);
axes('Parent', rightpanel);
set(listbox, 'UserData', {{}});  % no plot arguments belong to placeholder item

function mplot_plot(ax, varargin)
% Plots data in an mplot figure with the specified plot arguments.
%
% Input arguments:
% ax:
%    an axes handle graphics object
% varargin (optional):
%    parameters to pass to the plot function

if nargin >= 2
    try
        plot(ax, varargin{:});
    catch me
        disp('plot function produces an error when passed parameters:');
        args = varargin(:);
        disp(args);
        mplot_error(ax);
        rethrow(me);
    end
else  % nothing to plot
    mplot_hideaxes(ax);
end

function mplot_onselectionchange(listbox, event) %#ok<INUSD>
% Fired when the selected list item changes.

fig = ancestor(listbox, 'figure');
index = get(listbox, 'Value');

if isempty(index)
    ax = findobj(fig, 'Type', 'axes');
    mplot_hideaxes(ax);
    return;
end

userdata = get(listbox, 'UserData');
args = userdata{index};

switch get(fig, 'SelectionType')
    case 'open'
        string = get(listbox, 'String');
        caption = string{index};
        if ~isempty(caption)
            newfig = figure('Name', caption);  % open new figure window
        else
            newfig = figure;
        end
        ax = axes('Parent', newfig);
    otherwise
        ax = findobj(fig, 'Type', 'axes');
        cla(ax, 'reset');  % pass clean axes to user-defined function
end

if numel(args) > 0 && isa(args{1}, 'function_handle')
    try
        fun = args{1};  % unwrap function handle from cell array
        fun(ax, args{2:end});  % call user-defined function passing axes as argument
    catch me
        mplot_error(ax);
        rethrow(me);
    end
else
    mplot_plot(ax, args{:});
end
set(ax, 'Visible', 'on');

function mplot_hideaxes(ax)

cla(ax, 'reset');
set(ax, 'Visible', 'off');

function mplot_error(ax)

mplot_hideaxes(ax);
msgbox('Error while plotting data to axes, see console for details.', ...
    'Plot error', 'error');
