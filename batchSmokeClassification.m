tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

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

% create workers
% try
%     fprintf('Closing any pools...\n');
%     delete(gcp('nocreate'));
% catch ME
%     disp(ME.message);
% end
% local_cluster = parcluster('local');
% num_workers = 3;
% if(local_cluster.NumWorkers > num_workers + 1)
%     num_workers = local_cluster.NumWorkers;
% end
% if(num_workers>10)
%     num_workers = 10;
% end
% parpool('local',num_workers);

for idx=1:numel(date)
    try
        % set data source
        date_path = [date{idx},'.timemachine/'];
        dataset_path = 'crf26-12fps-1424x800/';
        tile_path = '1/2/2.mp4';
        
        % read frames
        path = fullfile(target_dir,date_path,dataset_path,tile_path);
        fprintf('Loading data.mat of %s\n',date{idx});
        data = load(fullfile(path,'data.mat'));
        fprintf('Loading data_median_60.mat of %s\n',date{idx});
        data_median = load(fullfile(path,'data_median_60.mat'));
        
        % allocate spaces
        num_imgs = size(data,4);
        label_predict_classifier = zeros(num_imgs,1);

        load(fullfile(path,'sun_frame.mat'));
        if(sunrise_frame < 3)
            sunrise_frame = 3;
        end
        for t=sunrise_frame:sunset_frame
            fprintf('Processing frame %d of %s\n',t,date{idx});
            % get image data and compute features
            feature = ones(num_tiles,dimension);
            imgs = data.data(:,:,:,t-2:t);
            img_bg = data_median.median(:,:,:,t);
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
            % classification
            label_test = ones(num_tiles,1);
            label_predict = svmpredict(label_test,feature,smoke_classifier);
            label_predict_classifier(t) = sum(label_predict==1);
        end
        
        % save file
        fprintf('Saving label_predict_classifier.mat of %s\n',date{idx});
        save(fullfile(path,'label_predict_classifier.mat'),'label_predict_classifier','-v7.3');
    catch ME
        fprintf('Error classifying smoke of date %s\n',date{idx});
        logError(ME);
        continue;
    end
end

% close workers
% delete(gcp('nocreate'));
fprintf('Done\n');
toc