function label_clean = removeRegions( label,option,thr1,img,thr2 )
    narginchk(3,5)
    channel_idx = unique(label);
    channel_idx(channel_idx==0) = [];
    label_clean = zeros(size(label),'uint8');
    if(nargin>=4 && size(img,3)>1)
        r = img(:,:,1);
        g = img(:,:,2);
        b = img(:,:,3);
    end
    for c=1:numel(channel_idx)
        channel = (label==channel_idx(c));
        CC = bwconncomp(channel);
        if(strcmp(option,'nonRect'))
            stats = regionprops(CC,'BoundingBox');
        end
        for i=1:CC.NumObjects
            idx = CC.PixelIdxList{i};
            if(strcmp(option,'smaller'))
                if(numel(idx)<thr1)
                    channel(idx) = 0;
                end
            elseif(strcmp(option,'larger'))
                if(numel(idx)>thr1)
                    channel(idx) = 0;
                end
            elseif(strcmp(option,'largerAndWhiter'))
                if(numel(idx)>thr1 && median(r(idx))>thr2 && median(g(idx))>thr2 && median(b(idx))>thr2)
                    channel(idx) = 0;
                end
            elseif(strcmp(option,'nonGray'))
                median_r = median(r(idx));
                median_g = median(g(idx));
                median_b = median(b(idx));
                if(abs(median_r-median_g)>thr1(1) || abs(median_g-median_b)>thr1(2) || abs(median_r-median_b)>thr1(3))
                    channel(idx) = 0;
                end
            elseif(strcmp(option,'noChange'))
                if(sum(img(idx))/numel(idx)<thr1)
                    channel(idx) = 0;
                end
            elseif(strcmp(option,'nonWhite'))
                img_gray = im2double(rgb2gray(img));
                median(img_gray(idx))
                if(median(img_gray(idx))>thr1)
                    channel(idx) = 0;
                end
            elseif(strcmp(option,'nonRect'))
                bbox = stats(i).BoundingBox;
                if(bbox(3)/bbox(4)>thr1 && numel(idx)/(bbox(3)*bbox(4))>thr2)
                    channel(idx) = 0;
                elseif(bbox(3)/bbox(4)>thr1*1.5)
                    channel(idx) = 0;
                end
            end
        end
        label_clean(channel~=0) = channel_idx(c);
    end
end

