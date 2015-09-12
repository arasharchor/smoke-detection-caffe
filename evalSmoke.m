clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

date = {'2015-05-01','2015-05-02','2015-05-03'};

% parameters
[day_min_idx,day_max_idx] = getDayIdx();

% 2015-05-01 after steam
% date = {'2015-05-01'};
% day_min_idx = 7900;

% 2015-05-02 after steam
% date = {'2015-05-02'};
% day_min_idx = 6800; 

% 2015-05-03 after steam
% date = {'2015-05-03'};
% day_min_idx = 6700;

% read mask
target_dir = 'frames';
fprintf('Loading bbox.mat\n');
load(fullfile(target_dir,'bbox.mat'));

for idx=1:numel(date)
    % set data source
    date_path = [date{idx},'.timemachine/'];
    dataset_path = 'crf26-12fps-1424x800/';
    tile_path = '1/2/2.mp4';

    % read ground truth and responses
    path = fullfile(target_dir,date_path,dataset_path,tile_path);
    load(fullfile(path,'label.mat'));
    load(fullfile(path,'response.mat'));

    % count the number of true smoke pixels in each images
    sum_smoke_pixel = sum(reshape(label(bbox_row,bbox_col,:,:),[],size(label,4)));
    truth = double(sum_smoke_pixel>0);
    
    % Gaussian smoothing
    response = filter1D(response,0.5);

    % find local max
    min_peak_prominence = 150;
    min_peak_height = 150;
    min_peak_distance = 30;
    thr = 0;
    min_peak_width = 1.2;
    max_peak_width = 5;
    [pks,locs,w,p] = findpeaks(response,'MinPeakProminence',min_peak_prominence,'MinPeakHeight',min_peak_height,'MinPeakDistance',min_peak_distance,'Threshold',thr,'MaxPeakWidth',max_peak_width,'MinPeakWidth',min_peak_width);
    
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
    predict = double(predict);
    
    % plot ground truth and prediction
    fig = figure(98);
    img_cols = 1;
    img_rows = 4;

    subplot(img_rows,img_cols,1)
    bar(sum_smoke_pixel,'r')
    xlim([day_min_idx day_max_idx])
    title(['Ground truth ( ',date{idx},' )'])

    subplot(img_rows,img_cols,2)
    plot(response,'b')
    xlim([day_min_idx day_max_idx])
    title('Response of smoke detection')
    hold on
    plot(locs,pks,'ro')
    hold off
    
    subplot(img_rows,img_cols,3)
    bar(predict,'b')
    xlim([day_min_idx day_max_idx])
    set(gca,'YTickLabel',[]);
    set(gca,'YTick',[]);
    title('Predicted frames containing smoke')

    subplot(img_rows,img_cols,4)
    bar(truth,'r')
    xlim([day_min_idx day_max_idx])
    set(gca,'YTickLabel',[]);
    set(gca,'YTick',[]);
    title('Ground truth')
    
    % print figure
    print_dir = 'figs';
    if ~exist(print_dir,'dir')
        mkdir(print_dir);
    end
    set(gcf,'PaperPositionMode','auto')
    print(fig,fullfile(print_dir,date{idx}),'-dpng','-r0')
    
    % output a json file
    js_dir = 'js';
    if ~exist(js_dir,'dir')
        mkdir(js_dir);
    end
    response(1:day_min_idx) = 0;
    response(day_max_idx:end) = 0;
    response = round(response);
    js = array2json(response,predict);
    fileID = fopen(fullfile(js_dir,['smoke-',date{idx},'.js']),'w');
    fprintf(fileID,js);
    fclose(fileID);
    
    % compute F-score
    fscore = computeFscore(truth,predict);
    fscore.date = date{idx}
end