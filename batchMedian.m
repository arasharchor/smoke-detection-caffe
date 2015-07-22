tic
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
data_mat = matfile(fullfile(path,'data.mat'));

% create workers
try
    fprintf('Closing any pools...\n');
    delete(gcp('nocreate'));
catch ME
    disp(ME.message);
end
local_cluster = parcluster('local');
num_workers = 3;
parpool('local',num_workers);

% compute median images over a time period
% ranges = [60,120,360,720]; % 5min,10min,30min,60min
ranges = [60]; % 5min
for j=1:length(ranges)
    median = zeros(size(data_mat,'data'),'uint8');
    parfor i=1:3
        median(:,:,i,:) = computeMedian(squeeze(data_mat.data(:,:,i,:)),ranges(j));
    end
    % save file
    filename = ['data_median_',num2str(ranges(j)),'.mat'];
    fprintf('Saving %s\n',filename);
    save(fullfile(path,filename),'median','-v7.3');
end

% close workers
delete(gcp('nocreate'));
toc