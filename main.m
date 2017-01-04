close all
clear
clc
set(0,'defaultfigurecolor',[1 1 1])
%%
load ./data/data_train
% --- use 50-25-25 for train-validate-test, randomly selected
ix = randperm(length(train_y));
cutix = round(.75*length(train_y));
train.x = train_x(ix(1:cutix),:);
train.y = train_y(ix(1:cutix),1);
test.x = train_x(ix(cutix+1:end),:);
test.y = train_y(ix(cutix+1:end),1);

% --- Use LASSO
% [FitObj,y_train_eval,y_test_eval] = ...
%     lassoRegression(train.x,train.y,test.x,test.y,.6);
% fprintf('RMSE of LASSO: %.2f\n',rmseCal(y_test_eval,test.y));

% --- Use REP tree
FitTree = fitctree(train.x,train.y);
y_test_tree = predict(FitTree,test.x);
fprintf('RMSE of REP tree: %.2f\n',rmseCal(y_test_tree,test.y));

%% Apply to human data

load ./data/data_human
% test_info: slice (1) angle (2) centroid (3 4) point (5 6)
dcm_files = dir('./data/P11 S04 AAA/*.dcm');
dump_dir = './data/dicomTopngDump/';
wall.inner = [];
wall.outer = [];

for i=1:length(dcm_files)
    sliceix = find(test_info(:,1)==str2double(dcm_files(i).name(6:8)));
    if (isempty(sliceix)==0)
        fprintf('Processing slice: %s\n',dcm_files(i).name(6:8));
        % --- stupid code here but it works!
        img = dicomread(['./data/P11 S04 AAA/' dcm_files(i).name]);
        dinfo = dicominfo(['./data/P11 S04 AAA/' dcm_files(i).name]);
        pixelspacing = dinfo.PixelSpacing;
        pixelspacingunified = (sqrt(pixelspacing(1)^2+pixelspacing(2)^2))^(-1);
        
        image8 = uint8(255 * mat2gray(img));
        imwrite(image8,[dump_dir dcm_files(i).name '.png']);
        img = imread([dump_dir dcm_files(i).name '.png']);
        img = im2double(img);
        
        h=figure(1);
        %imagesc(img);
        imshow(img);
        hold on
        % --- Apply regression to find thickness and plot on dcm figure
        
        %track_ray = [];
        point2Dinner = [];
        point2Douter = [];
        for j=1:length(sliceix)
            ix = sliceix(j);
            J = regiongrowing(img,round(test_info(ix,3)),round(test_info(ix,4)),0.2);
            [~, wallpoint] = getWallPoint(J,test_info(ix,:));
            %track_ray = [track_ray; raytmp'];
            %thickness_est(i,j) = FitObj.B_optimal'*test_x(ix,:)';
            thickness_est = predict(FitTree,test_x(ix,:));
            
            
            thickness_est_pixel = pixelspacingunified*thickness_est;
            
            point1(1) = wallpoint(1) + cos(test_info(ix,2))*thickness_est_pixel/2;
            point1(2) = wallpoint(2) - sin(test_info(ix,2))*thickness_est_pixel/2;
            point2(1) = wallpoint(1) - cos(test_info(ix,2))*thickness_est_pixel/2;
            point2(2) = wallpoint(2) + sin(test_info(ix,2))*thickness_est_pixel/2;
            
            %plot(point1(1),point1(2),'k.','MarkerSize',10); % outer
            %plot(point2(1),point2(2),'r.','MarkerSize',10); % inner
            
            wall.inner = [wall.inner;...
                [point2*pixelspacingunified dinfo.SliceLocation]];
            wall.outer = [wall.outer;...
                [point1*pixelspacingunified dinfo.SliceLocation]];
            point2Dinner  = [point2Dinner; point2];
            point2Douter  = [point2Douter; point1];
        end
        % --- Plot contour on image
        plot([point2Dinner(:,1); point2Dinner(1,1)],[point2Dinner(:,2);...
            point2Dinner(1,2)],'y-','LineWidth',2);
        plot([point2Douter(:,1); point2Douter(1,1)],[point2Douter(:,2);...
            point2Douter(1,2)],'y:','LineWidth',2);
        hold off;
        saveName = [dcm_files(i).name(6:8)];
        saveas(h,['./results/fig/' saveName '.fig']);
        saveas(h,['./results/jpg/' saveName '.jpg']);
        %hc = imcrop(h,[200 200 120 70]);
        %saveas(hc,['./results/crop/' saveName '.jpg']);
        close(h);
    else
        fprintf('No slice info available!\n');
    end
end

% --- save wall as point cloud
save('results/wall','wall');

% figure(2)
% hold on
% for i=1:size(thickness_est,1)
%     plot(thickness_est(i,:));
% end









