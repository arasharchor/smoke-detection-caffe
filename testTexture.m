tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;

% t = 5936;
% t = 7543;
% t = 6617;
% t = 4406;
% t = 9011;
% t = 12929;
% t = 12566;
t = [4369,4406,5108,5936,6613,6617,7298,7435,7543,9011,12929,12566];

% set data source
date_path = '2015-05-02/';

% read frames
target_dir = 'images';
path = fullfile(target_dir,date_path);

% define mask
if(select_box == 1)
    t_ref = 5936;
    img = imread(fullfile(path,[num2str(t_ref),'.jpg']));
    [bbox_row,bbox_col] = selectBound(img);
    save(fullfile(path,'bbox.mat'),'bbox_row','bbox_col');
else
    load(fullfile(path,'bbox.mat'));
end

% compute filter bank (Laws' texture energy measures)
kernel{1} = [1,4,6,4,1]; % L5 = average gray level
kernel{2} = [-1,-2,0,2,1]; % E5 = edges
kernel{3} = [-1,0,2,0,-1]; % S5 = spots
kernel{4} = [1,-4,6,-4,1]; % R5 = ripples
kernel{5} = [-1,2,0,-2,1]; % W5 = waves
filter_bank = zeros(5,5,25);
for i=1:5
    for j=1:5
        filter_bank(:,:,(i-1)*5+j) = kernel{i}'*kernel{j};
    end
end
    
for i=1:numel(t)
    if(t(i)<3)
        continue;
    end
    
    % crop an image
    img = imread(fullfile(path,[num2str(t(i)),'.jpg']));
    img = img(bbox_row,bbox_col,:);
    img = imresize(img,0.5);
    img = im2double(img);
    
    % texture segmentation
    imgs_filtered = textureSeg(img,filter_bank);
    
    % detect smoke
    
    % visualize images
    fig = figure(68);
    img_cols = 7;
    img_rows = 3;
    fig_idx = 1;
    
    I = img;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_lcn;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_adj;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_histeq;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = label2rgb(imgs_filtered.tex_filtered);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_gray_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_rm_nongray);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_rm_nongray_filtered);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_black_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_rm_nonblack);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_rm_nonblack_filtered);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_DoG;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math); 
    
    I = imgs_filtered.img_entropy;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_entropy_white_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_entropy_black_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_entropy_gray_px;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_rm_highfreq);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(imgs_filtered.tex_clean);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    % print figure
    print_dir = 'figs';
    if ~exist(print_dir,'dir')
        mkdir(print_dir);
    end
    set(gcf,'PaperPositionMode','auto')
    print(fig,fullfile(print_dir,num2str(t(i))),'-dpng','-r0')
end
toc