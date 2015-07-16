clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
fprintf('Loading data.mat\n');
load(fullfile(path,'data.mat'));
data_median_60_mat = matfile(fullfile(path,'data_median_60.mat'));
data_median_120_mat = matfile(fullfile(path,'data_median_120.mat'));
data_median_360_mat = matfile(fullfile(path,'data_median_360.mat'));
data_median_720_mat = matfile(fullfile(path,'data_median_720.mat'));

% read mask
fprintf('Loading bbox.mat\n');
load(fullfile(path,'bbox.mat'));

% crop images
fprintf('Cropping images\n');
data = data(bbox_row,bbox_col,:,:);

% allocate spaces
num_imgs = size(data,4);
responses_all = cell(num_imgs,1);

% create workers
numCores = 3;
try
    fprintf('Closing any pools...\n');
    matlabpool close;
catch ME
    disp(ME.message);
end
matlabpool('local',numCores);

parfor t=3:num_imgs
    fprintf('Processing frame %d\n',t);
    img = data(:,:,:,t);
    imgs_bg = zeros([size(img),4],'uint8');
    imgs_bg(:,:,:,1) = data_median_60_mat.median(bbox_row,bbox_col,:,t);
    imgs_bg(:,:,:,2) = data_median_120_mat.median(bbox_row,bbox_col,:,t);
    imgs_bg(:,:,:,3) = data_median_360_mat.median(bbox_row,bbox_col,:,t);
    imgs_bg(:,:,:,4) = data_median_720_mat.median(bbox_row,bbox_col,:,t);
    [responses,~] = detectSmoke(img,imgs_bg);
    responses_all{t} = responses;
end

% close workers
matlabpool close

% process features
fprintf('Computing feature vector\n');
fields = fieldnames(responses_all{3});
for i=1:length(fields)
    feature.(fields{i}) = zeros(num_imgs,1);
end
for j=3:num_imgs
    for k=1:length(fields)
        feature.(fields{k})(j) = responses_all{j}.(fields{k});
    end
end

% save file
fprintf('Saving feature.mat\n');
save(fullfile(path,'feature_smoke.mat'),'feature');
fprintf('Done\n');