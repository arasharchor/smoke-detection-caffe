function fscore = computeFscore( label_raw,predict_raw )
    [label_start_raw,label_end_raw] = computeSegments(label_raw);
    [predict_start_raw,predict_end_raw] = computeSegments(predict_raw);
    
    % merge unreasonable labels
    [label_start,label_end,label] = mergeSegments(label_start_raw,label_end_raw,label_raw);
    [predict_start,predict_end,predict] = mergeSegments(predict_start_raw,predict_end_raw,predict_raw);
    
    % compute true positives and false positives
    % 30% of the predictons in a segment are true labels
    TP = 0;
    FP = 0;
    for i=1:numel(predict_start)
        idx = predict_start(i):predict_end(i);
        if(sum(label(idx))/numel(idx)>0.3)
            TP = TP + 1;
        else
            FP = FP + 1;
        end
    end
    
    % compute false negatives
    FN = 0;
    for i=1:numel(label_start)
        idx = label_start(i):label_end(i);
        if(sum(predict(idx))==0)
            FN = FN + 1;
        end
    end

    % compute f-score
    precision = TP/(TP+FP);
    recall = TP/(TP+FN);
    score = (2*precision*recall)/(precision+recall);
    
    fscore.TP = TP;
    fscore.FP = FP;
    fscore.FN = FN;
    fscore.precision = precision;
    fscore.recall = recall;
    fscore.score = score;
end

