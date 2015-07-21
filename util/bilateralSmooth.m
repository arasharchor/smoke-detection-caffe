function img_smooth = bilateralSmooth( img )
    sigma_RGB = 0.125;
    sigma_spatial = 10;
    img_smooth = zeros(size(img));
    bilateral_filter(im2double(img),img_smooth,size(img_smooth,1),size(img_smooth,2),10,sigma_spatial,sigma_RGB);
    img_smooth = uint8(255.*img_smooth);
end

