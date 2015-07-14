function showOneFrame( t,num_frames,data_mat,label_mat,has_label_mat )
    set(gca,'position',[0 0 1 0.97]);
    data = squeeze(data_mat.data(:,:,:,t));
    label = squeeze(label_mat.label(:,:,:,t));
    has_label = has_label_mat.has_label(:,t);
    imshow(imfuse(data,imfuse(data,label),'montage'))
    title(sprintf('Viewing frame %d / %d , hasLabel = %d (press ENTER to label this frame, ESC to exit when labeling, DELETE to delete the label)',t,num_frames,has_label))
    fprintf('Viewing frame %d / %d , hasLabel = %d\n',t,num_frames,has_label);
end