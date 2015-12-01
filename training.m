clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

target_dir = 'frames';
load(fullfile(target_dir,'data_train.mat'));

% compute features
num_labels = size(data_train.label_pos,4);
dimension = 4;
feature = zeros(dimension,num_labels);

idx = 1:3;
fig = figure(99);
img_cols = numel(idx);
img_rows = 9;

for i=idx%num_labels
    img = data_train.label_pos(:,:,:,i);
    img_bg = data_train.label_pos_bg(:,:,:,i);
    img_pre = data_train.label_pos_pre(:,:,:,i);
    img_pre2 = data_train.label_pos_pre2(:,:,:,i);
    
    img_bs = mat2gray(backgroundSubtraction(img,img_bg,'Normalize'));
    img_fd = mat2gray(backgroundSubtraction(img,img_pre,'Normalize'));
    img_fd2 = mat2gray(backgroundSubtraction(img,img_pre2,'Normalize'));
    
    f_bs = cell(3,1);
    xi_bs = cell(3,1);
    f_fd = cell(3,1);
    xi_fd = cell(3,1);
    f_fd2 = cell(3,1);
    xi_fd2 = cell(3,1);
    for j=1:3
        [f_bs{j},xi_bs{j}] = ksdensity(img_bs(:),'bandwidth',0.01,'npoints',100);
        [f_fd{j},xi_fd{j}] = ksdensity(img_fd(:),'bandwidth',0.01,'npoints',100);
        [f_fd2{j},xi_fd2{j}] = ksdensity(img_fd2(:),'bandwidth',0.01,'npoints',100);
    end

    subplot(img_rows,img_cols,i);
    plot(xi_bs{1},f_bs{1})

    subplot(img_rows,img_cols,1*img_cols+i);
    plot(xi_bs{2},f_bs{2})
    
    subplot(img_rows,img_cols,2*img_cols+i);
    plot(xi_bs{3},f_bs{3})
    
    subplot(img_rows,img_cols,3*img_cols+i);
    plot(xi_fd{1},f_fd{1})
    
    subplot(img_rows,img_cols,4*img_cols+i);
    plot(xi_fd{2},f_fd{2})
    
    subplot(img_rows,img_cols,5*img_cols+i);
    plot(xi_fd{3},f_fd{3})

    subplot(img_rows,img_cols,6*img_cols+i);
    plot(xi_fd2{1},f_fd2{1})

    subplot(img_rows,img_cols,7*img_cols+i);
    plot(xi_fd2{2},f_fd2{2})
    
    subplot(img_rows,img_cols,8*img_cols+i);
    plot(xi_fd2{3},f_fd2{3})
    
%     img_DoG = mat2gray(diffOfGaussian(img,0.5,3));
%     img_bg_DoG = mat2gray(diffOfGaussian(img_bg,0.5,3));
%     img_pre_DoG = mat2gray(diffOfGaussian(img_pre,0.5,3));
%     img_pre2_DoG = mat2gray(diffOfGaussian(img_pre2,0.5,3));
%     
%     img_bs_DoG = mat2gray(backgroundSubtraction(img_DoG,img_bg_DoG,'Normalize'));
%     img_fd_DoG = mat2gray(backgroundSubtraction(img_DoG,img_pre_DoG,'Normalize'));
%     img_fd2_DoG = mat2gray(backgroundSubtraction(img_DoG,img_pre2_DoG,'Normalize'));
end

% % visualize images
% idx = 1190:1200;
% fig = figure(99);
% img_cols = numel(idx);
% img_rows = 4;
% fig_idx = 1;
% 
% for i=idx
%     I = data_train.label_pos(:,:,:,i);
%     str = '';
%     math = '';
%     fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
% end
% 
% for i=idx
%     I = data_train.label_pos_bg(:,:,:,i);
%     str = '';
%     math = '';
%     fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
% end
% 
% for i=idx
%     I = data_train.label_pos_pre(:,:,:,i);
%     str = '';
%     math = '';
%     fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
% end
% 
% for i=idx
%     I = data_train.label_pos_pre2(:,:,:,i);
%     str = '';
%     math = '';
%     fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
% end