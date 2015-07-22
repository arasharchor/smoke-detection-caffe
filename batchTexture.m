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

% create workers
numCores = 3;
try
    fprintf('Closing any pools...\n');
    delete(gcp('nocreate'));
catch ME
    disp(ME.message);
end
parpool('local',numCores);

% compute texture for every image
texture = zeros(size(data),'uint8');
parfor t=1:size(data,4)
    fprintf('Processing frame %d\n',t);
    img_lcn = mat2gray(localnormalize(double(data(:,:,:,t)),64,64));
    texture(:,:,:,t) = im2uint8(mat2gray(entropyfilt(img_lcn,true(9,9))));
end

% save file
filename = 'texture.mat';
fprintf('Saving %s\n',filename);
save(fullfile(path,filename),'texture','-v7.3');

% close workers
delete(gcp('nocreate'));