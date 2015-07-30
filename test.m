clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;

t = 5936;
% t = 6617;
% t = 7543;

% set data source
date_path = '2015-05-02/';

% read frames
target_dir = 'images';
path = fullfile(target_dir,date_path);

% define mask
t_ref = 5936;
img = imread(fullfile(path,[num2str(t_ref),'.jpg']));
if(select_box == 1)
    [bbox_row,bbox_col] = selectBound(img);
    save(fullfile(path,'bbox.mat'),'bbox_row','bbox_col');
else
    load(fullfile(path,'bbox.mat'));
end

for i=1:numel(t)
    if(t(i)<3) 
        continue;
    end
    
    % crop an image and detect smoke
    img = imread(fullfile(path,[num2str(t),'.jpg']));
    img = img(bbox_row,bbox_col,:);
    img = imresize(img, 0.25);
    img = im2double(img);
    
    img_lcn = mat2gray(localnormalize(img,128,128));
    img_DoG = mat2gray(diffOfGaussian(img,0.01,20));
    r = img_lcn(:,:,1);
    g = img_lcn(:,:,2);
    b = img_lcn(:,:,3);
    img_dark = r<0.45 & g<0.45 & b<0.45;
    img_grayish = abs(r-g)<0.1 & abs(r-b)<0.1 & abs(b-g)<0.1;
    
%     y = wgn(m,n,p)

    
    % visualize images
    fig = figure(66);
    img_cols = 4;
    img_rows = 2;
    fig_idx = 1;
    
    I = img;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = img_lcn;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = img_dark;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = img_grayish;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = img_DoG;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
end