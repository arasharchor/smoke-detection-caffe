function js = array2json( vec,predict )
    % encode vector
    js = ['var smoke_detection = {values:',array2Str(vec),'};'];
    % encode prediction
    predict_diff = diff(predict);
    frames_start = find(predict_diff==1)+1;
    frames_end = find(predict_diff==-1);
    js = [js,'var frames_start = ',array2Str(frames_start),';'];
    js = [js,'var frames_end = ',array2Str(frames_end),';'];
end

