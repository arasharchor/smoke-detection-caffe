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
fprintf('Loading data_median_60.mat\n');
data_median_60 = load(fullfile(path,'data_median_60.mat'));
fprintf('Loading data_median_120.mat\n');
data_median_120 = load(fullfile(path,'data_median_120.mat'));
fprintf('Loading data_median_360.mat\n');
data_median_360 = load(fullfile(path,'data_median_360.mat'));
fprintf('Loading data_median_720.mat\n');
data_median_720 = load(fullfile(path,'data_median_720.mat'));

% read mask
fprintf('Loading bbox.mat\n');
load(fullfile(path,'bbox.mat'));

% crop all images
fprintf('Cropping images\n');
data = data(bbox_row,bbox_col,:,:);
data_median_60.median = data_median_60.median(bbox_row,bbox_col,:,:);
data_median_120.median = data_median_120.median(bbox_row,bbox_col,:,:);
data_median_360.median = data_median_360.median(bbox_row,bbox_col,:,:);
data_median_720.median = data_median_720.median(bbox_row,bbox_col,:,:);

% allocate spaces
num_imgs = size(data,4);
responses_all = cell(num_imgs,1);

% create workers
numCores = 12;
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
    imgs_bg(:,:,:,1) = data_median_60.median(:,:,:,t);
    imgs_bg(:,:,:,2) = data_median_120.median(:,:,:,t);
    imgs_bg(:,:,:,3) = data_median_360.median(:,:,:,t);
    imgs_bg(:,:,:,4) = data_median_720.median(:,:,:,t);
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