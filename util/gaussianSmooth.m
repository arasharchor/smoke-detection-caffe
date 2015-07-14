function [ img_smooth ] = gaussianSmooth( img, sigma )
    channel = cell(1,1,size(img,3));
    width = 2*ceil(3*sigma)+1;
    h = fspecial('gaussian',[width width],sigma);
    for i=1:size(img,3)
        img_c = img(:,:,i);
        img_c = imfilter(img_c,h,'same');
        channel{i} = img_c;
    end
    img_smooth = cell2mat(channel);
end

