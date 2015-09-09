clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
date_str = '2015-05-02';
date_path = [date_str,'.timemachine/'];
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read ground truth and responses
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
load(fullfile(path,'label.mat'));
load(fullfile(path,'response.mat'));

% read mask
load(fullfile(path,'bbox.mat'));

% parameters
[day_min_idx,day_max_idx] = getDayIdx();

% count the number of true smoke pixels in each images
sum_smoke_pixel = sum(reshape(label(bbox_row,bbox_col,:,:),[],size(label,4)));

% Gaussian smoothing
response = filter1D(response,1);

% find local max
min_peak_prominence = 20;
min_peak_height = 50;
min_peak_distance = 60;
thr = 5;
max_peak_width = 100;
[pks,locs,w,p] = findpeaks(response,'MinPeakProminence',min_peak_prominence,'MinPeakHeight',min_peak_height,'MinPeakDistance',min_peak_distance,'Threshold',thr,'MaxPeakWidth',max_peak_width);

% remove night time idx and peaks that are too high
idx_remove = find(pks>10000 | locs<day_min_idx | locs>day_max_idx);
pks(idx_remove) = [];
locs(idx_remove) = [];
w(idx_remove) = [];
p(idx_remove) = [];

% prediction
predict = false(size(response));
for j=1:length(locs)
    w_ = w(j)*2;
    predict(round(locs(j)-w_):round(locs(j)+w_)) = true;
end

% plot ground truth and prediction
img_cols = 1;
img_rows = 4;
figure(98)

subplot(img_rows,img_cols,1)
bar(sum_smoke_pixel,'r')
xlim([day_min_idx day_max_idx])
title(['Ground truth of Smoke ( ',date_path,dataset_path,tile_path,' )'])

subplot(img_rows,img_cols,2)
plot(response,'b')
xlim([day_min_idx day_max_idx])
title('Smoke detection')
hold on
plot(locs,pks,'ro')
hold off

subplot(img_rows,img_cols,3)
bar(uint8(sum_smoke_pixel>0),'r')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title(['Ground truth of Smoke ( ',date_path,dataset_path,tile_path,' )'])

subplot(img_rows,img_cols,4)
bar(uint8(predict),'b')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title('Background subtraction')

% output a json file
response(1:day_min_idx) = 0;
response(day_max_idx:end) = 0;
response = round(response);
js = array2json(response,predict);
fileID = fopen(fullfile(path,['smoke-',date_str,'.js']),'w');
fprintf(fileID,js);
fclose(fileID);