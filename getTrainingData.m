clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

date = {
    '2015-05-01','2015-05-02','2015-05-03',...
    '2015-05-04','2015-05-05','2015-05-06','2015-05-07','2015-05-08','2015-05-09',...
    '2015-04-02','2015-05-28','2015-06-11','2015-07-08','2015-08-13','2015-09-09','2015-10-05','2015-11-15',...
    '2015-04-13','2015-05-15','2015-06-15','2015-07-26','2015-08-24','2015-09-19','2015-10-19','2015-11-26'};

output_label = true;

% read mask
target_dir = 'frames';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';
fprintf('Loading bbox.mat\n');
load(fullfile(target_dir,'bbox.mat'));

% seperate the bbox into 4x4 tiles
num_row_tiles = 4;
num_col_tiles = 4;
num_tiles = num_row_tiles*num_col_tiles;
col_size = numel(bbox_col)/num_col_tiles;
row_size = numel(bbox_row)/num_row_tiles;
tile_col = mat2cell(bbox_col,1,[col_size,col_size,col_size,col_size]);
tile_row = mat2cell(bbox_row,1,[row_size,row_size,row_size,row_size]);

% find positive and negative label idx
num_pos_labels = 0;
num_neg_labels = 0;
label_pos_idx = cell(numel(date),1);
label_neg_idx = cell(numel(date),1);
for idx=1:numel(date)
    idx
    % set data source
    date_path = [date{idx},'.timemachine/'];
    path = fullfile(target_dir,date_path,dataset_path,tile_path);
    % read ground truth labels
    load(fullfile(path,'label_simple.mat'));
    % read prediction
    load(fullfile(path,'label_predict.mat'));
    % read sum frames
    load(fullfile(path,'sun_frame.mat'));
    % find frames having positive labels
    true_label_idx = find(label_simple>1);
    num_true_label_idx = numel(true_label_idx);
    for i=1:num_true_label_idx
        tile_predict = mat2cell(label_predict(:,:,1,true_label_idx(i)),[31,31,31,31],[33,33,33,33]);
        is_smoke_tile = cellfun(@findSmokeTile,tile_predict,'UniformOutput',false);
        is_smoke_tile = cell2mat(is_smoke_tile);
        smoke_tiles = find(is_smoke_tile==1);
        num_pos_labels = num_pos_labels + numel(smoke_tiles);
        for j=1:numel(smoke_tiles)
            label_pos_idx{idx}(end+1,:) = [true_label_idx(i);smoke_tiles(j)];
        end
    end
    % find frames having negative labels
    false_label_idx = find(label_simple==0);
    false_label_idx(false_label_idx<sunrise_frame) = [];
    false_label_idx(false_label_idx>sunset_frame) = [];
    num_false_label_idx = numel(false_label_idx);
    step = round(num_false_label_idx/num_true_label_idx*7);
    for i=1:step:num_false_label_idx
        num_neg_labels = num_neg_labels + num_tiles;
        label_neg_idx{idx}(end+1:end+num_tiles,:) = [ones(num_tiles,1)*false_label_idx(i) (1:num_tiles)'];
    end
end

if(output_label)
    % initialize positive labels
    label_pos = zeros(row_size,col_size,3,num_pos_labels,'uint8');
    label_pos_bg = zeros(row_size,col_size,3,num_pos_labels,'uint8');
    label_pos_pre = zeros(row_size,col_size,3,num_pos_labels,'uint8');
    label_pos_pre2 = zeros(row_size,col_size,3,num_pos_labels,'uint8');
    ptr_pos = 1;
    % initialize negative labels
    label_neg = zeros(row_size,col_size,3,num_neg_labels,'uint8');
    label_neg_bg = zeros(row_size,col_size,3,num_neg_labels,'uint8');
    label_neg_pre = zeros(row_size,col_size,3,num_neg_labels,'uint8');
    label_neg_pre2 = zeros(row_size,col_size,3,num_neg_labels,'uint8');
    ptr_neg = 1;
    for idx = 1:numel(date)
        idx
        % set data source
        date_path = [date{idx},'.timemachine/'];
        % read frames
        path = fullfile(target_dir,date_path,dataset_path,tile_path);
        data_mat = matfile(fullfile(path,'data.mat'));
        data_median_mat = matfile(fullfile(path,'data_median_60.mat'));
        % construct positive labels
        for k = 1:size(label_pos_idx{idx},1)
            current_frame = label_pos_idx{idx}(k,1);
            tile_idx = label_pos_idx{idx}(k,2);
            [i,j] = ind2sub([4,4],tile_idx);
            imgs = data_mat.data(tile_row{i},tile_col{j},:,current_frame-2:current_frame);
            img_bg = data_median_mat.median(tile_row{i},tile_col{j},:,current_frame);
            label_pos(:,:,:,ptr_pos) = imgs(:,:,:,3);
            label_pos_pre(:,:,:,ptr_pos) = imgs(:,:,:,2);
            label_pos_pre2(:,:,:,ptr_pos) = imgs(:,:,:,1);
            label_pos_bg(:,:,:,ptr_pos) = img_bg;
            ptr_pos = ptr_pos + 1;
        end
        % construct negative labels
        for k = 1:size(label_neg_idx{idx},1)
            current_frame = label_neg_idx{idx}(k,1);
            tile_idx = label_neg_idx{idx}(k,2);
            [i,j] = ind2sub([4,4],tile_idx);
            imgs = data_mat.data(tile_row{i},tile_col{j},:,current_frame-2:current_frame);
            img_bg = data_median_mat.median(tile_row{i},tile_col{j},:,current_frame);
            label_neg(:,:,:,ptr_neg) = imgs(:,:,:,3);
            label_neg_pre(:,:,:,ptr_neg) = imgs(:,:,:,2);
            label_neg_pre2(:,:,:,ptr_neg) = imgs(:,:,:,1);
            label_neg_bg(:,:,:,ptr_neg) = img_bg;
            ptr_neg = ptr_neg + 1;
        end
    end

    data_train = struct();
    data_train.label_pos = label_pos;
    data_train.label_pos_bg = label_pos_bg;
    data_train.label_pos_pre = label_pos_pre;
    data_train.label_pos_pre2 = label_pos_pre2;
    data_train.label_neg = label_neg;
    data_train.label_neg_bg = label_neg_bg;
    data_train.label_neg_pre = label_neg_pre;
    data_train.label_neg_pre2 = label_neg_pre2;
    
    fprintf('Saving training data\n');
    save(fullfile(target_dir,'data_train.mat'),'data_train','-v7.3');
    fprintf('Done\n');
end