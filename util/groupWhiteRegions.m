function label_clean = groupWhiteRegions( label,img,thr )
    channel_idx = unique(label);
    channel_idx(channel_idx==0) = [];
    label_clean = zeros(size(label),'uint8');
    white_idx = -1;
    for c=1:numel(channel_idx)
        channel = double(label==channel_idx(c));
        CC = bwconncomp(channel);
        for i=1:CC.NumObjects
            idx = CC.PixelIdxList{i};
            r = img(:,:,1);
            g = img(:,:,2);
            b = img(:,:,3);
            if(median(r(idx))>thr && median(g(idx))>thr && median(b(idx))>thr)
                if(white_idx == -1)
                    white_idx = c;
                end
                channel(idx) = 0.5;
            end
        end
        label_clean(channel~=0) = channel_idx(c);
        label_clean(channel==0.5) = white_idx;
    end
end

