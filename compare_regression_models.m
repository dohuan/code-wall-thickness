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
[FitObj,y_train_eval,y_test_eval] = ...
    lassoRegression(train.x,train.y,test.x,test.y,.6);

% --- Use REP tree in Matlab
FitTree = fitctree(train.x,train.y);
y_test_tree = predict(FitTree,test.x);


% --- Use J48 Decision Tree in WEKA
%% Initializing 
% adding the path to matlab2weka codes
addpath([pwd filesep 'matlab2weka']);
% adding Weka Jar file
if strcmp(filesep, '\')% Windows    
    javaaddpath('C:\Program Files\Weka-3-6\weka.jar');
elseif strcmp(filesep, '/')% Mac OS X
    javaaddpath('/Applications/weka-3-6-12/weka.jar')
end
% adding matlab2weka JAR file that converts the matlab matrices (and cells)
% to Weka instances.
javaaddpath([pwd '\code-wall-thickness' filesep 'matlab2weka' filesep 'matlab2weka.jar']);

classifier = 2;
featName = {};
for i=1:size(train_x,2)
    featName = [featName; num2str(i)];
end
K = 10;
N = size(train_x,1);
% --- indices for cross validation
idxCV = ceil(rand([1 N])*K); 
rmseTrack = zeros(K,1);
for k=1:K
    feature_train = train_x(idxCV ~= k,:);
    class_train = train_y(idxCV ~= k,1);
    feature_test = train_x(idxCV == k,:);
    class_test = train_y(idxCV == k,1);
    [actual_tmp, predicted_tmp, stdDev_tmp] = ...
        wekaRegression(feature_train, class_train, ...
        feature_test, class_test, featName, classifier);
    rmseTrack(k,1) = rmseCal(actual_tmp,predicted_tmp);
    clear feature_train class_train feature_test class_test
    clear actual_tmp predicted_tmp probDistr_tmp
end







% --- Print out result
fprintf('RMSE of LASSO: %.2f\n',rmseCal(y_test_eval,test.y));
fprintf('RMSE of REP tree in Matlab: %.2f\n',rmseCal(y_test_tree,test.y));
fprintf('RMSE of J48 Decision Tree in WEKA: %.2f\n',mean(rmseTrack));



