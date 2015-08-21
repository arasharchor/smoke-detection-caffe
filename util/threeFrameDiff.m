function img_diff = threeFrameDiff( img,option,imgs_last2 )
    narginchk(1,3);
    img = double(img);
    img1 = double(imgs_last2(:,:,:,1));
    img2 = double(imgs_last2(:,:,:,2));
    img_diff_1 = abs((img-img1));
    img_diff_2 = abs((img-img2));    
    if(nargin == 2 && strcmp(option,'Normalize'))
        img_diff_1 = img_diff_1./(img+img1);
        img_diff_2 = img_diff_2./(img+img2);
    end
    img_diff = (img_diff_1 + img_diff_2)./2;
    img_diff(isnan(img_diff)) = 0;
end

