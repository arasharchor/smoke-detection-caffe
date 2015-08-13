function [ img_clean ] = removeSmallRegions( img,thr )
    channel_idx = unique(img);
    img_clean = zeros(size(img),'uint8');
    for c=1:numel(channel_idx)
        channel = (img==channel_idx(c));
        CC = bwconncomp(channel);
        for i=1:CC.NumObjects
            idx = CC.PixelIdxList{i};
            if(numel(idx)<thr)
                channel(idx) = 0;
            end
        end
        img_clean(channel~=0) = channel_idx(c);
    end
end

