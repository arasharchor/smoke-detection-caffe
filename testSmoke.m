clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;
% t = 5936;
% t = [5936,6617,7543];
% t = [5936,6617,7438,7543,7577,9008,12494,12566,12929,6205];
% t = [5936,6617,7543,6205,9008];
t = [4369,5108,5936,6613,6617,7298,7435,7543];
% t = [4406,4615,4860,4953,4995,5562,5969,6212,7327,7643,9014,9688,10078,10195,13100,13190,13418,13583,13871];

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
    [responses,imgs_filtered] = detectSmoke(img,img_bg);
    
    % visualize images
    fig = figure(50);
    nl = sprintf('\n');
    xlabel_offset = 8;
    img_cols = 8;
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
    str = 'Background';
    math = '$$B_t$$';
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)   

    subplot(img_rows,img_cols,3)
    imshow(mat2gray(imgs_filtered.img_bs))
    str = '$$D_t = \frac{abs(I_t-B_t)}{I_t+B_t}$$';
    math = num2str(responses.img_bs);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)

    subplot(img_rows,img_cols,4)
    imshow(mat2gray(imgs_filtered.img_bs_thr))
    str = 'Apply threshold';
    math = num2str(responses.img_bs_thr);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)

    subplot(img_rows,img_cols,5)
    imshow(imgs_filtered.img_gray_px)
    str = 'Grayish pixels';
    math = num2str(responses.img_gray_px);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    
    subplot(img_rows,img_cols,6)
    imshow(mat2gray(imgs_filtered.img_bs_rmcolor))
    str = 'Remove non-grayish';
    math = num2str(responses.img_bs_rmcolor);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)

    subplot(img_rows,img_cols,7)
    imshow(imgs_filtered.img_lowS_px)
    str = 'Low S pixels';
    math = num2str(responses.img_lowS_px);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)    
    
    subplot(img_rows,img_cols,8)
    imshow(mat2gray(imgs_filtered.img_bs_rmlowS))
    str = 'Remove high S';
    math = num2str(responses.img_bs_rmlowS);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    
    subplot(img_rows,img_cols,9)
    imshow(imgs_filtered.img_black_px)
    str = 'Black pixels';
    math = num2str(responses.img_black_px);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)    
    
    subplot(img_rows,img_cols,10)
    imshow(mat2gray(imgs_filtered.img_bs_rmblack))
    str = 'Remove non-black';
    math = num2str(responses.img_bs_rmblack);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)

    subplot(img_rows,img_cols,11)
    imshow(imgs_filtered.img_DoGdiff_entropy_px)
    str = 'DoG diff';
    math = num2str(responses.img_DoGdiff_entropy_px);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)

    subplot(img_rows,img_cols,12)
    imshow(mat2gray(imgs_filtered.img_bs_rmLowDoGdiff))
    str = 'Filter DoG diff';
    math = num2str(responses.img_bs_rmLowDoGdiff);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    
    subplot(img_rows,img_cols,13)
    imshow(imgs_filtered.img_bs_mask)
    str = 'Create a mask';
    math = num2str(responses.img_bs_mask);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    
    subplot(img_rows,img_cols,14)
    imshow(imgs_filtered.img_bs_mask_smooth)
    str = 'Smooth the mask';
    math = num2str(responses.img_bs_mask_smooth);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)  
    
    subplot(img_rows,img_cols,15)
    imshow(imgs_filtered.img_bs_mask_clean)
    str = 'Remove noise';
    math = num2str(responses.img_bs_mask_clean);
    xlabel([str,nl,math],'Interpreter','latex')
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position')-[0 xlabel_offset 0])
    set(gca,'FontSize',font_size)
    
    subplot(img_rows,img_cols,16)
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