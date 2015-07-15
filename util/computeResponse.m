function [ responses,imgs_filtered ] = computeResponse( imgs )
    % image smoothing
    imgs_smooth = gaussianSmooth(imgs,0.5);
    
    % convert to hsv
    imgs_hsv = rgb2hsv_4D(imgs_smooth);
    imgs_filtered.img_s = imgs_hsv(:,:,2,end);
    responses.img_s = sum(imgs_filtered.img_s(:));
    imgs_filtered.img_v = imgs_hsv(:,:,3,end);
    responses.img_v = sum(imgs_filtered.img_v(:));
    
    % three frame differencing
    img_hsv_diff = threeFrameDiff(imgs_hsv,'Normalize');
    imgs_filtered.img_s_diff = img_hsv_diff(:,:,2);
    responses.img_s_diff = sum(imgs_filtered.img_s_diff(:));
    imgs_filtered.img_v_diff = img_hsv_diff(:,:,3);
    responses.img_v_diff = sum(imgs_filtered.img_v_diff(:));
    
    % compute difference of Gaussian
    imgs_DoG = diffOfGaussian(imgs_smooth,0.5,3);
    imgs_filtered.img_DoG = imgs_DoG(:,:,:,end);
    responses.img_DoG = sum(imgs_filtered.img_DoG(:));
    
    % three frame differencing of DoG
    img_DoG_diff = threeFrameDiff(imgs_DoG);
    imgs_filtered.img_DoG_diff = img_DoG_diff;
    responses.img_DoG_diff = sum(img_DoG_diff(:));
    
    % compute entropy image of temporal difference
    img_entropy = entropyfilt(img_hsv_diff(:,:,3),ones(9));
    imgs_filtered.img_entropy = img_entropy;
    responses.img_entropy = sum(img_entropy(:));
    
    % compute rgb color sum and diff
    imgs_smooth_double = im2double(imgs_smooth);
    responses.img_rgb_sum = sum(imgs_smooth_double(:));
    responses.img_rgb_diff = rgbDiff(imgs_smooth_double);
    
    % compute wavelet energy
    [cA,cH,cV,cD] = dwt2(imgs_smooth(:,:,:,end),'db1');
    responses.wavelet_energy = sum(cH(:).^2+cV(:).^2+cD(:).^2);
end