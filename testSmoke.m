clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;
t = 5936;
% t = [5936,6617,7543];
% t = [5936,7543,7543,9008,6205];
% t = [5936,6617,7438,7543,4015,7577,9008,12494,12566,12929,6205];

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));
label_mat = matfile(fullfile(path,'label.mat'));
data_median_mat = matfile(fullfile(path,'data_median_120.mat'));

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
    [responses,imgs_filtered] = detectSmoke(img,img_bg);
    
    % visualize images
    fig = figure(50);
    nl = sprintf('\n');
    xlabel_offset = 8;
    img_cols = 4;
    img_rows = 2;
    font_size = 12;

    subplot(img_rows,img_cols,1)
    imshow(img)
    title(['t = ',num2str(t(i))])
    str = 'Current image';
    math = '$$I_t$$';
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    
    subplot(img_rows,img_cols,2)
    imshow(img_bg)
    str = 'Estimated Background';
    math = '$$B_t = \mathrm{median}(I_{t-119}...I_{t})$$';
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)   

    subplot(img_rows,img_cols,3)
    imshow(imgs_filtered.img_bs)
    str = '$D_t = (I_t-B_t)/(I_t+B_t)$';
    math = num2str(responses.img_bs);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)

    subplot(img_rows,img_cols,4)
    imshow(imgs_filtered.img_bs_thr)
    str = 'Apply threshold';
    math = num2str(responses.img_bs_thr);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size) 
    
    subplot(img_rows,img_cols,5)
    imshow(imgs_filtered.img_bs_mask)
    str = 'Create a mask';
    math = num2str(responses.img_bs_mask);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    
    subplot(img_rows,img_cols,6)
    imshow(imgs_filtered.img_bs_mask_smooth)
    str = 'Smooth the mask';
    math = num2str(responses.img_bs_mask_smooth);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)  
    
    subplot(img_rows,img_cols,7)
    imshow(imgs_filtered.img_bs_mask_clean)
    str = 'Remove noise and small regions';
    math = num2str(responses.img_bs_mask_clean);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    
    subplot(img_rows,img_cols,8)
    imshow(img_label)
    str = 'Ground truth';
    math = '$$T_t$$';
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