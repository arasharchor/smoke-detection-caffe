function img_histeq = histeqRGB( img )
    img_histeq = rgb2hsv(img);
%     img_histeq(:,:,3) = histeq(img_histeq(:,:,3));
    img_histeq(:,:,3) = adapthisteq(img_histeq(:,:,3));
    img_histeq = hsv2rgb(img_histeq);
end

