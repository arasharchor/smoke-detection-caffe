function imgs_median = computeMedian( imgs )
    num_frames = size(imgs,3);
    imgs_median = zeros(size(imgs,1),size(imgs,2),num_frames,'uint8');
    range = 100;
    ptr_end = range;
    pool = imgs(:,:,1:range);
    for t=1:num_frames
        fprintf('Processing frame %d\n',t);
        if t > range && t < num_frames-range+1
            ptr_end = ptr_end + 1;
            pool = circshift(pool,-1,3);
            pool(:,:,end) = imgs(:,:,ptr_end);
        end
        imgs_median(:,:,t) = mean(pool,3);
    end
end