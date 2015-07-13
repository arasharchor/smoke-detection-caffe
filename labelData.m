clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
url_path = 'http://tiles.cmucreatelab.org/ecam/timemachines/shenango1/';
date_path = '2015-05-01.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read images
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
fprintf('Loading data.mat / label.mat / info.mat\n');
load(fullfile(path,'info.mat'));
data_mat = matfile(fullfile(path,'data.mat'));
label_mat = matfile(fullfile(path,'label.mat'),'Writable',true);
has_label_mat = matfile(fullfile(path,'has_label.mat'),'Writable',true);

% label images
global t
% t = 4368;
t = 3700;
fig = figure(1);
set(fig,'KeyPressFcn',{@keyDownListener,r_json.frames,data_mat,label_mat,has_label_mat});