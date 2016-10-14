option = struct('begslice',2,'endslice',4,'L',8,'x',7,'N',20,'pts',36,'spacing',1);
directory.img = 'C:\Users\dohuan.ME197\Desktop\AortaKit\Image Samples\P11 S04 AAA';
directory.mask = 'C:\Users\dohuan.ME197\Desktop\AortaKit\Image Samples\P11 S04 AAA Rough Lumen Mask';
data = featureExtract(directory,option);



% --- load porcine and phantom data to a single training data set
fieldList{1}='phantomextract1';
fieldList{2}='phantomextract2';
fieldList{3}='microextractremeasured11';
fieldList{4}='microextractremeasured12';
fieldList{5}='microextractremeasured21';
fieldList{6}='microextractremeasured22';
fieldList{7}='microextractremeasured31';
fieldList{8}='microextractremeasured32';
fieldList{9}='microextractremeasured41';
fieldList{10}='microextractremeasured42';
fieldList{11}='microextractremeasured51';
fieldList{12}='microextractremeasured52';
train_x = [];
train_y = [];
for i=1:length(fieldList)
	h = eval(fieldList{i});
	for j=1:length(h)
		train_x = [train_x; zscore(h(j).array(:))'];
		train_y = [train_y; h(j).thickness];
	end
end
% --- delete NaN values from train_y
delix = find(isnan(train_y)==1);
train_y(delix) = [];
train_x(delix,:) = [];
save('./data/data_train','train_x','train_y');





% --- Load human data
test_x = [];
test_info = []; % slice (1) angle (1) centroid (2) point (2)
for k=1:length(patientextract)
	if (length(patientextract(k).point)>2)
		fprintf('Discarded\n');
	else
		tmparray = patientextract(k).array(:,:,1:18); % strim down to match porcine and phantom
		test_x = [test_x; zscore(tmparray(:))'];
		tmp=[patientextract(k).slice, patientextract(k).angle, patientextract(k).centroid, patientextract(k).point];
		test_info = [test_info; tmp];
	end
end



figure(1)
hold on
plot(xc,yc,'r.');
for i=1:size(xtrack,1)
	plot(xtrack(i),ytrack(i),'k.');
end














