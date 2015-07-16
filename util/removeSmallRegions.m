function [ img_clean ] = removeSmallRegions( img,thr )
    CC = bwconncomp(img);
    img_clean = img;
    for i=1:CC.NumObjects
        idx = CC.PixelIdxList{i};
        if(numel(idx)<thr)
            img_clean(idx) = 0;
        end
    end
end

