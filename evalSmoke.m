clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read ground truth and responses
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
load(fullfile(path,'label_black_smoke.mat'));
load(fullfile(path,'feature_smoke.mat'));

% read mask
load(fullfile(path,'bbox.mat'));

% parameters
day_min_idx = 4300;
day_max_idx = 14000;

% count the number of smoke pixels in each images and rescale to 0~1
sum_smoke_pixel = sum(reshape(label(bbox_row,bbox_col,:,:),[],size(label,4)));
% sum_smoke_pixel = sum_smoke_pixel - min(sum_smoke_pixel(:));
% sum_smoke_pixel = sum_smoke_pixel/max(abs(sum_smoke_pixel(:)));

% process features
fields = fieldnames(feature);
for i=1:length(fields)
    % rescale all features between 0 and 1
    vec = feature.(fields{i});
%     vec = vec - min(vec(day_min_idx:day_max_idx));
%     vec = vec/max(abs(vec(day_min_idx:day_max_idx)));
    % apply smoothing
%     vec = filter1D(vec,2);
    % find peaks
    min_peak_prominence = 0.2*max(vec(:));
    min_peak_height = 0;
    min_peak_distance = 0;
    thr = 0;
    max_peak_width = 0;
    [pks,locs,w,p] = findpeaks(vec,'MinPeakProminence',min_peak_prominence,'MinPeakHeight',min_peak_height,'MinPeakDistance',min_peak_distance,'Threshold',thr,'MaxPeakWidth',max_peak_width);
    % prediction
    predict = false(size(vec));
    for j=1:length(locs)
        w_half = w(j)/2;
        predict(round(locs(j)-w_half/2):round(locs(j)+w_half)) = true;
    end
    % write back
    feature.(fields{i}) = [];
    feature.(fields{i}).pks = pks;
    feature.(fields{i}).locs = locs;
    feature.(fields{i}).w = w;
    feature.(fields{i}).predict = predict;
    feature.(fields{i}).vec = vec;
end

% plot ground truth and features
img_cols = 1;
img_rows = 5;
figure(98)

subplot(img_rows,img_cols,1)
bar(sum_smoke_pixel,'r')
xlim([day_min_idx day_max_idx])
title(['Distribution of Smoke ( ',date_path,dataset_path,tile_path,' )'])

subplot(img_rows,img_cols,2)
plot(feature.img_bs_mask_clean.vec,'b')
xlim([day_min_idx day_max_idx])
title('Background subtraction (10 min = 120 frames)')
hold on
plot(feature.img_bs_mask_clean.locs,feature.img_bs_mask_clean.pks,'ro')
hold off

subplot(img_rows,img_cols,3)
plot(feature.gray_level_mean.vec,'b')
xlim([day_min_idx day_max_idx])
title('Grayish level mean')
hold on
plot(feature.gray_level_mean.locs,feature.gray_level_mean.pks,'ro')
hold off

subplot(img_rows,img_cols,4)
plot(feature.gray_level_std.vec,'b')
xlim([day_min_idx day_max_idx])
title('Grayish level std')
hold on
plot(feature.gray_level_std.locs,feature.gray_level_mean.pks,'ro')
hold off

% plot prediction
figure(101)

subplot(img_rows,img_cols,1)
bar(uint8(sum_smoke_pixel>0),'r')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title(['Distribution of Smoke ( ',date_path,dataset_path,tile_path,' )'])

subplot(img_rows,img_cols,2)
bar(uint8(feature.img_bs_mask_clean.predict),'b')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title('Background subtraction (10 min = 120 frames)')

subplot(img_rows,img_cols,3)
bar(uint8(feature.gray_level_mean.predict),'b')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title('Grayish level mean')

subplot(img_rows,img_cols,4)
bar(uint8(feature.gray_level_std.predict),'b')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title('Grayish level std')