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
load(fullfile(path,'label.mat'));
load(fullfile(path,'feature.mat'));

% read mask
load(fullfile(path,'bbox.mat'));

% parameters
[day_min_idx,day_max_idx] = getDayIdx();

% count the number of smoke pixels in each images
sum_smoke_pixel = sum(reshape(label(bbox_row,bbox_col,:,:),[],size(label,4)));

% bilateral smoothing
% wid = 5;       % bilateral filter half-width
% sigma = [3 0.1]; % bilateral filter standard deviations
% max = max(feature.img_bs_mask_clean);
% feature.img_bs_mask_clean = feature.img_bs_mask_clean./max;
% feature.img_bs_mask_clean = bfilter2(feature.img_bs_mask_clean,wid,sigma);
% feature.img_bs_mask_clean = feature.img_bs_mask_clean.*max;

% Gaussian smoothing
feature.img_bs_mask_clean = filter1D(feature.img_bs_mask_clean,1);

% find local max
min_peak_prominence = 200;
min_peak_height = 100;
min_peak_distance = 30;
thr = 10;
max_peak_width = 100;
[pks,locs,w,p] = findpeaks(feature.img_bs_mask_clean,'MinPeakProminence',min_peak_prominence,'MinPeakHeight',min_peak_height,'MinPeakDistance',min_peak_distance,'Threshold',thr,'MaxPeakWidth',max_peak_width);

% remove night time idx and peaks that are too high
feature.img_bs_mask_clean.vec = feature.img_bs_mask_clean;
idx_remove = find(pks>4000 | locs<day_min_idx | locs>day_max_idx);
pks(idx_remove) = [];
feature.img_bs_mask_clean.pks = pks;
locs(idx_remove) = [];
feature.img_bs_mask_clean.locs = locs;
w(idx_remove) = [];
p(idx_remove) = [];

% prediction
predict = false(size(feature.img_bs_mask_clean.vec));
for j=1:length(locs)
    w_ = w*2;
    predict(round(locs(j)-w_):round(locs(j)+w_)) = true;
end
feature.img_bs_mask_clean.predict = predict;

% plot ground truth and prediction
img_cols = 1;
img_rows = 4;
figure(98)

subplot(img_rows,img_cols,1)
bar(sum_smoke_pixel,'r')
xlim([day_min_idx day_max_idx])
title(['Ground truth of Smoke ( ',date_path,dataset_path,tile_path,' )'])

subplot(img_rows,img_cols,2)
plot(feature.img_bs_mask_clean.vec,'b')
xlim([day_min_idx day_max_idx])
title('Background subtraction')
hold on
plot(feature.img_bs_mask_clean.locs,feature.img_bs_mask_clean.pks,'ro')
hold off

subplot(img_rows,img_cols,3)
bar(uint8(sum_smoke_pixel>0),'r')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title(['Ground truth of Smoke ( ',date_path,dataset_path,tile_path,' )'])

subplot(img_rows,img_cols,4)
bar(uint8(feature.img_bs_mask_clean.predict),'b')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title('Background subtraction')

% output a json file
vec = feature.img_bs_mask_clean.vec;
vec(1:day_min_idx) = 0;
vec(day_max_idx:end) = 0;
vec = round(vec);
predict = feature.img_bs_mask_clean.predict;
js = array2json(vec,predict);
fileID = fopen(fullfile(path,'smoke.js'),'w');
fprintf(fileID,js);
fclose(fileID);