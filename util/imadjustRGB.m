function img_adj = imadjustRGB( img )
    img_adj = rgb2hsv(img);
    img_adj(:,:,3) = imadjust(img_adj(:,:,3));
    img_adj = hsv2rgb(img_adj);
end

