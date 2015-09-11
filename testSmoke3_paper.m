clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;

t = 7543;
% t = 6617;
% t = 10300;

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));
label_mat = matfile(fullfile(path,'label.mat'));
data_median_mat = matfile(fullfile(path,'data_median_60.mat'));

% define mask
if(select_box == 1)
    t_ref = 5936;
    img = data_mat.data(:,:,:,t_ref);
    [bbox_row,bbox_col] = selectBound(img);
    save(fullfile(target_dir,'bbox.mat'),'bbox_row','bbox_col');
else
    load(fullfile(target_dir,'bbox.mat'));
end

% compute filter bank (Laws' texture energy measures)
filter_bank = getFilterbank();

for i=1:numel(t)
    if(t(i)<3) 
        continue;
    end
    
    % crop an image and detect smoke
    img_label = label_mat.label(bbox_row,bbox_col,:,t(i));
    span = getTemporalSpan();
    imgs = data_mat.data(bbox_row,bbox_col,:,t(i)-span:span:t(i));
    imgs_fd = imgs(:,:,:,1);
    img_bg = data_median_mat.median(bbox_row,bbox_col,:,t(i));
    img = imgs(:,:,:,2);
    tic
    [val,imgs_filtered] = detectSmoke3(img,img_bg,filter_bank,imgs_fd);
    toc
    
    plot_HFCD = true;
    plot_IICD = true;
    plot_TEX = true;
    option = 'largeFont';
    
    if(plot_HFCD)
        % visualize images
        fig = figure(51);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;

        I = img;
        str = '$I_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_bg;
        str = '$B_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_DoG;
        str = '$I_{dog}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_bg_DoG;
        str = '$B_{dog}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_bs_DoG;
        str = '$S_{dog}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_bs_DoG_thr;
        str = '$S_{dog}>T_{1}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_HFCD.img_bs_DoG_thr_entropy;
        str = '$E_{dog}>T_{2}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.HFCD;
        str = '$M_{dog}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_1']),'-dpng','-r0')
    end
    
    if(plot_IICD)
        % visualize images
        fig = figure(52);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;

        I = imgs_filtered.imgs_IICD.img_histeq;
        str = '$I_{heq}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_bg_histeq;
        str = '$B_{heq}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_bs_thr;
        str = '$S_{heq}>T_{3}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_bs_thr_smooth;
        str = '$M_{heq1}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_last_histeq;
        str = '$I''_{heq}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_last_diff_thr;
        str = '$F_{heq}>T_{4}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_IICD.img_last_diff_thr_smooth;
        str = '$M_{heq2}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.IICD;
        str = '$M_{heq}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_2']),'-dpng','-r0')
    end
    
    if(plot_TEX)
        % visualize images
        fig = figure(53);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;
                
        I = label2rgb(imgs_filtered.imgs_TS.tex_seg);
        str = '$R_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = label2rgb(imgs_filtered.TS);
        str = '$R_{smooth}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = imgs_filtered.imgs_BRF.img_adj;
        str = '$I_{adj}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = mat2gray(imgs_filtered.imgs_BRF.img_bs);
        str = '$S_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        I = imgs_filtered.HFCD_IICD;
        str = '$M_{cd} = M_{dog} \;\&\; M_{heq}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
          
        I = label2rgb(imgs_filtered.imgs_BRF.tex_seg_nonshadow);
        str = '$R_{filter}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option); 

        I = imgs_filtered.BRF;
        str = '$M_{t}$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        img_masked = imgs_filtered.imgs_BRF.img_adj;
        img_masked(repmat(imgs_filtered.BRF==0,1,1,3)) = 0;
        I = img_masked;
        str = '$I_{adj}(M_{t})$';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
        
        % print figure
        print_dir = 'figs';
        if ~exist(print_dir,'dir')
            mkdir(print_dir);
        end
        set(gcf,'PaperPositionMode','auto')
        print(fig,fullfile(print_dir,[num2str(t(i)),'_3']),'-dpng','-r0')  
    end
end