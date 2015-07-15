clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
date_path = '2015-05-04.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));

% create workers
numCores = 3;
try
    fprintf('Closing any pools...\n');
    matlabpool close;
catch ME
    disp(ME.message);
end
matlabpool('local',numCores);

% compute median images over a time period
data_median = zeros(size(data_mat,'data'),'uint8');
parfor i=1:3
    data_median(:,:,i,:) = computeMedian(squeeze(data_mat.data(:,:,i,:)));
end

% close workers and save file
matlabpool close
fprintf('Saving data_median.mat\n');
save(fullfile(path,'data_median.mat'),'data_median','-v7.3');