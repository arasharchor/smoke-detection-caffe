function [ IICD,imgs_IICD ] = imgIntensityChangeDetection( img,img_bg )
    % background subtraction
    img_histeq = histeqRGB(img);
    img_bg_histeq = histeqRGB(img_bg);
    img_bs = backgroundSubtraction(img_histeq,img_bg_histeq,'Normalize');
    img_bs_thr = rgb2gray(img_bs);
    img_bs_thr = im2bw(img_bs_thr,0.08);
    img_bs_thr_smooth = morphology(img_bs_thr,2,'close');
    img_bs_thr_smooth = removeNoise(img_bs_thr_smooth);
    img_bs_thr_smooth = removeRegions(img_bs_thr_smooth,'smaller',150);
    
    % return images
    imgs_IICD.img_histeq = img_histeq;
    imgs_IICD.img_bg_histeq = img_bg_histeq;
    imgs_IICD.img_bs = img_bs;
    imgs_IICD.img_bs_thr = img_bs_thr;
    IICD = img_bs_thr_smooth;
end

