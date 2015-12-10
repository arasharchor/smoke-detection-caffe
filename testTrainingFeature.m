tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

target_dir = 'frames';
load(fullfile(target_dir,'data_train.mat'));

% feature information
[~,dimension] = computeFeature();

% compute positive features
idx = 100;
for i=idx
    warning('off','all')
    fprintf('Pos %d\n',i);
    img = data_train.label_pos(:,:,:,i);
    img_bg = data_train.label_pos_bg(:,:,:,i);
    img_pre = data_train.label_pos_pre(:,:,:,i);
    img_pre2 = data_train.label_pos_pre2(:,:,:,i);
    f = computeFeature(img,img_bg,img_pre,img_pre2,true);
end

toc