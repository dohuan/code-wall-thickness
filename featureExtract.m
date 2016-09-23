function out = featureExtract(directory,option)
%%                           Author Huan Do and Bara
tic
% directory.img : dir of images
% directory.mask : dir of masks

% example:
% option = struct('begslice',1,'endslice',10,'L',8,'x',3,'N',20,'pts',36,'spacing',1);
% directory.img = 'C:\Users\dohuan.ME197\Desktop\AortaKit\Image Samples\P11 S04 AAA';
% directory.mask = 'C:\Users\dohuan.ME197\Desktop\AortaKit\Image Samples\P11 S04 AAA Rough Lumen Mask';
% data = featureExtract(directory,option);

% --- Load project
project = load_images(directory.img);
project = load_mimics(directory.mask,project);

out = patientextract_uniform(project,option.begslice,option.endslice,...
    option.L,option.x,option.N,option.spacing,option.pts,1,false);

collapsedtime = toc;
fprintf('Collapsed time: %.2f (mins)\n',collapsedtime/60);
end

function project = load_mimics(dcm_dir,project)
tmp = load_images(dcm_dir);
images = tmp.images;
% --- Error check
if length(images) ~= length(project.images)
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

project = new_mask(BW,project);
end

function project = new_mask(BW,project)
% Add a new mask to the project, does not do error checking on the
% provided mask data (BW)! Must be same dimensions as loaded image set.

% for new mask, add 1 to max id (or set to 1 if no masks):
% if isfield(h.project,'masks')
%     id = int16(max([h.project.masks.id]) + 1);
% else id = [];
% end
% if ~isempty(id)
%     name = ['mask',num2str(id)];
% else
%     id = 1;
%     name = 'mask1';
% end

% color = next_mask(guidata(h.mainfigure));
% Update h:
% h = guidata(h.mainfigure);

id = 1; % mask ID,
color = gray(256);
name = 'mask';
new_mask_ = struct('id',id,'data',{BW},'color',color,'visible',true,...
    'select',false,'name',name);
if ~isfield(project,'masks')
    project.masks = new_mask_;
else
    project.masks = vertcat(project.masks,new_mask_);
end
end