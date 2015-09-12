function fscore = computeFscore( label,predict )
    [label_start_raw,label_end_raw] = computeSegments(label);
    [predict_start_raw,predict_end_raw] = computeSegments(predict);
    
    % merge unreasonable labels
    thr = 30;
    label_start = [];
    label_end = [];
    while numel(label_start_raw)>1
        if(label_start_raw(2)-label_end_raw(1)<thr)
            label_end_raw(1) = label_end_raw(2);
            label(label_end_raw(1):label_start_raw(2)) = 1;
            label_start_raw(2) = [];
            label_end_raw(2) = [];
        else
            label_start(end+1) = label_start_raw(1);
            label_end(end+1) = label_end_raw(1);
            label_start_raw(1) = [];
            label_end_raw(1) = [];
        end
    end
    label_start(end+1) = label_start_raw(1);
    label_end(end+1) = label_end_raw(1);
    
    % merge unreasonable predictions
    predict_start = [];
    predict_end = [];
    while numel(predict_start_raw)>1
        if(predict_start_raw(2)-predict_end_raw(1)<thr)
            predict_end_raw(1) = predict_end_raw(2);
            predict(predict_end_raw(1):predict_start_raw(2)) = 1;
            predict_start_raw(2) = [];
            predict_end_raw(2) = [];
        else
            predict_start(end+1) = predict_start_raw(1);
            predict_end(end+1) = predict_end_raw(1);
            predict_start_raw(1) = [];
            predict_end_raw(1) = [];
        end
    end
    predict_start(end+1) = predict_start_raw(1);
    predict_end(end+1) = predict_end_raw(1);
    
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

