function js = array2json( arr )
    js = 'smoke_detection = {values:[';
    L = numel(arr);
    for i=1:L
        js = [js,num2str(arr(i))];
        if(i~=L)
            js = [js,','];
        else
            js = [js,']};'];
        end
    end
end

