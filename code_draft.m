option = struct('begslice',2,'endslice',4,'L',8,'x',7,'N',20,'pts',36,'spacing',1);
directory.img = 'E:\AortaKit\Image Samples\P11 S04 AAA';
directory.mask = 'E:\AortaKit\Image Samples\P11 S04 AAA Rough Lumen Mask';
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



% --- test some filter
vector = 5*(1+cosd(1:3:180)) + 2 * rand(1, 60);
plot(vector, 'r-', 'linewidth', 3);
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(5);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
secondDFilter = [-1,2,-1];
vector_{1} = conv(vector, gaussFilter);
vector_{2} = conv(vector, secondFilter);


% --- test track_ray
figure(2)
hold on
for k=1:size(track_ray,1)
plot(track_ray(k,:))
end

figure(3)
hold on
for k=1:size(track_ray,1)
plot(gradient(track_ray(k,:)))
end

figure(4)
secondDFilter = [-1,2,-1];
hold on
for k=1:size(track_ray,1)
	tmp = conv(track_ray(k,:),secondDFilter);
	plot(tmp(2:end-1));
end


% --- test region growing
%img = im2double(imread('medtest.png'));
%x=198; y=359;
I=im2double(I);
%x=round(test_info(ix,3)); y=round(test_info(ix,4));
x=258; y=245;
J = regiongrowing(I,x,y,0.2); 
figure(1)
imshow(I+J);
hold on
plot(x,y,'r.','MarkerSize',3);


% --- test convert dicom to other image type
[img, ~] = dicomread(['./data/P11 S04 AAA/' dcm_files(i).name]);
image8 = uint8(255 * mat2gray(img));



% --- Plot a slice of 3-D AAA inner wall
z_slice = unique(wall.inner(:,end),'rows','stable');
hold on
for i=1:8:size(z_slice,1)
	%figure(i);
	index_slice = find(wall.inner(:,3)==z_slice(i));
	S_plot = wall.inner(index_slice,:);
	S_plot2 = wall.outer(index_slice,:);
	scatter3(S_plot(:,1),S_plot(:,2),S_plot(:,3),'b*');
	scatter3(S_plot2(:,1),S_plot2(:,2),S_plot2(:,3),'ro');
	%S_plot = predict.S_est(index_slice,1:2);
	%plot(S_plot(:,1),S_plot(:,2),'bo');
end
hold off

