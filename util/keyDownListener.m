function keyDownListener( src,event,num_frames,data_mat,label_mat,has_label_mat )
    global t
    if(strcmp(event.Key,'rightarrow') && t<num_frames)
        t = t + 1;
        showOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
    elseif(strcmp(event.Key,'leftarrow') && t>1)
        t = t - 1;
        showOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
    elseif(strcmp(event.Key,'return'))
        labelOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
    elseif(strcmp(event.Key,'delete'))
        deleteLabelOneFrame(t,num_frames,data_mat,label_mat,has_label_mat);
    end
end