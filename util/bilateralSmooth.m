function imgs_smooth = bilateralSmooth( imgs )
    sigma_RGB = 0.2;
    sigma_spatial = 10;
    imgs_smooth = zeros(size(imgs));
    for i=1:size(imgs,4)
        for j=1:size(imgs,3)
            img = im2double(imgs(:,:,j,i));
            imgs_smooth(:,:,j,i) = bilateralFilter(img,[],0,1,sigma_spatial,sigma_RGB);
        end
    end    
end

