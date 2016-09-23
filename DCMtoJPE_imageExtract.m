directory = 'E:\AortaKit\Image Samples\P11 S04 AAA';
saveDir   = 'E:\AortaKit\Image Samples\P11 S04 AAA JPG';
option = struct('begslice',1,'endslice',10,'L',8,'x',3,'N',20,'pts',36,'spacing',1);
project = load_images(directory);
for i=1:length(project.images)
    figure(1)
    imshow();
end