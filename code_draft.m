option = struct('begslice',2,'endslice',4,'L',8,'x',7,'N',20,'pts',36,'spacing',1);
directory.img = 'C:\Users\dohuan.ME197\Desktop\AortaKit\Image Samples\P11 S04 AAA';
directory.mask = 'C:\Users\dohuan.ME197\Desktop\AortaKit\Image Samples\P11 S04 AAA Rough Lumen Mask';
data = featureExtract(directory,option);



% --- load data to a single training data set
fieldList{1}='phantomextract1';
