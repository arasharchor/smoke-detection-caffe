function imgs_bg = computeBackground( imgs,use_gpu_array )
    num_frames = size(imgs,3);
    imgs_bg = zeros(size(imgs,1),size(imgs,2),num_frames,'uint8');    
end

