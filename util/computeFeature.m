function feature = computeFeature( img,img_bg,img_pre,img_pre2 )
    plot_graph = false;

    dimension = 30;
    feature = zeros(1,dimension);
    
    ptr = 1;
    
    % compute distribution features
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
        stat_bs = describeDistribution(f_bs{j},xi_bs{j});
        [f_fd{j},xi_fd{j}] = ksdensity(img_fd(:),'bandwidth',0.01,'npoints',100);
        stat_fd = describeDistribution(f_fd{j},xi_fd{j});
        [f_fd2{j},xi_fd2{j}] = ksdensity(img_fd2(:),'bandwidth',0.01,'npoints',100);
        stat_fd2 = describeDistribution(f_fd2{j},xi_fd2{j});
    end
    feature(1,ptr:ptr+numel(stat_bs)*3-1) = [stat_bs,stat_fd,stat_fd2];
    
    ptr = ptr + numel(stat_bs)*3;
    
    if(plot_graph)
        % visualize distributions
        figure(99);
        img_cols = 3;
        img_rows = 3;

        subplot(img_rows,img_cols,1);
        plot(xi_bs{1},f_bs{1})

        subplot(img_rows,img_cols,2);
        plot(xi_bs{2},f_bs{2})

        subplot(img_rows,img_cols,3);
        plot(xi_bs{3},f_bs{3})

        subplot(img_rows,img_cols,4);
        plot(xi_fd{1},f_fd{1})

        subplot(img_rows,img_cols,5);
        plot(xi_fd{2},f_fd{2})

        subplot(img_rows,img_cols,6);
        plot(xi_fd{3},f_fd{3})

        subplot(img_rows,img_cols,7);
        plot(xi_fd2{1},f_fd2{1})

        subplot(img_rows,img_cols,8);
        plot(xi_fd2{2},f_fd2{2})

        subplot(img_rows,img_cols,9);
        plot(xi_fd2{3},f_fd2{3})
    end
    
    % compute image features
    img_DoG = mat2gray(diffOfGaussian(img,0.5,3));
    img_bg_DoG = mat2gray(diffOfGaussian(img_bg,0.5,3));
    img_pre_DoG = mat2gray(diffOfGaussian(img_pre,0.5,3));
    img_pre2_DoG = mat2gray(diffOfGaussian(img_pre2,0.5,3));
    
    border = 3;
    img_DoG = eraseImgBorder(img_DoG,border);
    img_bg_DoG = eraseImgBorder(img_bg_DoG,border);
    img_pre_DoG = eraseImgBorder(img_pre_DoG,border);
    img_pre2_DoG = eraseImgBorder(img_pre2_DoG,border);
    
    feature(1,ptr:ptr+11) = [...
        squeeze(sum(sum(img_DoG)))',...
        squeeze(sum(sum(img_bg_DoG)))',...
        squeeze(sum(sum(img_pre_DoG)))',...
        squeeze(sum(sum(img_pre2_DoG)))'...
        ];
    
    if(plot_graph)
        % visualize images
        figure(100);
        img_cols = 4;
        img_rows = 2;
        fig_idx = 1;
        option = 'smallGraph';

        I = img;
        str = 'img';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_bg;
        str = 'img-bg';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_pre;
        str = 'img-pre';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_pre2;
        str = 'img-pre2';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_DoG;
        str = 'img-DoG';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_bg_DoG;
        str = 'img-bg-DoG';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_pre_DoG;
        str = 'img-pre-DoG';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);

        I = img_pre2_DoG;
        str = 'img-pre2-DoG';
        math = '';
        fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math,option);
    end
end

