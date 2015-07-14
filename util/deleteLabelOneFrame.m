function deleteLabelOneFrame( t,num_frames,data_mat,label_mat,has_label_mat )
    fprintf('Frame %d / %d deleted\n',t,num_frames);
    label = label_mat.label(:,:,:,t);
    label(:) = false;
    label_mat.label(:,:,:,t) = label;
    has_label_mat.has_label(:,t) = false;
    showOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
end

