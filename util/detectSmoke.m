function [ responses,imgs_filtered ] = detectSmoke( img,img_bg )
    % image smoothing
    img_smooth = gaussianSmooth(img,0.5);
    img_bg_smooth = gaussianSmooth(img_bg,0.5);

    % local contrast normalization
    img_smooth_lcn = mat2gray(localnormalize(double(img_smooth),64,64));
    img_bg_smooth_lcn = mat2gray(localnormalize(double(img_bg_smooth),64,64));
    
    imgs_filtered.img_smooth_lcn = img_smooth_lcn;   
    imgs_filtered.img_bg_smooth_lcn = img_bg_smooth_lcn; 
    
    % background subtraction
    img_bs = backgroundSubtraction(img_smooth_lcn,img_bg_smooth_lcn,'Normalize');
    img_bs = mat2gray(localnormalize(double(img_bs),64,64));
    
    imgs_filtered.img_bs = img_bs;
    responses.img_bs = sum(imgs_filtered.img_bs(:));

    % threshold
    thr = 0.07;
	img_bs_thr = img_bs;
    img_bs_thr(repmat(rgb2gray(img_bs_thr)<thr,1,1,3)) = 0;
    
    imgs_filtered.img_bs_thr = img_bs_thr;
    responses.img_bs_thr = sum(imgs_filtered.img_bs_thr(:));

    % remove pixels that are not black
    r = img_smooth_lcn(:,:,1);
    g = img_smooth_lcn(:,:,2);
    b = img_smooth_lcn(:,:,3);
    r_thr = 0.4;
    g_thr = 0.4;
    b_thr = 0.6;
    img_black_px = r<r_thr & g<g_thr & b<b_thr;
    img_bs_rmblack = img_bs_thr;
    img_bs_rmblack(~repmat(img_black_px,1,1,3)) = 0;

    imgs_filtered.img_bs_rmblack = img_bs_rmblack;
    responses.img_bs_rmblack = sum(imgs_filtered.img_bs_rmblack(:));    
    imgs_filtered.img_black_px = img_black_px;
    responses.img_black_px = sum(imgs_filtered.img_black_px(:));

    % remove pixels that are not gray
    rg_thr = 0.07;
    gb_thr = 0.07;
    rb_thr = 0.15;
    img_gray_px = abs(r-g)<rg_thr & abs(r-b)<rb_thr & abs(g-b)<gb_thr;
    img_bs_rmcolor = img_bs_rmblack;
    img_bs_rmcolor(~repmat(img_gray_px,1,1,3)) = 0;

    imgs_filtered.img_bs_rmcolor = img_bs_rmcolor;
    responses.img_bs_rmcolor = sum(imgs_filtered.img_bs_rmcolor(:));    
    imgs_filtered.img_gray_px = img_gray_px;
    responses.img_gray_px = sum(imgs_filtered.img_gray_px(:));

    % remove pixels that have high saturation
    img_hsv = rgb2hsv(img);
    img_lowS_px = img_hsv(:,:,2)<0.5;
    img_bs_rmlowS = img_bs_rmcolor;
    img_bs_rmlowS(~repmat(img_lowS_px,1,1,3)) = 0;

    imgs_filtered.img_bs_rmlowS = img_bs_rmlowS;
    responses.img_bs_rmlowS = sum(imgs_filtered.img_bs_rmlowS(:));    
    imgs_filtered.img_lowS_px = img_lowS_px;
    responses.img_lowS_px = sum(imgs_filtered.img_lowS_px(:));

    % remove pixels that have low background subtraction of DoG
    img_DoG = mat2gray(diffOfGaussian(img_smooth,0.5,3));
    img_bg_DoG = mat2gray(diffOfGaussian(img_bg_smooth,0.5,3));
    img_DoGdiff = mat2gray(backgroundSubtraction(img_DoG,img_bg_DoG,'Normalize'));
    img_DoGdiff = mat2gray(localnormalize(double(img_DoGdiff),64,64));
    r_thr = 0.1;
    g_thr = 0.1;
    b_thr = 0.1;
    img_DoGdiff_thr = img_DoGdiff(:,:,1)>r_thr & img_DoGdiff(:,:,2)>g_thr & img_DoGdiff(:,:,3)>b_thr;
    img_DoGdiff_entropy_px = entropyfilt(img_DoGdiff_thr,true(13,13));
    img_DoGdiff_entropy_px = im2bw(img_DoGdiff_entropy_px,0.75);
    img_bs_rmLowDoGdiff = img_bs_rmlowS;
    img_bs_rmLowDoGdiff(~repmat(img_DoGdiff_entropy_px,1,1,3)) = 0;

    imgs_filtered.img_DoG = img_DoG;
    responses.img_DoG = sum(imgs_filtered.img_DoG(:));
    imgs_filtered.img_bg_DoG = img_bg_DoG;
    responses.img_bg_DoG = sum(imgs_filtered.img_bg_DoG(:));
    imgs_filtered.img_DoGdiff = img_DoGdiff;
    responses.img_DoGdiff = sum(imgs_filtered.img_DoGdiff(:));
    imgs_filtered.img_DoGdiff_thr = img_DoGdiff_thr;
    responses.img_DoGdiff_thr = sum(imgs_filtered.img_DoGdiff_thr(:));
    imgs_filtered.img_DoGdiff_entropy_px = img_DoGdiff_entropy_px;
    responses.img_DoGdiff_entropy_px = sum(imgs_filtered.img_DoGdiff_entropy_px(:));
    imgs_filtered.img_bs_rmLowDoGdiff = img_bs_rmLowDoGdiff;
    responses.img_bs_rmLowDoGdiff = sum(imgs_filtered.img_bs_rmLowDoGdiff(:));

    % remove pixels that have low entropy in the current image
    img_entropy = mat2gray(entropyfilt(img_smooth_lcn,true(9,9)));
    r_en = img_entropy(:,:,1);
    g_en = img_entropy(:,:,2);
    b_en = img_entropy(:,:,3);
    rg_thr = 0.15;
    gb_thr = 0.15;
    rb_thr = 0.15;
    img_entropy_px = abs(r_en-g_en)<rg_thr & abs(r_en-b_en)<rb_thr & abs(g_en-b_en)<gb_thr;
    img_bs_rmLowEntropy = img_bs_rmLowDoGdiff;
    img_bs_rmLowEntropy(~repmat(img_entropy_px,1,1,3)) = 0;
    
    imgs_filtered.img_entropy = img_entropy;
    responses.img_entropy = sum(imgs_filtered.img_entropy(:));
    imgs_filtered.img_entropy_px = img_entropy_px;
    responses.img_entropy_px = sum(imgs_filtered.img_entropy_px(:));  
    imgs_filtered.img_bs_rmLowEntropy = img_bs_rmLowEntropy;
    responses.img_bs_rmLowEntropy = sum(imgs_filtered.img_bs_rmLowEntropy(:));
    
    % create a mask
    img_bs_mask_gray = rgb2gray(img_bs_rmLowEntropy);
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
    img_bs_mask_clean = removeSmallRegions(img_bs_mask_clean,50);

    imgs_filtered.img_bs_mask_clean = img_bs_mask_clean;
    responses.img_bs_mask_clean = sum(imgs_filtered.img_bs_mask_clean(:));
end