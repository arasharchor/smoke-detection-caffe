function [ responses,imgs_filtered ] = detectSmoke( img,imgs_bg )
    % image smoothing
    img_smooth = gaussianSmooth(img,0.5);
    
    % background subtraction
    imgs_bs = zeros(size(imgs_bg));
    for i=1:size(imgs_bs,4)
        img_bs = backgroundSubtraction(img_smooth,imgs_bg(:,:,:,i),'Normalize');
        % remove noise and small regions
        img_bs = morphology(img_bs,5);
        img_bs = removeNoise(img_bs);
        img_bs = removeSmallRegions(img_bs,100);
        imgs_bs(:,:,:,i) = img_bs;
    end

    % return
    imgs_filtered.img_bs_60 = imgs_bs(:,:,:,1);
    responses.img_bs_60 = sum(imgs_filtered.img_bs_60(:));
    imgs_filtered.img_bs_120 = imgs_bs(:,:,:,2);
    responses.img_bs_120 = sum(imgs_filtered.img_bs_120(:));
    imgs_filtered.img_bs_360 = imgs_bs(:,:,:,3);
    responses.img_bs_360 = sum(imgs_filtered.img_bs_360(:));
    imgs_filtered.img_bs_720 = imgs_bs(:,:,:,4);
    responses.img_bs_720 = sum(imgs_filtered.img_bs_720(:));
end

