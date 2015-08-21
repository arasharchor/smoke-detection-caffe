function [ IICD,imgs_IICD ] = imgIntensityChangeDetection( img,img_bg,imgs_last )
    % background subtraction
    img_histeq = histeqRGB(img);
    img_bg_histeq = histeqRGB(img_bg);
    img_bs = backgroundSubtraction(img_histeq,img_bg_histeq,'Normalize');
    img_bs_thr = rgb2gray(img_bs);
    img_bs_thr = im2bw(img_bs_thr,0.08);
    img_bs_thr_smooth = morphology(img_bs_thr,2,'close');
    img_bs_thr_smooth = removeNoise(img_bs_thr_smooth);
    img_bs_thr_smooth = removeRegions(img_bs_thr_smooth,'smaller',150);
    
    % three frame temporal differencing
    imgs_histeq_last = histeqRGB(imgs_last);
    img_diff = oneFrameDiff(img_histeq,'Normalize',imgs_histeq_last);
%     img_diff = threeFrameDiff(img_histeq,'Normalize',imgs_histeq_last2);
    img_diff_thr = rgb2gray(img_diff);
    img_diff_thr = im2bw(img_diff_thr,0.1);
    img_diff_thr_smooth = morphology(img_diff_thr,2,'close');
    img_diff_thr_smooth = removeNoise(img_diff_thr_smooth);
    img_diff_thr_smooth = removeRegions(img_diff_thr_smooth,'smaller',150);
    
    % combine results
    IICD = img_bs_thr_smooth & img_diff_thr_smooth;
    
    % return images
    imgs_IICD.img_histeq = img_histeq;
    imgs_IICD.img_bg_histeq = img_bg_histeq;
    imgs_IICD.img_bs = img_bs;
    imgs_IICD.img_bs_thr = img_bs_thr;
    imgs_IICD.img_bs_thr_smooth = img_bs_thr_smooth;
    imgs_IICD.img_diff = img_diff;
    imgs_IICD.img_diff_thr = img_diff_thr;
    imgs_IICD.img_diff_thr_smooth = img_diff_thr_smooth;
end

