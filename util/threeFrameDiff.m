function [ img_diff ] = threeFrameDiff( imgs, option )
    narginchk(1,2);

    img1 = double(imgs{end});
    img2 = double(imgs{end-1});
    img3 = double(imgs{end-2});
    if(nargin == 1)
        img_diff_1 = abs((img1-img2)./(img1+img2));
        img_diff_2 = abs((img1-img3)./(img1+img3));
    else
        if(strcmp(option,'noNormalization'))
            img_diff_1 = abs((img1-img2));
            img_diff_2 = abs((img1-img3));
        end
    end
    img_diff = (img_diff_1 + img_diff_2)./2;
    img_diff(isnan(img_diff)) = 0;
end

