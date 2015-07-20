clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;
% t = 5936;
% t = [5936,6617,7543];
% t = [5936,6617,7438,7543,7577,9008,12494,12566,12929,6205];
% t = [5936,6617,7543,6205,9008];
% t = [4369,5108,5936,6613,6617,7298,7435,7543];
t = [4406,4615,4860,4953,4995,5562,5969,6212,7327,7643,9014,9688,10078,10195,13100,13190,13418,13583,13871];

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));

% define mask
t_ref = 5936;
img = data_mat.data(:,:,:,t_ref);
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
    
    % crop an image and compute responses
    imgs = data_mat.data(bbox_row,bbox_col,:,t(i)-2:t(i));
    [responses,imgs_filtered] = computeResponse(imgs);
    
    % visualize images
    fig = figure(50);
    img_cols = 5;
    img_rows = 2;
    fig_idx = 1;

    I = imgs(:,:,:,end);
    header = ['t = ',num2str(t(i))];
    str = 'Time t';
    math = '$$I_t$$';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,header,str,math);

    I = imgs(:,:,:,end-1);
    str = 'Time t-1';
    math = '$$I_{t-1}$$';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs(:,:,:,end-2);
    str = 'Time t-2';
    math = '$$I_{t-2}$$';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = mat2gray(imgs_filtered.img_s_diff);
    str = 'Temp diff of S channel';
    math = num2str(responses.img_s_diff);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = mat2gray(imgs_filtered.img_v_diff);
    str = 'Temp diff of V channel';
    math = num2str(responses.img_v_diff);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = mat2gray(imgs_filtered.img_DoG);
    str = 'Difference of Gaussian (DoG)';
    math = num2str(responses.img_DoG);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = mat2gray(imgs_filtered.img_DoG_diff);
    str = 'Temp diff of DoG';
    math = num2str(responses.img_DoG_diff);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = mat2gray(imgs_filtered.img_entropy);
    str = 'Local entropy of DoG diff';
    math = num2str(responses.img_entropy);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_s;
    str = 'S channel of HSV';
    math = num2str(responses.img_s);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_v;
    str = 'V channel of HSV';
    math = num2str(responses.img_v);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    % print figure
    print_dir = 'figs';
    if ~exist(print_dir,'dir')
        mkdir(print_dir);
    end
    set(gcf,'PaperPositionMode','auto')
    print(fig,fullfile(print_dir,num2str(t(i))),'-dpng','-r0')
end