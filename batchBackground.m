tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
use_gpu_array = false;

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));

% create workers
if(~use_gpu_array)
    try
        fprintf('Closing any pools...\n');
        delete(gcp('nocreate'));
    catch ME
        disp(ME.message);
    end
    local_cluster = parcluster('local');
    num_workers = 3;
    parpool('local',num_workers);
end

% compute background image using image matting
alpha = 0.5;
bg = zeros(size(data_mat,'data'),'uint8');
if(use_gpu_array)
    for i=1:3
        bg(:,:,i,:) = computeBackground(squeeze(data_mat.data(:,:,i,:)),use_gpu_array);
    end
else
    parfor i=1:3
        bg(:,:,i,:) = computeBackground(squeeze(data_mat.data(:,:,i,:)),use_gpu_array);
    end
end
% save file
filename = 'data_bg_mat';
fprintf('Saving %s\n',filename);
save(fullfile(path,filename),'bg','-v7.3');


% close workers
if(~use_gpu_array)
    delete(gcp('nocreate'));
end
toc