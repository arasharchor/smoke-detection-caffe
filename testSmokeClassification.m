tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
warning('off','all')

% black smoke
t = 5936;
% t = 7543;
% t = 6613;
% gray smoke
% t = 7298;
% t = 7438;
% t = 6617;
% t = 7435;
% steam + smoke
% t = 5108;
% t = 4369;
% shadow + steam
% t = 6205;
% t = 4847;
% white smoke
% t = 12929;
% t = 12566;
% steam
% t = 5969;
% t = 4406;
% t = 4544;
% shadow
% t = 4847;
% t = 4853;
% t = 9776;
% t = 9007;
% t = 9778;
% t = 9010;
% t = 9011;
% t = 10312;
% t = 10523;
% nothing
% t = 7000;
% t = 7111;
% t = 7577;

date = getProcessingDates();

% load classifier
target_dir = 'frames';
fprintf('Loading classifier...\n');
load(fullfile(target_dir,'smoke_classifier.mat'));

% read mask
target_dir = 'frames';
fprintf('Loading bbox.mat\n');
load(fullfile(target_dir,'bbox.mat'));

% tile information
num_row_tiles = 4;
num_col_tiles = 4;
num_tiles = num_row_tiles*num_col_tiles;

% seperate the bbox into 4x4 tiles
[tile_col,tile_row] = tileBbox(bbox_col,bbox_row,num_row_tiles,num_col_tiles);

% feature information
dimension = 30;

for idx=1:numel(t)
    current_frame = t(idx);
    
    % set data source
    date_path = '2015-05-02.timemachine/';
    dataset_path = 'crf26-12fps-1424x800/';
    tile_path = '1/2/2.mp4';
    
    % read frames
    path = fullfile(target_dir,date_path,dataset_path,tile_path);
    data_mat = matfile(fullfile(path,'data.mat'));
    data_median_mat = matfile(fullfile(path,'data_median_60.mat'));
    
    % get image data and compute features
    feature = ones(num_tiles,dimension);
    imgs = data_mat.data(:,:,:,current_frame-2:current_frame);
    img_bg = data_median_mat.median(:,:,:,current_frame);
    tic
    for k=1:num_tiles
        [i,j] = ind2sub([num_row_tiles,num_col_tiles],k);
        img_tile = imgs(tile_row{i},tile_col{j},:,end);
        img_pre_tile = imgs(tile_row{i},tile_col{j},:,end-1);
        img_pre2_tile = imgs(tile_row{i},tile_col{j},:,end-2);
        img_bg_tile = img_bg(tile_row{i},tile_col{j},:);
        f = computeFeature(img_tile,img_bg_tile,img_pre_tile,img_pre2_tile);
        f = normalizeFeature(f,feature_max,feature_min);
        feature(k,:) = f;
    end
    toc
    
    % classification
    label_test = ones(num_tiles,1);
    label_predict = svmpredict(label_test,feature,smoke_classifier);
    
    % visualization
    fig = figure(999);
    img_cols = 4;
    img_rows = 4;
    fig_idx = 1;
    option = 'smallGraph2';
    
    order = [1,2,3,4;5,6,7,8;9,10,11,12;13,14,15,16];
    for k=1:numel(order)
        [i,j] = ind2sub([num_row_tiles,num_col_tiles],order(k));
        img_tile = imgs(tile_row{i},tile_col{j},:,end);
        
        I = img_tile;
        str = num2str(label_predict(order(k))==1);
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
    end
end