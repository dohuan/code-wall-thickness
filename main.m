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
pixelspacing = [0.6621 0.6621]; % found in dicominfo
dcm_files = dir('./data/P11 S04 AAA/*.dcm');

for i=1:length(dcm_files)
    sliceix = find(test_info(:,1)==str2double(dcm_files(i).name(6:8)));
    if (isempty(sliceix)==0)
        fprintf('Processing slice: %s\n',dcm_files(i).name(6:8));
        img = dicomread(['./data/P11 S04 AAA/' dcm_files(i).name]);
        h=figure(1);
        imagesc(img);
        hold on
        % --- Apply LASSO to find thickness and plot on dcm figure
        
        track_ray = [];
        for j=1:length(sliceix)
            ix = sliceix(j);
            
            [raytmp, wallpoint] = getWallPoint(img,test_info(ix,:));
            track_ray = [track_ray; raytmp'];
            %thickness_est(i,j) = FitObj.B_optimal'*test_x(ix,:)';
            thickness_est(i,j) = predict(FitTree,test_x(ix,:));
            
            thickness_est_pixel = (sqrt(pixelspacing(1)^2+pixelspacing(2)^2))^(-1)...
                *thickness_est(i,j);
            
            point1(1) = wallpoint(1) + cos(test_info(ix,2))*thickness_est_pixel/2;
            point1(2) = wallpoint(2) - sin(test_info(ix,2))*thickness_est_pixel/2;
            point2(1) = wallpoint(1) - cos(test_info(ix,2))*thickness_est_pixel/2;
            point2(2) = wallpoint(2) + sin(test_info(ix,2))*thickness_est_pixel/2;
            
            plot(point1(1),point1(2),'k.','MarkerSize',10);
            plot(point2(1),point2(2),'r.','MarkerSize',10);
        end
        hold off;
        saveName = [dcm_files(i).name(6:8) '.jpg'];
        saveas(h,['./results/' saveName]);
        close(h);
    else
        fprintf('No slice info available!\n');
    end
end

% figure(2)
% hold on
% for i=1:size(thickness_est,1)
%     plot(thickness_est(i,:));
% end









