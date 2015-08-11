tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;

t = 5936;
% t = 7543;
% t = 6617;
% t = 4406;
% t = 9011;

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

% compute filter banks (Laws' texture energy measures)
kernel{1} = [1,4,6,4,1]; % L5 = average gray level
kernel{2} = [-1,-2,0,2,1]; % E5 = edges
kernel{3} = [-1,0,2,0,-1]; % S5 = spots
kernel{4} = [1,-4,6,-4,1]; % R5 = ripples
kernel{5} = [-1,2,0,-2,1]; % W5 = waves
filter = zeros(5,5,25);
for i=1:5
    for j=1:5
        filter(:,:,(i-1)*5+j) = kernel{i}'*kernel{j};
    end
end
    
for i=1:numel(t)
    if(t(i)<3) 
        continue;
    end
    
    % crop an image
    img = imread(fullfile(path,[num2str(t),'.jpg']));
    img = img(bbox_row,bbox_col,:);
    img = imresize(img,0.25);
    img = im2double(img);
    
    % texture segmentation
    tex = textureSeg(img);
    
    % detect smoke
    
    % visualize images
    fig = figure(68);
    img_cols = 2;
    img_rows = 1;
    fig_idx = 1;
    
    I = img;
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = label2rgb(tex);
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
end
toc