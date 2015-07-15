function [ img_diff ] = threeFrameDiff( imgs,option )
    narginchk(1,2);
    imgs = double(imgs);
    img1 = imgs(:,:,:,1);
    img2 = imgs(:,:,:,2);
    img3 = imgs(:,:,:,3);
    img_diff_1 = abs((img3-img1));
    img_diff_2 = abs((img3-img2));    
    if(nargin == 2 && strcmp(option,'Normalize'))
        img_diff_1 = img_diff_1./(img3+img1);
        img_diff_2 = img_diff_2./(img3+img2);
    end
    img_diff = (img_diff_1 + img_diff_2)./2;
    img_diff(isnan(img_diff)) = 0;
end

