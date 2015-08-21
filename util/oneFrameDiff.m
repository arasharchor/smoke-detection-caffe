function img_diff = oneFrameDiff( img,option,img_last )
    narginchk(1,3);
    img = double(img);
    img1 = double(img_last);
    img_diff = abs((img-img1)); 
    if(nargin == 2 && strcmp(option,'Normalize'))
        img_diff = img_diff_1./(img+img1);
    end
    img_diff(isnan(img_diff)) = 0;
end

