function [ img_morph ] = morphology( img,level )
    channel = cell(1,1,size(img,3));
    se = strel('disk',level);
    for i=1:size(img,3)
        img_c = img(:,:,i);
        img_c = imclose(im2uint8(img_c),se);
        channel{i} = img_c;
    end
    img_morph = cell2mat(channel);
end

