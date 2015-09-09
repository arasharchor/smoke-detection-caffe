tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
date_path = '2015-05-01.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
fprintf('Loading data.mat\n');
data = load(fullfile(path,'data.mat'));
fprintf('Loading data_median_60.mat\n');
data_median = load(fullfile(path,'data_median_60.mat'));

% read mask
fprintf('Loading bbox.mat\n');
load(fullfile(path,'bbox.mat'));

% compute filter bank (Laws' texture energy measures)
filter_bank = getFilterbank();

% crop images
fprintf('Cropping images\n');
data = data.data(bbox_row,bbox_col,:,:);
data_median = data_median.median(bbox_row,bbox_col,:,:);

% allocate spaces
num_imgs = size(data,4);
response = zeros(num_imgs,1);
label_predict = false(size(data,1),size(data,2),1,size(data,4));
has_label_predict = false(1,size(data,4));

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
if(num_workers>12)
    num_workers = 12;
end
parpool('local',num_workers);

[day_min_idx,day_max_idx] = getDayIdx();
parfor t=day_min_idx:day_max_idx
    fprintf('Processing frame %d\n',t);
    span = getTemporalSpan();
    imgs = data(:,:,:,t-span:span:t);
    img_bg = data_median(:,:,:,t);
    imgs_fd = imgs(:,:,:,1);
    [val,imgs_filtered] = detectSmoke3(imgs(:,:,:,2),img_bg,filter_bank,imgs_fd);
    response(t) = val;
    label_predict(:,:,:,t) = imgs_filtered.BRF;
    if(val>0)
        has_label_predict(t) = true;
    end
end

% close workers
delete(gcp('nocreate'));

% save file
fprintf('Saving response.mat\n');
save(fullfile(path,'response.mat'),'response','-v7.3');
fprintf('Saving label_predict.mat\n');
save(fullfile(path,'label_predict.mat'),'label_predict','-v7.3');
fprintf('Saving has_label_predict.mat\n');
save(fullfile(path,'has_label_predict.mat'),'has_label_predict','-v7.3');
fprintf('Done\n');
toc