tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

target_dir = 'frames';
load(fullfile(target_dir,'data_train.mat'));

% feature information
dimension = 30;

% create workers
try
    fprintf('Closing any pools...\n');
    delete(gcp('nocreate'));
catch ME
    disp(ME.message);
end
local_cluster = parcluster('local');
num_workers = 3;
if(local_cluster.NumWorkers > num_workers + 1)
    num_workers = local_cluster.NumWorkers;
end
if(num_workers>10)
    num_workers = 10;
end
parpool('local',num_workers);

% compute positive features
num_pos_labels = size(data_train.label_pos,4);
idx = 1:num_pos_labels;
feature_pos = zeros(num_pos_labels,dimension);
parfor i=idx
    warning('off','all')
    fprintf('Pos %d\n',i);
    img = data_train.label_pos(:,:,:,i);
    img_bg = data_train.label_pos_bg(:,:,:,i);
    img_pre = data_train.label_pos_pre(:,:,:,i);
    img_pre2 = data_train.label_pos_pre2(:,:,:,i);
    f = computeFeature(img,img_bg,img_pre,img_pre2);
    feature_pos(i,:) = f;
end

% compute negative features
num_neg_labels = size(data_train.label_neg,4);
idx = 1:num_neg_labels;
feature_neg = zeros(num_neg_labels,dimension);
parfor i=idx
    warning('off','all')
    fprintf('Neg %d\n',i);
    img = data_train.label_neg(:,:,:,i);
    img_bg = data_train.label_neg_bg(:,:,:,i);
    img_pre = data_train.label_neg_pre(:,:,:,i);
    img_pre2 = data_train.label_neg_pre2(:,:,:,i);
    f = computeFeature(img,img_bg,img_pre,img_pre2);
    feature_neg(i,:) = f;
end

feature = struct();
feature.pos = feature_pos;
feature.neg = feature_neg;

fprintf('Saving feature\n');
save(fullfile(target_dir,'feature.mat'),'feature','-v7.3');

% close workers
delete(gcp('nocreate'));
fprintf('Done\n');
toc