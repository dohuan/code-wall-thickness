%function [images, minHU, maxHU, pixel_size] = load_images(dcm_files, directory)
function out = load_images(directory)
% Load dcm images listed in dcm_files (output of dir function) from
% directory. Returns a struct w/ fields image, location, minHU, maxHU.
% Also returns global minHU and maxHU found in the image set.
dcm_files = dir([directory '/*.dcm']);
minHU = 0; maxHU = 0;
fprintf('Loading images...\n');
%h_w = waitbar(0,'Loading images...');
%set(h_w,'CloseRequestFcn','','WindowStyle','modal')
images = cell(0);
j = 1;
for i = 1:length(dcm_files)
    if ~dcm_files(i).isdir
        % Read image and dicom tags:
        % (convert image to int16 to allow negative HU values)
        im = int16(dicomread([directory '/' dcm_files(i).name]));
        info = dicominfo([directory '/' dcm_files(i).name]);
        
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

%waitbar(1.1/1.3,h_w,'Sorting Images...')
fprintf('Sorting Images...\n');
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
info = dicominfo([directory '/' dcm_files(i).name]);
pixel_size = info.PixelSpacing(1);

%delete(h_w)

out.original_images = images;
out.images = images;
out.minHU = minHU;
out.maxHU = maxHU;
out.pixel_size = pixel_size;
out.n_images = length(images);

end