function js = array2json( vec,predict )
    % encode vector
    js = ['var smoke_detection = {values:',array2Str(vec),'};'];
    % encode prediction
    [frames_start,frames_end] = computeSegments(predict);
    js = [js,'var frames_start = ',array2Str(frames_start),';'];
    js = [js,'var frames_end = ',array2Str(frames_end),';'];
end

