% --Main Figure Setup Functions--
% -------------------------------

function varargout = AortaKit(varargin)
% AORTAKIT MATLAB code for AortaKit.fig
%      AORTAKIT, by itself, creates a new AORTAKIT or raises the existing
%      singleton*.
%
%      H = AORTAKIT returns the handle to a new AORTAKIT or the handle to
%      the existing singleton*.
%
%      AORTAKIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AORTAKIT.M with the given input arguments.
%
%      AORTAKIT('Property','Value',...) creates a new AORTAKIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AortaKit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AortaKit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AortaKit

% Last Modified by GUIDE v2.5 24-Nov-2015 15:00:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AortaKit_OpeningFcn, ...
                   'gui_OutputFcn',  @AortaKit_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function AortaKit_OpeningFcn(hObject, ~, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AortaKit (see VARARGIN)

%opengl software
%set(h.mainfigure,'renderer','opengl')

iptsetpref('ImshowAxesVisible','on')

% Add paths:
[path, ~, ~] = fileparts(mfilename('fullpath'));
addpath(genpath(path))
v = version('-release');
[~,idx] = sort({v,'2014a'});
if idx(1) == 1 % then v is <= 2014a
    rmpath(genpath([path '\GUILayoutV2']))
else
    rmpath(genpath([path '\GUILayoutV1']))
end

h.multislider_contrast = MultiSlider(h.panel_imagenav);
MultiSlider(h.multislider_contrast, 'NTicks', 11);
MultiSlider(h.multislider_contrast, 'TicksRoundDigits', 0);
MultiSlider(h.multislider_contrast, 'Domain', [-1000 2000]);
MultiSlider(h.multislider_contrast, 'UserFcn', ...
    'AortaKit(''multislider_contrast_callback'',guidata(gcf))');

h.multislider_cmap = MultiSlider(h.panel_imagenav);
MultiSlider(h.multislider_cmap, 'NTicks', 11);
MultiSlider(h.multislider_cmap, 'TicksRoundDigits', 0);
MultiSlider(h.multislider_cmap, 'Domain', [0 100]);
MultiSlider(h.multislider_cmap, 'UserFcn', ...
    'AortaKit(''multislider_cmap_callback'',guidata(gcf))');

% Create tabs within objects panel:
h.tabpanel_objects = uiextras.TabPanel('Parent', h.panel_objects,...
    'Units','normal', 'Position',[0 0 1 1]);
% Profile lines tab:
h.tab_profilelines = uipanel('Parent',h.tabpanel_objects,...
    'Units','normal', 'Position',[0 0 1 1], 'BorderType','none');
set(get(h.temp_tab_profilelines,'Children'),'Parent',h.tab_profilelines)
delete(h.temp_tab_profilelines)
% Masks tab:
h.tab_masks = uipanel('Parent',h.tabpanel_objects,...
    'Units','normal', 'Position',[0 0 1 1], 'BorderType','none');
set(get(h.temp_tab_masks,'Children'),'Parent',h.tab_masks)
delete(h.temp_tab_masks)
% Isolines tab:
h.tab_isolines = uipanel('Parent',h.tabpanel_objects,...
    'Units','normal', 'Position',[0 0 1 1], 'BorderType','none');
set(get(h.temp_tab_isolines,'Children'),'Parent',h.tab_isolines)
delete(h.temp_tab_isolines)
% Filters tab:
h.tab_filters = uipanel('Parent',h.tabpanel_objects,...
    'Units','normal', 'Position',[0 0 1 1], 'BorderType','none');
set(get(h.temp_tab_filters,'Children'),'Parent',h.tab_filters)
delete(h.temp_tab_filters)
% Code tab:
h.tab_code = uipanel('Parent',h.tabpanel_objects,...
    'Units','normal', 'Position',[0 0 1 1], 'BorderType','none');
set(get(h.temp_tab_code,'Children'),'Parent',h.tab_code)
delete(h.temp_tab_code)

% Tab panel stuff:
set(h.tabpanel_objects, 'SelectedChild',1, ...
    'TabNames', {'Profile Lines', 'Masks','Isolines','Filters','Code'})


% Create tabs within Extraction panel:
h.tabpanel_extraction = uiextras.TabPanel('Parent', h.panel_extraction,...
    'Units','normal', 'Position',[0 0 1 1]);
% Patient extract tab:
h.tab_patientextract = uipanel('Parent',h.tabpanel_extraction,...
    'Units','normal', 'Position',[0 0 1 1], 'BorderType','none');
set(get(h.temp_tab_patientextract,'Children'),'Parent',h.tab_patientextract)
delete(h.temp_tab_patientextract)
% Phantom extract tab:
h.tab_phantomextract = uipanel('Parent',h.tabpanel_extraction,...
    'Units','normal', 'Position',[0 0 1 1], 'BorderType','none');
set(get(h.temp_tab_phantomextract,'Children'),'Parent',h.tab_phantomextract)
delete(h.temp_tab_phantomextract)
% Micro extract tab:
h.tab_microextract = uipanel('Parent',h.tabpanel_extraction,...
    'Units','normal', 'Position',[0 0 1 1], 'BorderType','none');
set(get(h.temp_tab_microextract,'Children'),'Parent',h.tab_microextract)
delete(h.temp_tab_microextract)

% Tab panel stuff:
set(h.tabpanel_extraction, 'SelectedChild',1, ...
    'TabNames', {'Patient Extract','Phantom Extract','Micro Extract'})

% Choose default command line output for AortaKit
h.output = hObject;

% Disable and delete data from tables initially:
set([h.table_profilelines, h.table_masks], {'Enable', 'Data'}, {'off', {}})

[path, ~, ~] = fileparts(mfilename('fullpath'));
% Load settings if available, otherwise create empty settings struct.
if exist([path '\' 'settings.mat'],'file') == 2
    s = load([path '\' 'settings.mat']);
    h.('settings') = s.settings;
else
    h.('settings') = struct();
end

% Create zoom and pan object:
h.zoom = zoom(hObject);
set(h.zoom,...
    'RightClickAction','InverseZoom',...
    'Direction','in',...
    'Enable','off',...
    'ActionPostCallback',...
    @(hObject,eventdata)zoom_ActionPostCallback(hObject,eventdata,guidata(hObject)));
setAllowAxesZoom(h.zoom,h.axes_image,true)
setAllowAxesZoom(h.zoom,h.multislider_contrast,false)
setAllowAxesZoom(h.zoom,h.multislider_cmap,false)

h.pan = pan(hObject);
set(h.pan,'Enable','off');
setAllowAxesPan(h.pan,h.axes_image,true)
setAllowAxesPan(h.pan,h.multislider_contrast,false)
setAllowAxesPan(h.pan,h.multislider_cmap,false)

h.project_loaded = false;
h.colormap = gray(256); % set default colormap as gray

% Update handles structure
guidata(hObject, h);

% Listener for scrollbar(s) (to allow dynamic scrolling):
hLstn = addlistener(h.slider_ImageScroll,'ContinuousValueChange', ...
    @(hObject, eventdata) update_image(hObject, guidata(hObject),...
    get_slider_ImageScroll_index(guidata(hObject)),true)); %#ok<NASGU>

function mainfigure_CloseRequestFcn(hObject, ~, h)
% hObject    handle to mainfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Saves settings to be loaded next time figure is opened.
[path, ~, ~] = fileparts(mfilename('fullpath'));
save([path '\settings'],'-struct','h','settings')

delete(hObject);

function varargout = AortaKit_OutputFcn(~, ~, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = h.output;

function mainfigure_ResizeFcn(hObject, ~, h)
% hObject    handle to mainfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ---Adjust imagenav panel---
% Desired position of imagenav panel relative to main figure:
top = 3;
right = 10;
bottom = 10;
left = 420;

% Get pixel positions:
mainfig_px_pos = getpixelposition(h.mainfigure);

% Set position:
x = left;
y = bottom;
width = mainfig_px_pos(3) - (left + right);
height = mainfig_px_pos(4) - (bottom + top);
setpixelposition(h.panel_imagenav, [x y width height]);

% ---Adjust control panel---
% Desired position of imagenav panel relative to main figure:
top = 10;
width = 400;
bottom = 10;
left = 10;

% Set position:
x = left;
y = bottom;
height = mainfig_px_pos(4) - (bottom + top);
setpixelposition(h.panel_control, [x y width height]);

% ---Adjust imageaxes panel---
% Desired position of imageaxes panel from top left of panel (px):
top = 40; % NOTE THIS VALUE USED IN POPUP_CMAP ADJUSTMENT BELOW
left = 40;
% Desired buffer position to right and bottom of panel (px):
right = 64; % NOTE THIS VALUE USED IN POPUP_CMAP ADJUSTMENT BELOW
bottom = 96;

% Get pixel position
imagenav_px_pos = getpixelposition(h.panel_imagenav);
imageaxes_px_pos = getpixelposition(h.panel_imageaxes);

% Adjust imageaxes panel position:
x = left;
y = bottom;
height = imagenav_px_pos(4) - (top + bottom);
width = imagenav_px_pos(3) - (left + right);
setpixelposition(h.panel_imageaxes, [x y width height]);
    
% ---Adjust axes within imageaxes panel---
% Get pixel position
imageaxes_px_pos = getpixelposition(h.panel_imageaxes);
axes_px_pos = getpixelposition(h.axes_image);

% Adjust axes position:
margin = 4;
if imageaxes_px_pos(3) > imageaxes_px_pos(4)
    % Means panel is WIDE
    y = margin;
    height = imageaxes_px_pos(4) - 2*margin;
    x = (imageaxes_px_pos(3)-height)/2;
    width = height;
    setpixelposition(h.axes_image, [x y width height])
else
    % Panel is TALL
    x = margin;
    width = imageaxes_px_pos(3) - 2*margin;
    y = (imageaxes_px_pos(4)-width)/2;
    height = width;
    setpixelposition(h.axes_image, [x y width height])
end

% ---Adjust scroll bar(s) and text, etc.---
% Image scroll slider:
setpixelposition(h.slider_ImageScroll,...
    [(imageaxes_px_pos(1)+imageaxes_px_pos(3)) imageaxes_px_pos(2) ...
    24 (imageaxes_px_pos(4)+1)])
% Image location text:
pos = getpixelposition(h.text_SliceLocation);
setpixelposition(h.text_SliceLocation,...
    [(imageaxes_px_pos(1)+(imageaxes_px_pos(3)-pos(3))/2) ...
    (imageaxes_px_pos(2)+imageaxes_px_pos(4)+5) pos(3) pos(4)])
% Image index text:
pos = getpixelposition(h.text_index);
setpixelposition(h.text_index,...
    [imageaxes_px_pos(1) (imageaxes_px_pos(2)+imageaxes_px_pos(4)+5) ...
    pos(3) pos(4)])
% Cmap popup:
pos = getpixelposition(h.popup_cmap);
setpixelposition(h.popup_cmap,...
    [(imagenav_px_pos(3)-(right+pos(3)))...
    (imagenav_px_pos(4)-(top-3)) ...
    pos(3) pos(4)])
% Contrast MultiSlider
% Need to get imageaxes pixel position relative to main figure:
imageaxes_px_pos = getpixelposition(h.panel_imageaxes);
pos = getpixelposition(h.multislider_contrast);
MultiSlider(h.multislider_contrast, 'Position', ...
    [imageaxes_px_pos(1) (imageaxes_px_pos(2)-(pos(4)+10)) ...
    imageaxes_px_pos(3) pos(4)]);
% Cmap multislider
pos = getpixelposition(h.multislider_cmap,true);
MultiSlider(h.multislider_cmap, 'Position', ...
    [imageaxes_px_pos(1) (imageaxes_px_pos(2)-(6.5*pos(4))) ...
    imageaxes_px_pos(3) pos(4)]);
% ---Adjust Control panels---
% Desired panel margins (px):
margin = 3;
% Get pixel positions:
controlpanel_px_pos = getpixelposition(h.panel_control);

% Title:
title_pos = getpixelposition(h.panel_title);
setpixelposition(h.panel_title, ...
    [margin (controlpanel_px_pos(4)-(title_pos(4)+margin)) ...
    title_pos(3) title_pos(4)])
% Objects panel:
title_pos = getpixelposition(h.panel_title);
profilelines_pos = getpixelposition(h.panel_objects);
setpixelposition(h.panel_objects, ...
    [margin (title_pos(2)-(profilelines_pos(4)+margin)) ...
    profilelines_pos(3) profilelines_pos(4)])
% Extraction panel:
profilelines_pos = getpixelposition(h.panel_objects);
analysis_pos = getpixelposition(h.panel_extraction);
setpixelposition(h.panel_extraction, ...
    [margin profilelines_pos(2)-(analysis_pos(4)+margin) ...
    analysis_pos(3) analysis_pos(4)])

function mainfigure_WindowScrollWheelFcn(hObject, eventdata, h)
% hObject    handle to mainfigure (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

if ~h.project_loaded % means no project is loaded
    return
end

if h.index + eventdata.VerticalScrollCount <= 1
    update_image(hObject, h, 1, false)
elseif h.index + eventdata.VerticalScrollCount >= h.project.n_images
    update_image(hObject, h, h.project.n_images, false)
else
    update_image(hObject, h, h.index + eventdata.VerticalScrollCount, false)
end

function slider_ImageScroll_CreateFcn(hObject,  ~, ~)
% hObject    handle to slider_ImageScroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function popup_cmap_CreateFcn(hObject,  ~, ~)
% hObject    handle to popup_cmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    %set(hObject,'BackgroundColor','white');
end

function listbox_filters_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_filters_CreateFcn(hObject,~ ,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_code_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --Settings Operations--
% -------------------------------

function fix_exportDCMDirectory(h)
% Set h.settings.exportDCMDirectory to desktop if no setting stored or
% invalid path stored. Otherwise, do nothing.

desktop = winqueryreg('HKEY_CURRENT_USER', ...
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',...
        'Desktop');

if ~isfield(h.settings,'exportDCMDirectory')
    % Set to desktop path:
    h.settings.('exportDCMDirectory') = desktop;
elseif ~exist(num2str(h.settings.exportDCMDirectory),'file')
    h.settings.('exportDCMDirectory') = desktop;
end

guidata(h.mainfigure, h);

function fix_ImagesDirectory(h)
% Set h.settings.ImagesDirectory to desktop if no setting stored or
% invalid path stored. Otherwise, do nothing.

desktop = winqueryreg('HKEY_CURRENT_USER', ...
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',...
        'Desktop');

if ~isfield(h.settings,'ImagesDirectory')
    % Set to desktop path:
    h.settings.('ImagesDirectory') = desktop;
elseif ~exist(num2str(h.settings.ImagesDirectory),'file')
    h.settings.('ImagesDirectory') = desktop;
end

guidata(h.mainfigure, h);

function fix_VFFDirectory(h)
% Set h.settings.VFFDirectory to desktop if no setting stored or
% invalid path stored. Otherwise, do nothing.

desktop = winqueryreg('HKEY_CURRENT_USER', ...
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',...
        'Desktop');

if ~isfield(h.settings,'VFFDirectory')
    % Set to desktop path:
    h.settings.('VFFDirectory') = desktop;
elseif ~exist(num2str(h.settings.VFFDirectory),'file')
    h.settings.('VFFDirectory') = desktop;
end

guidata(h.mainfigure, h);

function fix_ProjectsDirectory(h)
% Set h.settings.ProjectsDirectory to desktop if no setting stored or
% invalid path stored. Otherwise, do nothing.

desktop = winqueryreg('HKEY_CURRENT_USER', ...
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',...
        'Desktop');

if ~isfield(h.settings,'ProjectsDirectory')
    % Set to desktop path:
    h.settings.('ProjectsDirectory') = desktop;
elseif ~exist(num2str(h.settings.ProjectsDirectory),'file')
    h.settings.('ProjectsDirectory') = desktop;
end

guidata(h.mainfigure, h);

% --Project Oprations--
% -------------------------------

function filemenu_new_ClickedCallback(hObject, ~, h)
% hObject    handle to filemenu_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[dcm_files,result] = select_dcm_folder(h);

if isempty(result), return, end % Means user cancelled operation, so cancel
                                % new project.

project.('name') = 'untitled';
h.('project_loaded') = true;

% Load images:
[images, minHU, maxHU, pixel_size] = load_images(dcm_files, result);

% Store project data:
project.('original_images') = images;
project.('images') = images;
project.('minHU') = minHU; project.('maxHU') = maxHU;
project.('n_images') = length(project.images);
project.('pixel_size') = pixel_size;
h.('project') = project;

% Set title of window:
set(gcbf,'Name','AortaKit - untitled.akp')

guidata(hObject,h)
create_image(hObject,guidata(hObject))

function filemenu_newfromvff_ClickedCallback(hObject, ~, h)
% Implement ability to open vff file (1/16/15)

fix_VFFDirectory(h)
h = guidata(h.mainfigure); % Update h structure

[vObject, path] = vff3D(h.settings.VFFDirectory);

if isnumeric(vObject) && vObject == -1 % most likely user cancelled operation,
                                   % or corrupted file
    return % Cancel new project, do nothing
end

% Update relevant settings, unless fileopen failed:
h.settings.VFFDirectory = path;

project.('name') = 'untitled';
h.('project_loaded') = true;

% Load images into struct & also project data:
[images, minHU, maxHU, pixel_size] = load_vff_images(vObject);

% Store project data:
project.('original_images') = images;
project.('images') = images;
project.('minHU') = minHU; project.('maxHU') = maxHU;
project.('n_images') = length(project.images);
project.('pixel_size') = pixel_size;
h.('project') = project;

% Set title of window:
set(gcbf,'Name','AortaKit - untitled.akp')

guidata(hObject,h)
create_image(hObject,guidata(hObject))

function filemenu_open_ClickedCallback(hObject, ~, h)
% hObject    handle to filemenu_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fix_ProjectsDirectory(h)
h = guidata(hObject); % Update h structure

[filename, pathname] = uigetfile([h.settings.ProjectsDirectory '\*.akp'],...
    'Select project (.AKP) file.');

if filename == 0 % User cancelled operation
    return
end

% Update relevant settings, unless user cancelled operation:
h.settings.ProjectsDirectory = pathname;

% Try to load file, cancel operation otherwise:
try
    h_d = please_wait(h,'Loading file, please wait...');
    project = load([pathname '\' filename],'-mat');
    if ~all(isfield(project,{'name','n_images','images','minHU','maxHU',...
            'pixel_size','original_images'}))
        throw(MException('AortaKit:BadProject',...
            'There is something wrong with the specified project file.'))
    end
    delete(h_d)
catch ME
    delete(h_d)
    if strcmp(ME.identifier,'AortaKit:BadProject')
        uiwait(msgbox('There was a problem loading this file.'))
        return
    else
        rethrow(ME)
    end
end

% Ensure project is consistent, cancel operation otherwise.
if project.n_images ~= length(project.images)
    uiwait(msgbox('There was a problem loading this file.'))
    return
end

% Update project name based on filename:
[~,name,~] = fileparts(filename);
project.name = name;

% Store project:
h.('project') = project;
h.('project_loaded') = true;

% Set title of window:
set(gcbf,'Name',['AortaKit - ' project.name '.akp'])

% Import filter settings if applicable:
if isfield(h.project,'filters')
    set(h.listbox_filters,'string',h.project.filters)
end

guidata(hObject,h)
update_table_profilelines(hObject,guidata(hObject))
update_table_masks(guidata(hObject))
create_image(hObject,guidata(hObject))

function filemenu_save_ClickedCallback(hObject, ~, h)
% hObject    handle to filemenu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~h.project_loaded
    uiwait(msgbox('Cannot save. No project is open.'))
    return
else
    fix_ProjectsDirectory(h)
    h = guidata(hObject); % Update h structure
    
    [filename, pathname] = uiputfile([h.settings.ProjectsDirectory ...
        '\' h.project.name '.akp'], 'Select location and name to save project.');
    
    if filename == 0 % User cancelled operation.
        return
    end
    
    [~, filename, ~] = fileparts(filename); % Remove extension, if provided.
    
    % Update relevant settings and project name, unless user cancelled operation:
    h.settings.ProjectsDirectory = pathname;
    h.project.name = filename;
    
    % Set title of window:
    set(gcbf,'Name',['AortaKit - ' filename '.akp'])
    
    % Save project:
    project = h.project;
    h_d = please_wait(h, 'Saving file, please wait...');
    save([pathname '\' filename '.akp'], '-struct', 'project','-mat')
    delete(h_d)
    
    guidata(hObject,h)
    
end

function result = good_image_path(pathstr)
% Get files:
dcm_files = dir([pathstr '\*.dcm']);
result = ~isempty(dcm_files);

function [images, minHU, maxHU, pixel_size] = load_images(dcm_files, directory)
% Load dcm images listed in dcm_files (output of dir function) from
% directory. Returns a struct w/ fields image, location, minHU, maxHU.
% Also returns global minHU and maxHU found in the image set.
minHU = 0; maxHU = 0;
h_w = waitbar(0,'Loading images...');
set(h_w,'CloseRequestFcn','','WindowStyle','modal')
images = cell(0);
j = 1;
for i = 1:length(dcm_files)
    if ~dcm_files(i).isdir
        % Read image and dicom tags:
        % (convert image to int16 to allow negative HU values)
        im = int16(dicomread([directory '\' dcm_files(i).name]));
        info = dicominfo([directory '\' dcm_files(i).name]);

        % Rescale pixels into HU values:
        if all(isfield(info,{'RescaleSlope','RescaleIntercept'}))
            im = im*info.RescaleSlope + info.RescaleIntercept;
        end
        
        images{j,1} = im;
        
        if isfield(info,'SliceLocation')
            images{j,2} = info.SliceLocation;
        else
            images{j,2} = j;
        end
        
        % Store min and max HU vals also:
        images{j,3} = min(im(:));
        images{j,4} = max(im(:));
        
        % Update global min/max HU:
        if images{j,3} < minHU
            minHU = images{j,3};
        end
        if images{j,4} > maxHU
            maxHU = images{j,4};
        end

        j = j+1;
        waitbar(i/(length(dcm_files)*1.3))
    end
end

waitbar(1.1/1.3,h_w,'Sorting Images...')

% Sort images by SliceLocation, then subtract smallest SliceLocation
% from each images so that stored location is relative to this.
if isfield(info,'SliceLocation')
    images = sortrows(images,2);
    images(:,2) = cellfun(@(C){C-images{1,2}},images(:,2));
else
    images = sortrows(images,-2); % Reverse sorting if no SliceLocation info was used.
                                  % This way will be sorted according to
                                  % import order.
    images(:,2) = cellfun(@(C){C-images{end,2}},images(:,2));
end

% The following assigns location 0 to lowest image (and up from there):
images(:,2) = num2cell( sort(cell2mat(images(:,2)), 'descend') );

% Store images in struct:
images = cell2struct(images, {'image','location','minHU','maxHU'}, 2);
% Get pixel_size:
i = 1;
while dcm_files(i).isdir
    i = i+1;
end
info = dicominfo([directory '\' dcm_files(i).name]);
pixel_size = info.PixelSpacing(1);

delete(h_w)

function [images, minHU, maxHU, pixel_size] = load_vff_images(vObject)
% Implement ability to open vff file (1/16/15)
% Load vff images vObject. Returns a struct w/ fields image, location,
% minHU, maxHU. Also returns global minHU and maxHU found in the image set.

minHU = min(vObject.ImageStack(:));
maxHU = max(vObject.ImageStack(:));
pixel_size = vObject.Spacing(1);

h_w = waitbar(0,'Loading images...');
set(h_w,'CloseRequestFcn','','WindowStyle','modal')
images = cell(0);

for j = 1:size(vObject.ImageStack,3)
        
    images{j,1} = vObject.ImageStack(:,:,j);
    images{j,2} = (j-1)*vObject.Spacing(3);

    % Store min and max HU vals also:
    images{j,3} = min(min(vObject.ImageStack(:,:,j)));
    images{j,4} = max(max(vObject.ImageStack(:,:,j)));

    waitbar(j/(size(vObject.ImageStack,3)*1.3))

end

waitbar(1.1/1.3,h_w,'Storing Images...')

% Reverse sorting. This way will be sorted according to import order.
images = sortrows(images,-2);
images(:,2) = cellfun(@(C){C-images{end,2}},images(:,2));

% Store images in struct:
images = cell2struct(images, {'image','location','minHU','maxHU'}, 2);

delete(h_w)

% --Setup Operations-- (generally one-time, when starting new project)
% -------------------------------

function create_image(hObject,h)
% Create image in axes_image, deleting whatever was previously there.
% Requires that a project be loaded.
try 
    delete(h.image)
catch ME
    if ~strcmp(ME.identifier, 'MATLAB:nonExistentField')
        rethrow(ME)
    end
end

h.('image') = imshow(h.project.images(1).image, ...
    [h.project.minHU, h.project.maxHU], ...
    'parent', h.axes_image);

set(h.axes_image,{'XLimMode','YLimMode','ZLimMode','NextPlot','XTick',...
    'YTick','Visible'},...
    {'manual','manual','manual','add',[],[],'on'})

set(h.image,'HitTest','off')

% Turn on image navigation tools:
set([h.toggletool_zoomin,h.toggletool_zoomout,h.toggletool_pan,...
    h.toggletool_exportDCM],'Enable','on')

h.('index') = 1;
guidata(hObject,h)
setup_slider_ImageScroll(guidata(hObject))
setup_multislider_contrast(guidata(hObject))
setup_multislider_cmap(guidata(hObject))
popup_cmap_Callback(h.popup_cmap,[],guidata(hObject))
update_image(hObject,guidata(hObject),1,false)

function setup_multislider_contrast(h)
MultiSlider(h.multislider_contrast, 'Enable', 'on');
MultiSlider(h.multislider_contrast, 'Domain', ...
    double([h.project.minHU h.project.maxHU])); % Need to pass as double not uint
if h.project.maxHU - h.project.minHU < 10
    MultiSlider(h.multislider_contrast, 'TicksRoundDigits', 2);
elseif h.project.maxHU - h.project.minHU < 50
    MultiSlider(h.multislider_contrast, 'TicksRoundDigits', 1);
else
    MultiSlider(h.multislider_contrast, 'TicksRoundDigits', 0);
end

function setup_multislider_cmap(h)
MultiSlider(h.multislider_cmap, 'Enable', 'on');

function setup_slider_ImageScroll(h)
% Set up the slider w/ min/max, step, and val values:
% Starts slider at top (maximum) - corresponding to index 1.
set(h.slider_ImageScroll,{'enable','min','max','SliderStep','Value'},...
    {'on', 1, h.project.n_images, [.01 .1], h.project.n_images})

% --Image Navigation--
% -------------------------------

function update_image(hObject,h,index,listener)
% Listener indicates whether function is being called by scrollbar
% listener.

if ~h.project_loaded % means no project is loaded
    return
end

% Update displayed image to that at index.
if ishandle(h.image)
    set(h.image,'CData', h.project.images(index).image)
else
    recreate_image(hObject,h,index)
end
% Update index also:
h.index = index;
% Update slice location text:
set(h.text_SliceLocation, 'string',...
    ['Relative Slice Location: ' ...
    num2str(h.project.images(index).location,'%0.1f') ' mm'])
% Update slice index text:
set(h.text_index, 'string', num2str(index))

% Update slider:
if hObject ~= h.slider_ImageScroll
    set_slider_ImageScroll_index(h, index)
end

% Update masks:
% First delete existing:
delete( findall(h.axes_image,'Tag','OVM') )
if ~listener % NEED TO FIX - does not work for continuous scrolling yet   
    % Next, plot all visible ones:
    if isfield(h.project,'masks')
        for i = 1:length(h.project.masks)
            if h.project.masks(i).visible
                if h.project.masks(i).select, opacity = 0.8;
                else opacity = 0.4; end
                alphamask(h.project.masks(i).data{index},...
                    h.project.masks(i).color, opacity, h.axes_image);
            end
        end
    end
end

% Update profile lines:
% First delete any existing:
delete( findall(h.axes_image,'Tag','Arrow') )
if ~listener % NEED TO FIX - does not work for continuous scrolling yet
    % Next, add arrows:
    if isfield(h.project,'profilelines')
        profilelines_index = [h.project.profilelines.index];
        i = find(profilelines_index == index);
        axes(h.axes_image)
        for j = 1:length(i)
            if h.project.profilelines(i(j)).visible
                if h.project.profilelines(i(j)).select, linewidth = 2;
                else linewidth = 1; end
                pt1 = h.project.profilelines(i(j)).pt1;
                pt2 = h.project.profilelines(i(j)).pt2;
                h_arrow = arrow(pt1,pt2,10);
                set(h_arrow,'Clipping','on',...
                    'EdgeColor',h.project.profilelines(i(j)).color,...
                    'FaceColor',h.project.profilelines(i(j)).color,...
                    'LineStyle',h.project.profilelines(i(j)).style,...
                    'LineWidth',linewidth)
            end
        end   
    end
end

% Show isolines:
% First delete existing one:
delete( findall(h.axes_image,'Tag','isoline') )
% Add:
if ~listener && h.isolines.display
    axes(h.axes_image)
    set(h.axes_image,'nextplot','add')
    V = h.isolines.start:h.isolines.step:h.isolines.end;
    if length(V) < 2
        V = [V,V]; % if V has one number, make it vector to work properly
                   % with imcontour
    end
    [~,hC] = imcontour(h.project.images(index).image,V,'g');
    set(hC,'linewidth',1,'tag','isoline')
end

guidata(hObject,h)

function recreate_image(hObject,h,i)
% Use if image is expected but not found, to recreate image
% Create image in axes_image, deleting whatever was previously there.
% Requires that a project be loaded.
try 
    delete(h.image)
catch ME
    if ~strcmp(ME.identifier, 'MATLAB:nonExistentField') && ...
            ~strcmp(ME.identifier, 'MATLAB:hg:udd_interface:CannotDelete')
        rethrow(ME)
    end
end

h.('image') = imshow(h.project.images(i).image, ...
    [h.project.minHU, h.project.maxHU], ...
    'parent', h.axes_image);

set(h.axes_image,{'XLimMode','YLimMode','ZLimMode','NextPlot','XTick',...
    'YTick','Visible'},...
    {'manual','manual','manual','add',[],[],'on'})

set(h.image,'HitTest','off')

guidata(hObject,h)

multislider_contrast_callback(h)
multislider_cmap_callback(h)

function index = get_slider_ImageScroll_index(h)
% This function is necessary becasue slider is inversed.
min = get(h.slider_ImageScroll,'min');
max = get(h.slider_ImageScroll,'max');
val = get(h.slider_ImageScroll,'value');
index = round(min+max-val);

function set_slider_ImageScroll_index(h, index)
% This function is necessary becasue slider is inversed.
min = get(h.slider_ImageScroll,'min');
max = get(h.slider_ImageScroll,'max');
set(h.slider_ImageScroll,'value',min+max-index);

function slider_ImageScroll_Callback(hObject, ~, h)
% hObject    handle to slider_ImageScroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_image(hObject,h,get_slider_ImageScroll_index(guidata(hObject)),false)

function multislider_contrast_callback(h)

% Desired window width (fraction) to use if only one grip:
window = 0.2*(h.project.maxHU - h.project.minHU);
% Get grip positions:
grips = MultiSlider(h.multislider_contrast,'Results');
% # of elements in colormap:
n = size(h.colormap,1);

if isempty(grips)
    set(h.axes_image,'CLim',[h.project.minHU, h.project.maxHU])
elseif length(grips) == 1
    set(h.axes_image,'CLim',[grips-window/2, grips+window/2])
elseif length(grips) == 2
    if ~(grips(1) >= grips(2))
        set(h.axes_image,'CLim',[grips(1), grips(2)])
    end
else % following is deprecated since only 2 grips are allowed now...
    n_int = length(grips)-1;
    gray_int = 1/n_int;
    perc_HU = zeros(1,n_int);
    for i = 1:n_int
        perc_HU(i) = (grips(i+1)-grips(i))/(grips(end)-grips(1));
    end

    i_start = 1;
    i_end = round(perc_HU(1)*n);
    for i = 1:n_int
        cmap(i_start:i_end) = ...
            linspace((i-1)*gray_int,i*gray_int,(i_end-i_start+1));
        if i == n_int
            break
        end
        i_start = i_end+1;
        if i==n_int-1, i_end = n;
        else i_end = round(perc_HU(i+1)*n);
        end
    end
    cmap = [cmap',cmap',cmap'];
    set(h.axes_image,'CLim',[grips(1), grips(end)])
    set(h.mainfigure,'Colormap',cmap)
end

function multislider_cmap_callback(h)

% Desired window width to use if only one grip:
window = 20; % percent of colormap values
% Get grip positions:
grips = MultiSlider(h.multislider_cmap,'Results');
% Get curr colormap:
cmap = h.colormap;
n = size(cmap,1);

if isempty(grips)
    set(h.mainfigure,'Colormap',cmap)
elseif length(grips) == 1
    low = ceil((grips - window/2)/100*n);
    high = floor((grips + window/2)/100*n);
    if ~(low < 1 || high > n)
        % Resample cmap for higher resolution:
        cmap = interp1(cmap(low:high,:),linspace(1,high-low,256));
        set(h.mainfigure,'Colormap',cmap)
    end
elseif length(grips) == 2
    low = ceil(grips(1)/100*n);
    high = floor(grips(2)/100*n);
    if ~(low < 1 || high > n || low >= high)
        % Resample cmap for higher resolution:
        cmap = interp1(cmap(low:high,:),linspace(1,high-low,256));
        set(h.mainfigure,'Colormap',cmap)
    end
else
    set(h.mainfigure,'Colormap',cmap)
end

function popup_cmap_Callback(hObject, ~, h)
% hObject    handle to popup_cmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(hObject,'Value');
str = get(hObject,'String');

switch deblank(str{val})
    case 'Gray'
        h.colormap = gray(256);
    case 'Jet'
        h.colormap = jet(256);
    case 'Winter'
        h.colormap = winter(256);
    case 'Summer'
        h.colormap = summer(256);
    case 'Bone'
        h.colormap = bone(256);
    case 'HSV'
        h.colormap = hsv(256);
end

guidata(hObject,h)
multislider_cmap_callback(guidata(hObject))

% --Mask Operations--
% -------------------------------

function update_table_masks(h)
% Update masks table w/ data from loaded project...

% If project has no masks, disable table:
if isfield(h.project,'masks')
    if isempty(h.project.masks)
        set(h.table_masks, {'Enable', 'Data'}, {'off', {}})
        return
    else
        set(h.table_masks, 'Enable', 'on')
    end
else
    set(h.table_masks, {'Enable', 'Data'}, {'off', {}})
    return
end

% Table data a cell array w/ columns id, name, visible, select.

% Project data a struct w/ fields id, name, visible, select (and
% others...)
proj_data = h.project.masks;

curr_data = cell(length(proj_data),4);
% Create cell array of data:
for i = 1:length(proj_data)
        curr_data(i,:) = {proj_data(i).id, proj_data(i).name, ...
            proj_data(i).visible, proj_data(i).select};
end

% Update table:
set(h.table_masks, 'Data', curr_data)

function [color] = next_mask(h)

% Set color rotations (can add/remove values without affecting
% functionality):
color_rot = ['b';'r';'g';'y';'c';'m'];

if ~isfield(h.project,'maskcoloridx')
    idx = uint16(1);
elseif h.project.maskcoloridx == length(color_rot)
    idx = uint16(1);
else
    idx = uint16(h.project.maskcoloridx + 1);
end

h.project.('maskcoloridx') = idx;
guidata(h.mainfigure,h)
color = color_rot(idx);

function new_mask(BW,h)
% Add a new mask to the project, does not do error checking on the
% provided mask data (BW)! Must be same dimensions as loaded image set.

% for new mask, add 1 to max id (or set to 1 if no masks):
if isfield(h.project,'masks')
    id = int16(max([h.project.masks.id]) + 1);
else id = [];
end
if ~isempty(id)
    name = ['mask',num2str(id)];
else
    id = 1;
    name = 'mask1';
end
color = next_mask(guidata(h.mainfigure));
% Update h:
h = guidata(h.mainfigure);

new_mask = struct('id',id,'data',{BW},'color',color,'visible',true,...
    'select',false,'name',name);
if ~isfield(h.project,'masks')
    h.project.masks = new_mask;
else
    h.project.masks = vertcat(h.project.masks,new_mask);
end

guidata(h.mainfigure,h)
update_image(h.axes_image,h,h.index,false)
update_table_masks(h)

function table_masks_CellEditCallback(hObject, e, h)

% Update project.masks according to edited cell. Also update image.

if ~isfield(h.project,'masks')
    return
else
    r = e.Indices(1); c = e.Indices(2);
    data = get(hObject,'data');
    % Get index of mask in project (should be exactly 1 value):
    i = [h.project.masks.id] == data{r,1};
    switch c
        case 2
            h.project.masks(i).name = e.NewData;
        case 3
            h.project.masks(i).visible = e.NewData;
        case 4
            h.project.masks(i).select = e.NewData;
        otherwise
            throw(MException('AortaKit:UnknownError',...
                'Unexpected value change in table_masks.'))
    end
end

guidata(hObject,h)
update_image(hObject,guidata(hObject),h.index,false)

function pushbutton_masks_delete_Callback(hObject, ~, h)

if ~h.project_loaded
    return
end
if ~isfield(h.project,'masks')
    return
end

i = [h.project.masks.select];
h.project.masks(i) = [];

guidata(hObject,h)
update_table_masks(guidata(hObject))
update_image(hObject,guidata(hObject),h.index,false)

function pushbutton_masks_loadmimics_Callback(hObject, ~, h)

if ~h.project_loaded
    return
end

[dcm_files,result] = select_dcm_folder(h);
if isempty(result), return, end % Means user cancelled folder selection, so
                                % cancel load mask operation.
images = load_images(dcm_files,result);

% Error check:
if any(size(images(1).image) ~= size(get(h.image,'CData')))
    uiwait(msgbox('Selected images dimensions do not match current project.'))
    return
elseif length(images) ~= length(h.project.images)
    uiwait(msgbox('Selected directory contains more images than the current project.'))
    return
end

images = {images.image}; % place in cell array of matrices
BW = cell(length(images),1);
HU = user_select_HU(images);
if isempty(HU) % User did not select a point to identify HU for mask.
    return
end

for i = 1:length(images)
    % To extract mask from images, assume that Mimics will always indicate
    % the mask with a consistent HU value larger than any in the original
    % image (seems true).
    BW{i} = images{i} == HU;
end

new_mask(BW,h)

function pushbutton_masks_export_Callback(hObject, ~, h)

if ~h.project_loaded
    return
end
if ~isfield(h.project,'masks')
    return
end

idx_selected = find([h.project.masks.select]);
if isempty(idx_selected)
    return
end

h_d = please_wait(h,'Exporting masks, please wait...');
s = struct();

j=1;
for i = idx_selected
    s(j).name = h.project.masks(i).name;
    s(j).data = h.project.masks(i).data;
    j = j+1;
end

assignin('base','masks',s)
delete(h_d)
msgbox('Export of ''masks'' to main workspace was successful.')

function contextmenu_masks_selectall_Callback(hObject, ~, h)
% hObject    handle to contextmenu_masks_selectall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~h.project_loaded
    return
end
if ~isfield(h.project,'masks')
    return
end
select = num2cell(logical(ones(length(h.project.masks))));
[h.project.masks.select] = select{:};
guidata(hObject,h)
update_table_masks(guidata(hObject))

function contextmenu_masks_deselectall_Callback(hObject, ~, h)
% hObject    handle to contextmenu_masks_deselectall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~h.project_loaded
    return
end
if ~isfield(h.project,'masks')
    return
end
select = num2cell(logical(zeros(length(h.project.masks))));
[h.project.masks.select] = select{:};
guidata(hObject,h)
update_table_masks(guidata(hObject))

function contextmenu_masks_allvisible_Callback(hObject, ~, h)
% hObject    handle to contextmenu_masks_allvisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~h.project_loaded
    return
end
if ~isfield(h.project,'masks')
    return
end
visible = num2cell(logical(ones(length(h.project.masks))));
[h.project.masks.visible] = visible{:};
guidata(hObject,h)
update_table_masks(guidata(hObject))
update_image(hObject,guidata(hObject),h.index,false)

function contextmenu_masks_allinvisible_Callback(hObject, ~, h)
% hObject    handle to contextmenu_masks_allinvisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~h.project_loaded
    return
end
if ~isfield(h.project,'masks')
    return
end
visible = num2cell(logical(zeros(length(h.project.masks))));
[h.project.masks.visible] = visible{:};
guidata(hObject,h)
update_table_masks(guidata(hObject))
update_image(hObject,guidata(hObject),h.index,false)

% --Profile Line Operations--
% -------------------------------

function [color,style] = next_line(h)

% Set color and style rotations:
color_rot = ['b';'r';'g';'y';'c';'m'];
style_rot = {'-','--',':'};

% 18 possible color/linestyle combinations, previously used one stored
% in project.linestyleidx. 6 colors, 3 linestyles. See below:

%     'b' 'r' 'g' 'y' 'c' 'm'
% -    1   2   3   4   5   6
% --   7   8   9   10  11  12
% :    13  14  15  16  17  18

if ~isfield(h.project,'linestyleidx')
    idx = uint16(1);
elseif h.project.linestyleidx == 18
    idx = uint16(1);
else
    idx = uint16(h.project.linestyleidx + 1);
end

styleid = idivide(idx,length(color_rot),'ceil');
colorid = rem(idx-1,length(color_rot))+1;

h.project.('linestyleidx') = idx;

guidata(h.mainfigure,h)

color = color_rot(colorid);
style = style_rot{styleid};

function update_table_profilelines(~, h)
% Update profile lines w/ data from loaded project...

% If project has no profile lines, disable table:
if isfield(h.project,'profilelines')
    if isempty(h.project.profilelines)
        set(h.table_profilelines, {'Enable', 'Data'}, {'off', {}})
        return
    else
        set(h.table_profilelines, 'Enable', 'on')
    end
else
    set(h.table_profilelines, {'Enable', 'Data'}, {'off', {}})
    return
end

% Table data a cell array w/ columns id, name, location, length, visible,
% select.

% Project data a struct w/ fields id, index, pt1, pt2, visible, select (and
% others...)
proj_data = h.project.profilelines; 

curr_data = cell(length(proj_data),6);
% Create cell array of data:
for i = 1:length(proj_data)
        curr_data(i,:) = {proj_data(i).id, proj_data(i).name, ...
            h.project.images(proj_data(i).index).location,...
            sqrt(sum((proj_data(i).pt2-proj_data(i).pt1).^2))*h.project.pixel_size,...
            proj_data(i).visible, proj_data(i).select};
end

% Update table:
set(h.table_profilelines, 'Data', curr_data)

function profile_line_drawing(hObject,~,h)
UserData = get(h.toggletool_profilelines,'UserData');
cp = get(h.axes_image,'CurrentPoint');
XData = get(UserData.line,'XData');
YData = get(UserData.line,'YData');
set(UserData.line, 'XData', [XData(1) cp(1,1)],...
    'YData', [YData(1) cp(1,2)])

function toggletool_profilelines_OnCallback(hObject, ~, h)
% hObject    handle to toggletool_profilelines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~h.project_loaded
    set(hObject,'state','off')
    return
end

if strcmp(get(h.zoom,'Enable'),'on') || strcmp(get(h.pan,'Enable'),'on')
    set([h.zoom, h.pan],'Enable','off')
end

% Get original axes button down callback:
UserData.original_axes_callback = get(h.axes_image,'ButtonDownFcn');
UserData.original_WindowButtonMotionFcn = get(h.mainfigure,'WindowButtonMotionFcn');
UserData.original_WindowScrollWheelFcn = get(h.mainfigure,'WindowScrollWheelFcn');
set(h.axes_image,'ButtonDownFcn',...
    @(hObject,eventdata)profilelines_axes_callback(hObject,eventdata,guidata(hObject)))
% Store selected points in userdata of toggle button.
% Format is [ x1 y1 ; x2 y2 ]
UserData.pts = [];
set(hObject,'UserData',UserData);

function toggletool_profilelines_OffCallback(hObject, ~, h)
% hObject    handle to toggletool_profilelines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~h.project_loaded
    return
end

UserData = get(hObject,'UserData');

% Discard line:
if size(UserData.pts,1) == 1
    delete(UserData.line)
end

% Reset Call backs:
% First turn off zoom/pan modes (to enable resetting of callbacks):
set([h.zoom, h.pan], 'Enable', 'off')
set(h.axes_image,'ButtonDownFcn',UserData.original_axes_callback)
set(h.mainfigure,'WindowButtonMotionFcn',UserData.original_WindowButtonMotionFcn)
set(h.mainfigure,'WindowScrollWheelFcn',UserData.original_WindowScrollWheelFcn)

function profilelines_axes_callback(hObject, ~, h)
UserData = get(h.toggletool_profilelines,'UserData');
pts = UserData.pts;
switch size(pts,1)
    case 0
        set(h.axes_image,'NextPlot','add')
        cp = get(h.axes_image,'CurrentPoint');
        UserData.pts = cp(1,1:2);
        UserData.line = plot(h.axes_image, UserData.pts(1,1), ...
            UserData.pts(1,2), '.r-', 'LineWidth', 2);
        set(UserData.line,'HitTest','off')
        set(h.mainfigure,'WindowButtonMotionFcn',...
            {@profile_line_drawing,guidata(hObject)})
        set(h.mainfigure,'WindowScrollWheelFcn','')
    case 1
        cp = get(h.axes_image,'CurrentPoint');
        UserData.pts(2,:) = cp(1,1:2);
        new_profileline(UserData.pts(1,:),UserData.pts(2,:),h.index,...
            guidata(hObject))
        UserData.pts = [];
        set(UserData.line, 'XData', [], 'YData', [])
        set(h.mainfigure,'WindowButtonMotionFcn',...
            UserData.original_WindowButtonMotionFcn)
        set(h.mainfigure,'WindowScrollWheelFcn',...
            UserData.original_WindowScrollWheelFcn)
end
set(h.toggletool_profilelines,'UserData',UserData)

function new_profileline(pt1,pt2,index,h)

% for new line, add 1 to max id (or set to 1 if no lines):
if isfield(h.project,'profilelines')
    id = int16(max([h.project.profilelines.id]) + 1);
else id = [];
end
if ~isempty(id)
    name = ['line',num2str(id)];
else
    id = 1;
    name = 'line1';
end
[color,style] = next_line(guidata(h.mainfigure));
% Update h:
h = guidata(h.mainfigure);

new_line = struct('id',id,'index',index,'pt1',pt1,'pt2',pt2,...
    'color',color,'style',style,'visible',true,'select',false,'name',name);
if ~isfield(h.project,'profilelines')
    h.project.profilelines = new_line;
else
    h.project.profilelines = vertcat(h.project.profilelines,new_line);
end

guidata(h.mainfigure,h)
update_image(h.axes_image,h,h.index,false)
update_table_profilelines(h.axes_image,h)

function table_profilelines_CellEditCallback(hObject, e, h)
% hObject    handle to table_profilelines (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Update project.profilelines according to edited cell. Also update image.

if ~isfield(h.project,'profilelines')
    return
else
    r = e.Indices(1); c = e.Indices(2);
    data = get(hObject,'data');
    % Get index of profile line in project (should be exactly 1):
    i = [h.project.profilelines.id] == data{r,1};
    switch c
        case 2
            h.project.profilelines(i).name = e.NewData;
        case 5
            h.project.profilelines(i).visible = e.NewData;
        case 6
            h.project.profilelines(i).select = e.NewData;
        otherwise
            throw(MException('AortaKit:UnknownError',...
                'Unexpected value change in table_profilelines.'))
    end
end

guidata(hObject,h)
update_image(hObject,guidata(hObject),h.index,false)

function pushbutton_profilelines_delete_Callback(hObject, ~, h)
% hObject    handle to pushbutton_profilelines_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~h.project_loaded
    return
end
if ~isfield(h.project,'profilelines')
    return
end

i = [h.project.profilelines.select];
h.project.profilelines(i) = [];

guidata(hObject,h)
update_table_profilelines(hObject,guidata(hObject))
update_image(hObject,guidata(hObject),h.index,false)

function pushbutton_profilelines_plot_Callback(hObject, ~, h)
% hObject    handle to pushbutton_profilelines_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~h.project_loaded
    return
end
if ~isfield(h.project,'profilelines')
    return
end

idx_selected = find([h.project.profilelines.select]);
if isempty(idx_selected)
    return
end
h_fig =  mplot('new');
grid on
for i = idx_selected
    [pos, val] = get_profileline_data(h.project.profilelines(i), guidata(hObject));
    mplot(h_fig, h.project.profilelines(i).name, pos, val, ...
        [h.project.profilelines(i).color, h.project.profilelines(i).style]);
end

function pushbutton_profilelines_export_Callback(hObject, ~, h)
% hObject    handle to pushbutton_profilelines_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~h.project_loaded
    return
end
if ~isfield(h.project,'profilelines')
    return
end

idx_selected = find([h.project.profilelines.select]);
if isempty(idx_selected)
    return
end

h_d = please_wait(h,'Exporting profile lines, please wait...');
s = struct();

j=1;
for i = idx_selected
    [pos, val] = get_profileline_data(h.project.profilelines(i), guidata(hObject));
    s(j).name = h.project.profilelines(i).name;
    s(j).pos = pos;
    s(j).val = val;
    s(j).length = sqrt(sum((h.project.profilelines(i).pt2 - ...
        h.project.profilelines(i).pt1).^2));
    s(j).pt1 = h.project.profilelines(i).pt1;
    s(j).pt2 = h.project.profilelines(i).pt2;
    s(j).index = h.project.profilelines(i).index;
    s(j).location = h.project.images(h.project.profilelines(i).index).location;
    j = j+1;
end

assignin('base','profilelines',s)
delete(h_d)
msgbox('Export of ''profilelines'' to main workspace was successful.')

function [pos, val] = get_profileline_data(profileline, h)

val = improfile(h.project.images(profileline.index).image,...
    [profileline.pt1(1), profileline.pt2(1)],...
    [profileline.pt1(2), profileline.pt2(2)])';

len = sqrt(sum((profileline.pt2-profileline.pt1).^2))*h.project.pixel_size;

pos = 0 : len/(length(val)-1) : len;

function contextmenu_profilelines_selectall_Callback(hObject, ~, h)
% hObject    handle to contextmenu_profilelines_selectall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~h.project_loaded
    return
end
if ~isfield(h.project,'profilelines')
    return
end
select = num2cell(logical(ones(length(h.project.profilelines))));
[h.project.profilelines.select] = select{:};
guidata(hObject,h)
update_table_profilelines(hObject,guidata(hObject))

function contextmenu_profilelines_deselectall_Callback(hObject, ~, h)
% hObject    handle to contextmenu_profilelines_deselectall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~h.project_loaded
    return
end
if ~isfield(h.project,'profilelines')
    return
end
select = num2cell(logical(zeros(length(h.project.profilelines))));
[h.project.profilelines.select] = select{:};
guidata(hObject,h)
update_table_profilelines(hObject,guidata(hObject))

function contextmenu_profilelines_allvisible_Callback(hObject, ~, h)
% hObject    handle to contextmenu_profilelines_allvisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~h.project_loaded
    return
end
if ~isfield(h.project,'profilelines')
    return
end
visible = num2cell(logical(ones(length(h.project.profilelines))));
[h.project.profilelines.visible] = visible{:};
guidata(hObject,h)
update_table_profilelines(hObject,guidata(hObject))
update_image(hObject,guidata(hObject),h.index,false)

function contextmenu_profilelines_allinvisible_Callback(hObject, ~, h)
% hObject    handle to contextmenu_profilelines_allinvisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~h.project_loaded
    return
end
if ~isfield(h.project,'profilelines')
    return
end
visible = num2cell(logical(zeros(length(h.project.profilelines))));
[h.project.profilelines.visible] = visible{:};
guidata(hObject,h)
update_table_profilelines(hObject,guidata(hObject))
update_image(hObject,guidata(hObject),h.index,false)

% --Isoline Operations--
% -------------------------------
% Note: Callbacks also operate on creation so that h.isolines is set up
% properly. This is for edit texts and check box (not push buttons).
% Also note that pushbutton callbacks assume that they will be
% called only when a valid value is in the edit boxes (ie they will not
% error check).

function edit_isolines_start_Callback(hObject, ~, h)
val = str2double(get(hObject,'string'));
if ~isnan(val)
    h.('isolines').('start') = val;
    set(hObject,'userdata',get(hObject,'string'))
else
    fixbox(hObject,h)
    h.('isolines').('start') = str2double(get(hObject,'string'));
end
guidata(hObject,h)

% Below line will not run for create function and if no project is loaded,
% which is OK (h.index will not exist in either case).
try
    update_image(hObject,guidata(hObject),h.index,false)
catch ME
    if ~strcmp(ME.identifier,'MATLAB:nonExistentField')
        rethrow(ME)
    end
end

function edit_isolines_end_Callback(hObject, ~, h)
val = str2double(get(hObject,'string'));
if ~isnan(val)
    h.('isolines').('end') = val;
    set(hObject,'userdata',get(hObject,'string'))
else
    fixbox(hObject,h)
    h.('isolines').('end') = str2double(get(hObject,'string'));
end
guidata(hObject,h)

% Below line will not run for create function and if no project is loaded,
% which is OK (h.index will not exist in either case).
try
    update_image(hObject,guidata(hObject),h.index,false)
catch ME
    if ~strcmp(ME.identifier,'MATLAB:nonExistentField')
        rethrow(ME)
    end
end

function edit_isolines_step_Callback(hObject, ~, h)
val = str2double(get(hObject,'string'));
if ~isnan(val)
    h.('isolines').('step') = val;
    set(hObject,'userdata',get(hObject,'string'))
else
    fixbox(hObject,h)
    h.('isolines').('step') = str2num(get(hObject,'string'));
end
guidata(hObject,h)

% Below line will not run for create function and if no project is loaded,
% which is OK (h.index will not exist in either case).
try
    update_image(hObject,guidata(hObject),h.index,false)
catch ME
    if ~strcmp(ME.identifier,'MATLAB:nonExistentField')
        rethrow(ME)
    end
end

function pushbutton_isolines_startleft_Callback(hObject, ~, h)
val = str2double(get(h.edit_isolines_start,'string'));
set(h.edit_isolines_start,'string',num2str(val-1),'userdata',num2str(val-1))
h.('isolines').('start') = val-1;
guidata(hObject,h)
if h.project_loaded
    update_image(hObject,guidata(hObject),h.index,false)
end

function pushbutton_isolines_startright_Callback(hObject, ~, h)
val = str2double(get(h.edit_isolines_start,'string'));
set(h.edit_isolines_start,'string',num2str(val+1),'userdata',num2str(val+1))
h.('isolines').('start') = val+1;
guidata(hObject,h)
if h.project_loaded
    update_image(hObject,guidata(hObject),h.index,false)
end

function pushbutton_isolines_endleft_Callback(hObject, ~, h)
val = str2double(get(h.edit_isolines_end,'string'));
set(h.edit_isolines_end,'string',num2str(val-1),'userdata',num2str(val-1))
h.('isolines').('end') = val-1;
guidata(hObject,h)
if h.project_loaded
    update_image(hObject,guidata(hObject),h.index,false)
end

function pushbutton_isolines_endright_Callback(hObject, ~, h)
val = str2double(get(h.edit_isolines_end,'string'));
set(h.edit_isolines_end,'string',num2str(val+1),'userdata',num2str(val+1))
h.('isolines').('end') = val+1;
guidata(hObject,h)
if h.project_loaded
    update_image(hObject,guidata(hObject),h.index,false)
end

function pushbutton_isolines_stepleft_Callback(hObject, ~, h)
val = str2double(get(h.edit_isolines_step,'string'));
set(h.edit_isolines_step,'string',num2str(val-1),'userdata',num2str(val-1))
h.('isolines').('step') = val-1;
guidata(hObject,h)
if h.project_loaded
    update_image(hObject,guidata(hObject),h.index,false)
end

function pushbutton_isolines_stepright_Callback(hObject, ~, h)
val = str2double(get(h.edit_isolines_step,'string'));
set(h.edit_isolines_step,'string',num2str(val+1),'userdata',num2str(val+1))
h.('isolines').('step') = val+1;
guidata(hObject,h)
if h.project_loaded
    update_image(hObject,guidata(hObject),h.index,false)
end

function pushbutton_isolines_bothleft_Callback(hObject, ~, h)
valstart = str2double(get(h.edit_isolines_start,'string'));
valend = str2double(get(h.edit_isolines_end,'string'));
set(h.edit_isolines_start,'string',num2str(valstart-1),...
    'userdata',num2str(valstart-1))
set(h.edit_isolines_end,'string',num2str(valend-1),...
    'userdata',num2str(valend-1))
h.('isolines').('start') = valstart-1;
h.('isolines').('end') = valend-1;
guidata(hObject,h)
if h.project_loaded
    update_image(hObject,guidata(hObject),h.index,false)
end

function pushbutton_isolines_bothright_Callback(hObject, ~, h)
valstart = str2double(get(h.edit_isolines_start,'string'));
valend = str2double(get(h.edit_isolines_end,'string'));
set(h.edit_isolines_start,'string',num2str(valstart+1),...
    'userdata',num2str(valstart+1))
set(h.edit_isolines_end,'string',num2str(valend+1),...
    'userdata',num2str(valend+1))
h.('isolines').('start') = valstart+1;
h.('isolines').('end') = valend+1;
guidata(hObject,h)
if h.project_loaded
    update_image(hObject,guidata(hObject),h.index,false)
end

function checkbox_isolines_display_Callback(hObject, ~, h)
h.('isolines').('display') = logical(get(hObject,'value'));
guidata(hObject,h)

% Below line will not run for create function and if no project is loaded,
% which is OK (h.index will not exist in either case).
try
    update_image(hObject,guidata(hObject),h.index,false)
catch ME
    if ~strcmp(ME.identifier,'MATLAB:nonExistentField')
        rethrow(ME)
    end
end

% --Filters Operations--
% -------------------------------

function pushbutton_filters_add_Callback(hObject, ~, h)
if h.project_loaded && ...
        ~isempty(strtrim(get(h.edit_filters,'string')))
    list = get(h.listbox_filters,'string');
    list{end+1} = strtrim(get(h.edit_filters,'string'));
    set(h.listbox_filters,'string',list)
    set(h.listbox_filters,'value',[])
    set(h.edit_filters,'string','')
end

function pushbutton_filters_delete_Callback(hObject, ~, h)
if h.project_loaded
    val = get(h.listbox_filters,'value');
    list = get(h.listbox_filters,'string');
    if ~isempty(val)
        list(val) = [];
        set(h.listbox_filters,'string',list)
        set(h.listbox_filters,'value',[])
    end
end

function pushbutton_filters_apply_Callback(hObject, ~, h)
if h.project_loaded
    h.project.('filters') = get(h.listbox_filters,'string');
    set(h.edit_filters,'string','')
    set(h.listbox_filters,'value',[])
    guidata(hObject,h)
    apply_filters(h)
end

function pushbutton_filters_cancel_Callback(hObject, ~, h)
if isfield(h.project,'filters')
    set(h.listbox_filters,'string',h.project.filters)
else
    set(h.listbox_filters,'string',{})
end
set(h.listbox_filters,'value',[])
set(h.edit_filters,'string','')

function apply_filters(h)
n = length(h.project.original_images);
new_images = struct('image',cell(n,1),...
    'location',{h.project.original_images.location}',...
    'minHU',cell(n,1), 'maxHU',cell(n,1));

h_w = waitbar(0,'Applying Filters...');
set(h_w,'CloseRequestFcn','','WindowStyle','modal')

ok = true;
minHU = nan; maxHU = nan;
for i = 1:n
    I = h.project.original_images(i).image;
    for j = 1:length(h.project.filters)
        try
            eval([h.project.filters{j} ';'])
        catch
            ok = false;
            errordlg('There was a problem applying filters, operation cancelled.')
            break
        end
    end
    if ~ok, break, end
    new_images(i).image = I;
    new_images(i).minHU = min(I(:));
    new_images(i).maxHU = max(I(:));
    if isnan(minHU) || minHU > new_images(i).minHU
        minHU = new_images(i).minHU;
    end
    if isnan(maxHU) || maxHU < new_images(i).maxHU
        maxHU = new_images(i).maxHU;
    end
    waitbar(i/n)
end
delete(h_w)
if ok
    h.project.images = new_images;
    h.project.minHU = minHU;
    h.project.maxHU = maxHU;
end
guidata(h.mainfigure,h)
setup_multislider_contrast(h)
multislider_contrast_callback(h)
update_image(h.pushbutton_filters_apply,h,h.index,false)

% --Data Extraction--
% -------------------------------

function pushbutton_patientextract_start_Callback(hObject, ~, h)
% Currently only uniform data extract is supported. This should be altered
% to match phantomextract and microextract callbacks if "original extract" is
% to be supported (this extraction method does not interpolate between
% slices).
h_d = please_wait(h,'Working, please wait.');
try

    data = patientextract_uniform(h.project,...
        str2num(get(h.edit_patientextract_startslice,'string')),...
        str2num(get(h.edit_patientextract_endslice,'string')),...
        str2num(get(h.edit_patientextract_L,'string')),...
        str2num(get(h.edit_patientextract_x,'string')),...
        str2num(get(h.edit_patientextract_N,'string')),...
        str2num(get(h.edit_patientextract_spacing,'string')),...
        str2num(get(h.edit_patientextract_pts,'string')),...
        str2num(get(h.edit_patientextract_maski,'string')),...
        get(h.checkbox_patientextract_show,'value'));

catch ME
    delete(h_d)
    rethrow(ME)
end

assignin('base','patientextract',data)
delete(h_d)
msgbox('Successfully saved ''patientextract'' to workspace.')

function pushbutton_phantomextract_start_Callback(hObject, ~, h)
h_d = please_wait(h,'Working, please wait.');
try
    switch get(h.uibuttongroup_phantomextract_feature,'SelectedObject')
        case h.radio_phantomextract_original
            data = phantomextract(h.project,...
                str2num(get(h.edit_phantomextract_startslice,'string')),...
                str2num(get(h.edit_phantomextract_endslice,'string')),...
                str2num(get(h.edit_phantomextract_L,'string')),...
                str2num(get(h.edit_phantomextract_x,'string')),...
                str2num(get(h.edit_phantomextract_maski,'string')),...
                get(h.checkbox_phantomextract_show,'value'),...
                h_d);
        case h.radio_phantomextract_uniform
            data = phantomextract_uniform(h.project,...
                str2num(get(h.edit_phantomextract_startslice,'string')),...
                str2num(get(h.edit_phantomextract_endslice,'string')),...
                str2num(get(h.edit_phantomextract_L,'string')),...
                str2num(get(h.edit_phantomextract_x,'string')),...
                str2num(get(h.edit_phantomextract_N,'string')),...
                str2num(get(h.edit_phantomextract_spacing,'string')),...
                str2num(get(h.edit_phantomextract_maski,'string')),...
                get(h.checkbox_phantomextract_show,'value'),...
                h_d);
    end
catch ME
    delete(h_d)
    rethrow(ME)
end

assignin('base','phantomextract',data)
delete(h_d)
msgbox('Successfully saved ''phantomextract'' to workspace.')

function pushbutton_microextract_microfile_Callback(hObject, ~, h)
fix_ProjectsDirectory(h)
h = guidata(hObject); % Update h structure

[filename, pathname] = uigetfile([h.settings.ProjectsDirectory '\*.akp'],...
    'Select project (.AKP) file.');

if filename == 0 % User cancelled operation
    return
end

% Update relevant settings, unless user cancelled operation:
h.settings.ProjectsDirectory = pathname;

[~,~,ext] = fileparts(filename);
if ~strcmpi(ext,'.akp')
    uiwait(msgbox('You must select a .akp file. File open cancelled.'))
    return
end

set(h.text_microextract_microfile,'string',filename,...
    'UserData',[pathname filename])

function pushbutton_microextract_start_Callback(hObject, ~, h)

file = get(h.text_microextract_microfile,'UserData');

% Try to load micro file, cancel operation otherwise:
try
    h_d = please_wait(h,'Loading micro file, please wait...');
    Mproject = load(file,'-mat');
    if ~all(isfield(Mproject,{'name','n_images','images','minHU','maxHU',...
            'pixel_size','original_images'}))
        throw(MException('AortaKit:BadProject',...
            'There is something wrong with the specified project file.'))
    end
    delete(h_d)
catch ME
    delete(h_d)
    if strcmp(ME.identifier,'AortaKit:BadProject')
        uiwait(msgbox('There was a problem loading this file.'))
        return
    else
        rethrow(ME)
    end
end

% Ensure micro project is consistent, cancel operation otherwise.
if Mproject.n_images ~= length(Mproject.images)
    uiwait(msgbox('There was a problem loading this file.'))
    return
end

h_d = please_wait(h,'Working, please wait.');
try
    switch get(h.uibuttongroup_microextract_feature,'SelectedObject')
        case h.radio_microextract_original
            data = microextract(h.project,Mproject,...
                str2num(get(h.edit_microextract_Cmaski,'string')),...
                str2num(get(h.edit_microextract_Mmaski,'string')),...
                str2num(get(h.edit_microextract_startslice,'string')),...
                str2num(get(h.edit_microextract_endslice,'string')),...
                str2num(get(h.edit_microextract_Mstartslice,'string')),...
                str2num(get(h.edit_microextract_L,'string')),...
                str2num(get(h.edit_microextract_x,'string')),...
                str2num(get(h.edit_microextract_k,'string')),...
                get(h.checkbox_microextract_show,'value'),...
                h_d);
        case h.radio_microextract_uniform
            data = microextract_uniform(h.project,Mproject,...
                str2num(get(h.edit_microextract_Cmaski,'string')),...
                str2num(get(h.edit_microextract_Mmaski,'string')),...
                str2num(get(h.edit_microextract_startslice,'string')),...
                str2num(get(h.edit_microextract_endslice,'string')),...
                str2num(get(h.edit_microextract_Mstartslice,'string')),...
                str2num(get(h.edit_microextract_L,'string')),...
                str2num(get(h.edit_microextract_x,'string')),...
                str2num(get(h.edit_microextract_k,'string')),...
                str2num(get(h.edit_microextract_N,'string')),...
                str2num(get(h.edit_microextract_spacing,'string')),...
                get(h.checkbox_microextract_show,'value'),...
                h_d);
    end
catch ME
    delete(h_d)
    rethrow(ME)
end

assignin('base','microextract',data)
delete(h_d)
msgbox('Successfully saved ''microextract'' to workspace.')

function uibuttongroup_microextract_feature_SelectionChangeFcn(hObject, ~, h)
switch hObject
    case h.radio_microextract_original
        set(h.edit_microextract_spacing,'Enable','off')       
        set(h.edit_microextract_N,'Enable','off')       
    case h.radio_microextract_uniform
        set(h.edit_microextract_spacing,'Enable','on') 
        set(h.edit_microextract_N,'Enable','on')
    case h.radio_microextract_LBP
        set(h.edit_microextract_spacing,'Enable','off') 
        set(h.edit_microextract_N,'Enable','off')
end

function uibuttongroup_phantomextract_feature_SelectionChangeFcn(hObject, ~, h)
switch hObject
    case h.radio_phantomextract_original
        set(h.edit_phantomextract_spacing,'Enable','off')       
        set(h.edit_phantomextract_N,'Enable','off')   
    case h.radio_phantomextract_uniform
        set(h.edit_phantomextract_spacing,'Enable','on')  
        set(h.edit_phantomextract_N,'Enable','on')
    case h.radio_phantomextract_LBP
        set(h.edit_phantomextract_spacing,'Enable','off') 
        set(h.edit_phantomextract_N,'Enable','off')
end

% --Misc. Utilities--
% -------------------------------

function h_d = please_wait(h, message)
% Use this to supply a message box with no close ability.
mainfig_pos = getpixelposition(h.mainfigure);
dialog_size = [500 100]; % width, height in pixels
text_size = [400 20]; % width, height in pixels
dialog_position = [mainfig_pos(1)+(1/2)*mainfig_pos(3)-(1/2)*dialog_size(1)...
    mainfig_pos(2)+(1/2)*mainfig_pos(4)-(1/2)*dialog_size(2)...
    dialog_size(1) dialog_size(2)];
text_position = [(1/2)*dialog_size(1)-(1/2)*text_size(1)...
    (1/2)*dialog_size(2)-(1/2)*text_size(2) text_size(1) text_size(2)];
h_d = dialog('CloseRequestFcn','',...
    'Position', dialog_position, 'WindowStyle','Modal');
uicontrol('Parent', h_d, 'Style', 'text', 'String', message,...
    'FontSize', 12, 'Position', text_position);
drawnow
  
function zoom_ActionPostCallback(~,~,h)
% Update display of arrows:
arrow(h.axes_image)
% It seems above line turns off clipping, turn back on...
set(findobj(h.axes_image,'Tag','Arrow'),'Clipping','on')

function [dcm_files,directory] = select_dcm_folder(h)

fix_ImagesDirectory(h)
h = guidata(h.mainfigure); % Update h structure

OK = false;
while ~OK
% Prompt for working directory, starting at previously used directory:
result = uigetdir(h.settings.ImagesDirectory,...
    'Select folder with dcm images.');
    if result == 0
        dcm_files=[]; directory='';
        return % User cancelled operation, cancel new project.
    elseif good_image_path(result)
        OK = true;
    else
        uiwait(msgbox('Selected directory contains no .dcm images. Try again.'))
    end
end

% Update relevant settings, unless user cancelled operation:
h.settings.ImagesDirectory = result;
guidata(h.mainfigure,h)

dcm_files = dir([result '\*.dcm']);
directory = result;

function fixbox(hBox,h)
% Fix text boxes by reverting to previous value.

udata = get(hBox,'userdata'); % Store previous OK value here as string.

switch hBox
    case h.edit_isolines_start
        set(h.edit_isolines_start,'string',udata)
    case h.edit_isolines_end
        set(h.edit_isolines_end,'string',udata)
    case h.edit_isolines_step
        set(h.edit_isolines_step,'string',udata)
end

function pushbutton_code_Callback(hObject, ~, h)

code = get(h.edit_code,'string');

str = '';
for i = 1:size(code,1)
str = [str,code(i,:),','];
end

eval(str)

function toggletool_exportDCM_Callback(hObject, ~, h)

if ~h.project_loaded
    return
end

fix_exportDCMDirectory(h)
h = guidata(h.mainfigure);

dir = uigetdir(h.settings.exportDCMDirectory);

if dir == 0
    return % User cancelled operation, do nothing.
end

% Update setting:
h.settings.exportDCMDirectory = dir;
guidata(h.mainfigure,h)

h_w = waitbar(0,'Exporting images...');
set(h_w,'CloseRequestFcn','','WindowStyle','modal')

for i = 1:length(h.project.images)
    
    imwrite(mat2gray(h.project.images(i).image,...
                     [h.project.minHU h.project.maxHU]),...
         [dir '\' h.project.name '_' sprintf('%03d',i) '.bmp'])
    
    waitbar(i/length(h.project.images))
end

delete(h_w)
