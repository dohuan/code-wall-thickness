function HU = user_select_HU(images)
% Allows user to choose a a point indicating the HU value to use for the
% mask. Returns empty matrix [] if no point selected.

h_fig = figure('name','Select a point indicating the mask to import.',...
    'KeyPressFcn',@fig_KeyPressCallback,...
    'NumberTitle','off','WindowStyle','modal');

h_ax = axes('Parent',h_fig);
h_image = imshow(images{1},[],'Parent',h_ax);
set(h_image,'HitTest','off')
set(h_ax,'NextPlot','add','HitTest','on',...
    'ButtonDownFcn',@ax_ButtonDownCallback,'visible','on',...
    'XTick',[],'YTick',[])

uiwait(msgbox({'Select a point indicating the mask to import.' ...
               'Press up/down to navigate images.' '' ...
               'Press enter when done. Close figure to cancel.'},'modal'))

data = struct('h_image',h_image,'h_ax',h_ax,...
    'images',{images},'image_idx',1);
guidata(h_fig,data)

uiwait(h_fig) % blocks execution until user presses enter or figure is closed

HU = getHU(h_fig);

try close(h_fig)
catch ME
    if ~strcmp(ME.identifier,'MATLAB:close:InvalidFigureHandle')
        rethrow(ME)
    end
end

function fig_KeyPressCallback(hObject,e)
% Pressing up/down changes image and also deletes the selected point.

data = guidata(hObject);

switch e.Key
    case 'uparrow'
        if data.image_idx > 1
            set(data.h_image,'CData',data.images{data.image_idx-1})
            data.image_idx = data.image_idx - 1;
            delete_point(gcbf)
        end
    case 'downarrow'
        if data.image_idx < length(data.images)
            set(data.h_image,'CData',data.images{data.image_idx+1})
            data.image_idx = data.image_idx + 1;
            delete_point(gcbf)
        end
    case 'return'
        uiresume(gcbf)
end

guidata(hObject,data)

function ax_ButtonDownCallback(hObject,~)

data = guidata(hObject);

delete_point(gcbf)

point = get(data.h_ax,'CurrentPoint');
data.('point') =  point(1,1:2);
data.('h_point') = plot(data.h_ax,data.point(1),data.point(2),...
    'r.','MarkerSize',5);

guidata(hObject,data)

function delete_point(h_fig)

data = guidata(h_fig);

if isfield(data,'h_point')
    try
        delete(data.h_point)
    catch ME
        if ~strcmp(ME.identifier,'MATLAB:hg:udd_interface:CannotDelete')
            rethrow(ME)
        end
    end
    data = rmfield(data,{'h_point','point'});
end

guidata(h_fig,data)

function HU = getHU(h_fig)

try data = guidata(h_fig);
catch ME
    if ~strcmp(ME.identifier,'MATLAB:guidata:InvalidInput')
        rethrow(ME)
    else
        HU = []; % user cancelled by closing figure.
        return
    end
end

if isfield(data,'point')
    image = data.images{data.image_idx};
    point = round(data.point);
    HU = image(point(2),point(1));
else
    HU = []; % no point is currently selected.
end