function [ responses,imgs_filtered ] = detectSmoke( img,img_bg )
    % image smoothing
    img_smooth = gaussianSmooth(img,0.5);
    
    % background subtraction
    img_bs = backgroundSubtraction(img_smooth,img_bg,'NormalizeWithSign');
    imgs_filtered.img_bs = img_bs;
    responses.img_bs = sum(imgs_filtered.img_bs(:));
    
    % threshold
    thr = 0.1;
    img_bs_thr = img_bs;
    img_bs_thr(img_bs_thr<thr) = 0;
    imgs_filtered.img_bs_thr = img_bs_thr;
    responses.img_bs_thr = sum(imgs_filtered.img_bs_thr(:));
    
    % create a mask
    img_bs_mask_gray = rgb2gray(img_bs_thr);
    img_bs_mask = false(size(img_bs_mask_gray));
    img_bs_mask(img_bs_mask_gray>0) = true;
    imgs_filtered.img_bs_mask = img_bs_mask;
    responses.img_bs_mask = sum(imgs_filtered.img_bs_mask(:)); 
    
    % smooth the mask
    img_bs_mask_smooth = img_bs_mask;
    img_bs_mask_smooth = morphology(img_bs_mask_smooth,3);
    imgs_filtered.img_bs_mask_smooth = img_bs_mask_smooth;
    responses.img_bs_mask_smooth = sum(imgs_filtered.img_bs_mask_smooth(:)); 
    
    % remove small regions and noise
    img_bs_mask_clean = img_bs_mask_smooth;
    img_bs_mask_clean = removeSmallRegions(img_bs_mask_clean,100);
    img_bs_mask_clean = removeNoise(img_bs_mask_clean);
    imgs_filtered.img_bs_mask_clean = img_bs_mask_clean;
    responses.img_bs_mask_clean = sum(imgs_filtered.img_bs_mask_clean(:));
    
    % compute grayish level of the original image in the mask
    r_vec = img_smooth(:,:,1);
    r_vec = r_vec(img_bs_mask_clean==1);
    g_vec = img_smooth(:,:,2);
    g_vec = g_vec(img_bs_mask_clean==1);
    b_vec = img_smooth(:,:,3);
    b_vec = b_vec(img_bs_mask_clean==1);
    gray_level = double(abs(r_vec-g_vec)+abs(g_vec-b_vec)+abs(b_vec-r_vec));
    if(numel(gray_level)==0)
        gray_level_mean = 0;
        gray_level_std = 0;
    else
        gray_level_mean = mean(gray_level);
        gray_level_std = std(gray_level);
    end
    responses.gray_level_mean = gray_level_mean;
    responses.gray_level_std = gray_level_std;
end

