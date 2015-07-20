function [ responses,imgs_filtered ] = detectSmoke( img,img_bg )
    % image smoothing
    img_smooth = gaussianSmooth(img,0.5);
    img_bg_smooth = gaussianSmooth(img_bg,0.5);
    
    % background subtraction
    img_bs = backgroundSubtraction(img_smooth,img_bg_smooth,'Normalize');
    imgs_filtered.img_bs = img_bs;
    responses.img_bs = sum(imgs_filtered.img_bs(:));
    
    % threshold
    thr = 0.07;
    img_bs_thr = img_bs;
    img_bs_thr(img_bs_thr<thr) = 0;
    imgs_filtered.img_bs_thr = img_bs_thr;
    responses.img_bs_thr = sum(imgs_filtered.img_bs_thr(:));

    % remove pixels that are not black
    r = double(img(:,:,1));
    g = double(img(:,:,2));
    b = double(img(:,:,3));    
    r_thr = 110;
    g_thr = 130;
    b_thr = 150;
    img_black_px = r<r_thr & g<g_thr & b<b_thr;
    img_bs_rmblack = img_bs_thr;
    img_bs_rmblack(~repmat(img_black_px,1,1,3)) = 0;
    imgs_filtered.img_bs_rmblack = img_bs_rmblack;
    responses.img_bs_rmblack = sum(imgs_filtered.img_bs_rmblack(:));    
    imgs_filtered.img_black_px = img_black_px;
    responses.img_black_px = sum(imgs_filtered.img_black_px(:));
    
    % remove pixels that are not gray
    rg_thr = 25;
    gb_thr = 25;
    rb_thr = 45;
    img_gray_px = abs(r-g)<=rg_thr & abs(r-b)<=rb_thr & abs(g-b)<=gb_thr;
    img_bs_rmcolor = img_bs_rmblack;
    img_bs_rmcolor(~repmat(img_gray_px,1,1,3)) = 0;
    imgs_filtered.img_bs_rmcolor = img_bs_rmcolor;
    responses.img_bs_rmcolor = sum(imgs_filtered.img_bs_rmcolor(:));    
    imgs_filtered.img_gray_px = img_gray_px;
    responses.img_gray_px = sum(imgs_filtered.img_gray_px(:));

    % remove pixels that have high saturation
    img_hsv = rgb2hsv(img);
    img_lowS_px = img_hsv(:,:,2)<0.35;
    img_bs_rmlowS = img_bs_rmcolor;
    img_bs_rmlowS(~repmat(img_lowS_px,1,1,3)) = 0;
    imgs_filtered.img_bs_rmlowS = img_bs_rmlowS;
    responses.img_bs_rmlowS = sum(imgs_filtered.img_bs_rmlowS(:));    
    imgs_filtered.img_lowS_px = img_lowS_px;
    responses.img_lowS_px = sum(imgs_filtered.img_lowS_px(:));

    % remove pixels that have low background subtraction of DoG
    img_DoG = diffOfGaussian(img_smooth,0.5,3);
    img_bg_DoG = diffOfGaussian(img_bg_smooth,0.5,3);
    img_DoGdiff = mat2gray(backgroundSubtraction(img_DoG,img_bg_DoG,'Normalize'));
    r_thr = 0.15;
    g_thr = 0.15;
    b_thr = 0.15;
    img_DoGdiff_entropy_px = img_DoGdiff(:,:,1)>r_thr & img_DoGdiff(:,:,2)>g_thr & img_DoGdiff(:,:,3)>b_thr;
    img_DoGdiff_entropy_px = entropyfilt(img_DoGdiff_entropy_px,true(7,7));
    img_DoGdiff_entropy_px(img_DoGdiff_entropy_px<0.7) = 0;
    img_bs_rmLowDoGdiff = img_bs_rmlowS;
    img_bs_rmLowDoGdiff(~repmat(img_DoGdiff_entropy_px,1,1,3)) = 0;
    imgs_filtered.img_DoGdiff_entropy_px = img_DoGdiff_entropy_px;
    responses.img_DoGdiff_entropy_px = sum(imgs_filtered.img_DoGdiff_entropy_px(:));
    imgs_filtered.img_bs_rmLowDoGdiff = img_bs_rmLowDoGdiff;
    responses.img_bs_rmLowDoGdiff = max(imgs_filtered.img_bs_rmLowDoGdiff(:));
    
    % create a mask
    img_bs_mask_gray = rgb2gray(img_bs_rmLowDoGdiff);
    img_bs_mask = false(size(img_bs_mask_gray));
    img_bs_mask(img_bs_mask_gray>0) = true;
    imgs_filtered.img_bs_mask = img_bs_mask;
    responses.img_bs_mask = sum(imgs_filtered.img_bs_mask(:)); 
    
    % smooth the mask
    img_bs_mask_smooth = img_bs_mask;
    img_bs_mask_smooth = im2double(morphology(img_bs_mask_smooth,5));
    imgs_filtered.img_bs_mask_smooth = img_bs_mask_smooth;
    responses.img_bs_mask_smooth = sum(imgs_filtered.img_bs_mask_smooth(:)); 
    
    % remove noise
    img_bs_mask_clean = img_bs_mask_smooth;
    img_bs_mask_clean = removeNoise(img_bs_mask_clean);
    img_bs_mask_clean = removeSmallRegions(img_bs_mask_clean,100);
    imgs_filtered.img_bs_mask_clean = img_bs_mask_clean;
    responses.img_bs_mask_clean = sum(imgs_filtered.img_bs_mask_clean(:));
end

