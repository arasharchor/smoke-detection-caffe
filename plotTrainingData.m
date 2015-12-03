clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

target_dir = 'frames';
load(fullfile(target_dir,'data_train.mat'));

figure(1)
imdisp(data_train.label_pos(:,:,:,datasample(1:size(data_train.label_pos,4),180)),'Border',[0.01,0.01],'Size',[9,20]);

figure(2)
imdisp(data_train.label_neg(:,:,:,datasample(1:size(data_train.label_neg,4),180)),'Border',[0.01,0.01],'Size',[9,20]);
