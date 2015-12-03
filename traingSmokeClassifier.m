tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

target_dir = 'frames';
load(fullfile(target_dir,'feature.mat'));

% seperate data into 10 folds
num_folds = 10;
num_pos = size(feature.pos,1);
num_neg = size(feature.neg,1);
fold_size_pos = round(num_pos/10);
fold_size_neg = round(num_neg/10);
fold_pos = mat2cell(feature.pos,[fold_size_pos*ones(1,9),num_pos-fold_size_pos*9]);
fold_neg = mat2cell(feature.neg,[fold_size_neg*ones(1,9),num_neg-fold_size_neg*9]);

% cross validation
accuracy_all = zeros(num_folds,1);
for i=1:num_folds
    fprintf('Fold %d\n',i);
    
    feature_test = [fold_pos{i};fold_neg{i}];
    label_test = [ones(size(fold_pos{i},1),1);-ones(size(fold_neg{i},1),1)];
    idx = 1:num_folds;
    idx(idx==i) = [];
    feature_pos_train = cell2mat(fold_pos(idx));
	feature_neg_train = cell2mat(fold_neg(idx));
    feature_train = [feature_pos_train;feature_neg_train];
    label_train = [ones(size(feature_pos_train,1),1);-ones(size(feature_neg_train,1),1)];
    
    % scale training data to range [0,1]
	[feature_train,feature_max,feature_min] = scaleFeature(feature_train);
    
    % scale testing data
    feature_test = normalizeFeature(feature_test,feature_max,feature_min);
    
    % train a SVM
    model = svmtrain(label_train,feature_train,'-s 0 -t 2 -c 1 -g 0.07');
    
    % compute testing accuracy
    [label_predict,accuracy,decision_values] = svmpredict(label_test,feature_test,model);
    accuracy_all(i) = accuracy(1);
end

accuracy_avg = mean(accuracy_all)
fprintf('Done');
toc