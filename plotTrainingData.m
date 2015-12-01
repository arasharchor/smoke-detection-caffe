clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

target_dir = 'frames';
load(fullfile(target_dir,'data_train.mat'));

imdisp(data_train.label_pos(:,:,:,1:10:2000),'Border',[0.01,0.01],'Size',[9,20]);