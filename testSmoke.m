clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;
% t = 5936;
t = [5936,6617,7438,7543,4015,7577,9008,12494,12566,12929,6205];

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));
data_median_60_mat = matfile(fullfile(path,'data_median_60.mat'));
data_median_120_mat = matfile(fullfile(path,'data_median_120.mat'));
data_median_360_mat = matfile(fullfile(path,'data_median_360.mat'));
data_median_720_mat = matfile(fullfile(path,'data_median_720.mat'));

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
    img = data_mat.data(bbox_row,bbox_col,:,t(i));
    imgs_bg = zeros([size(img),4],'uint8');
    imgs_bg(:,:,:,1) = data_median_60_mat.median(bbox_row,bbox_col,:,t(i));
    imgs_bg(:,:,:,2) = data_median_120_mat.median(bbox_row,bbox_col,:,t(i));
    imgs_bg(:,:,:,3) = data_median_360_mat.median(bbox_row,bbox_col,:,t(i));
    imgs_bg(:,:,:,4) = data_median_720_mat.median(bbox_row,bbox_col,:,t(i));
    [responses,imgs_filtered] = detectSmoke(img,imgs_bg);
    
    % visualize images
    fig = figure(50);
    nl = sprintf('\n');
    xlabel_offset = 8;
    img_cols = 5;
    img_rows = 2;
    font_size = 12;

    subplot(img_rows,img_cols,1)
    imshow(img)
    title(['t = ',num2str(t(i))])
    str = 'Time t';
    math = '$$I_t$$';
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)

    subplot(img_rows,img_cols,2)
    imshow(imgs_bg(:,:,:,1))
    str = 'Background $B1_t$ (5 mins)';
    math = '$$\mathrm{median}(I_{t-59}...I_{t})$$';
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)    

    subplot(img_rows,img_cols,3)
    imshow(imgs_bg(:,:,:,2))
    str = 'Background $B2_t$ (10 mins)';
    math = '$$\mathrm{median}(I_{t-119}...I_{t})$$';
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)   
 
    subplot(img_rows,img_cols,4)
    imshow(imgs_bg(:,:,:,3))
    str = 'Background $B3_t$ (30 mins)';
    math = '$$\mathrm{median}(I_{t-359}...I_{t})$$';
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size) 

    subplot(img_rows,img_cols,5)
    imshow(imgs_bg(:,:,:,4))
    str = 'Background $B4_t$ (60 mins)';
    math = '$$\mathrm{median}(I_{t-719}...I_{t})$$';
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    
    subplot(img_rows,img_cols,7)
    imshow(imgs_filtered.img_bs_60)
    str = '$\mathrm{abs}(I_t-B1_t)/(I_t+B1_t)$';
    math = num2str(responses.img_bs_60);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)

    subplot(img_rows,img_cols,8)
    imshow(imgs_filtered.img_bs_120)
    str = '$\mathrm{abs}(I_t-B2_t)/(I_t+B2_t)$';
    math = num2str(responses.img_bs_120);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)  

    subplot(img_rows,img_cols,9)
    imshow(imgs_filtered.img_bs_360)
    str = '$\mathrm{abs}(I_t-B3_t)/(I_t+B3_t)$';
    math = num2str(responses.img_bs_360);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)  
    
    subplot(img_rows,img_cols,10)
    imshow(imgs_filtered.img_bs_720)
    str = '$\mathrm{abs}(I_t-B4_t)/(I_t+B4_t)$';
    math = num2str(responses.img_bs_720);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size) 
    
    % print figure
    print_dir = 'figs';
    if ~exist(print_dir,'dir')
        mkdir(print_dir);
    end
    set(gcf,'PaperPositionMode','auto')
    print(fig,fullfile(print_dir,num2str(t(i))),'-dpng','-r0')
end