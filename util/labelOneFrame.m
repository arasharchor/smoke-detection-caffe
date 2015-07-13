function labelOneFrame( t,num_frames,data_mat,label_mat,has_label_mat )
    set(gca,'position',[0 0 1 1]);
    ROI = roipoly(permute(squeeze(data_mat.data(t,:,:,:)),[2 3 1]));
    if(numel(ROI)~=0)
        fprintf('Frame %d / %d saved\n',t,num_frames);
        label_mat.label(t,:,:,:) = permute(ROI,[4 3 1 2]);
        has_label_mat.has_label(t,:) = true;
    end
    showOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
end

