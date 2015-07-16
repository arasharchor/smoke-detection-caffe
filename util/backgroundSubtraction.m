function img_bs = backgroundSubtraction( img,img_bg,option )
    narginchk(2,3);
    img = double(img);
    img_bg = double(img_bg);
    img_bs = abs((img-img_bg));
    if(nargin == 3 && strcmp(option,'Normalize'))
        img_bs = img_bs./(img+img_bg);
    end
    img_bs(isnan(img_bs)) = 0;
end