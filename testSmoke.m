clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;
% t = 5936;
% t = 7543;
% t = 6617;
% t = 9014;
% t = 4406;
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
label_mat = matfile(fullfile(path,'label_black_smoke.mat'));
data_median_mat = matfile(fullfile(path,'data_median_60.mat'));

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
    
    % crop an image and detect smoke
    img_label = label_mat.label(bbox_row,bbox_col,:,t(i));
    img = data_mat.data(bbox_row,bbox_col,:,t(i));
    img_bg = data_median_mat.median(bbox_row,bbox_col,:,t(i));
    tic
    [responses,imgs_filtered] = detectSmoke(img,img_bg);
    toc
    
    % visualize images
    fig = figure(50);
    img_cols = 8;
    img_rows = 3;
    fig_idx = 1;

    I = img;
    header = ['t = ',num2str(t(i))];
    str = 'Current image';
    math = '$$I_t$$';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,header,str,math);

    I = img_bg;
    str = 'Background';
    math = '$$B_t$$';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_smooth_lcn;
    str = '$$I_t = \mathrm{LCN}(I_t)$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bg_smooth_lcn;
    str = '$$B_t = \mathrm{LCN}(B_t)$$';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);    

    I = imgs_filtered.img_bs;
    str = '$$D_t = \frac{|I_t-B_t|}{I_t+B_t}$$';
    math = num2str(responses.img_bs);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

%     I = imgs_filtered.img_bs_thr;
%     str = 'Threshold $D_t$';
%     math = num2str(responses.img_bs_thr);
%     fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_black_px;
    str = 'Black px';
    math = num2str(responses.img_black_px);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_rmblack;
    str = 'Remove non-black';
    math = num2str(responses.img_bs_rmblack);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_gray_px;
    str = 'Grayish px';
    math = num2str(responses.img_gray_px);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_rmcolor;
    str = 'Remove non-grayish';
    math = num2str(responses.img_bs_rmcolor);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_lowS_px;
    str = 'Low S px';
    math = num2str(responses.img_lowS_px);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_rmlowS;
    str = 'Remove high S';
    math = num2str(responses.img_bs_rmlowS);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_DoG;
    str = '$$I_{dg} = \mathrm{DoG}(I_t)$$';
    math = num2str(responses.img_DoG);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bg_DoG;
    str = '$$B_{dg} = \mathrm{DoG}(B_t)$$';
    math = num2str(responses.img_bg_DoG);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_DoGdiff;
    str = '$$D_{dg} = \frac{|I_{dg}-B_{dg}|}{I_{dg}+B_{dg}}$$';
    math = num2str(responses.img_DoGdiff);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_DoGdiff_thr;
    str = 'Threshold $D_{dg}$';
    math = num2str(responses.img_DoGdiff_thr);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_DoGdiff_entropy_px;
    str = '$$E_{dg} = \mathrm{Entropy}(D_{dg})$$';
    math = num2str(responses.img_DoGdiff_entropy_px);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_rmLowDoGdiff;
    str = 'Remove small $E_{dg}$';
    math = num2str(responses.img_bs_rmLowDoGdiff);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_entropy;
    str = '$$E_t = \mathrm{Entropy}(I_t)$$';
    math = num2str(responses.img_entropy);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);    
    
    I = imgs_filtered.img_entropy_px;
    str = 'High $E_t$ px';
    math = num2str(responses.img_entropy_px);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_bs_rmLowEntropy;
    str = 'Remove Low $E_t$';
    math = num2str(responses.img_bs_rmLowEntropy);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
    
    I = imgs_filtered.img_bs_mask;
    str = 'Create a mask';
    math = num2str(responses.img_bs_mask);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_mask_smooth;
    str = 'Smooth the mask';
    math = num2str(responses.img_bs_mask_smooth);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = imgs_filtered.img_bs_mask_clean;
    str = 'Remove noise';
    math = num2str(responses.img_bs_mask_clean);
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    I = img_label;
    str = 'Ground truth';
    math = '$$T_t$$';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

    % print figure
    print_dir = 'figs';
    if ~exist(print_dir,'dir')
        mkdir(print_dir);
    end
    set(gcf,'PaperPositionMode','auto')
    print(fig,fullfile(print_dir,num2str(t(i))),'-dpng','-r0')
end