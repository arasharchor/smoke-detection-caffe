function [ BRF,imgs_BRF ] = regionFilter( img,TS,imgs_IICD,HFCD_IICD )
    % remove segments which do not have correct shapes
    tex_seg_shape = removeRegions(TS,'nonRect',2.5,[],0.4);

    % group white color segments
    img_adj = imadjustRGB(img);
    tex_seg_group_white = groupWhiteRegions(tex_seg_shape,img_adj,0.6);
    
    % remove nongray regions
    tex_seg_gray = removeRegions(tex_seg_group_white,'nonGray',[0.1 0.1 0.15],imgs_IICD.img_histeq);
    
    % remove large regions
    tex_seg_size = removeRegions(tex_seg_gray,'larger',numel(img(:,:,1))*0.15);
    
    % remove segments which do not have enough changes
    tex_seg_change = removeRegions(tex_seg_size,'noChange',0.7,HFCD_IICD);
    tex_seg_change = removeRegions(tex_seg_change,'smaller',20);
    
    % return images
    imgs_BRF.tex_seg_shape = tex_seg_shape;
    imgs_BRF.img_adj = img_adj;
    imgs_BRF.tex_seg_group_white = tex_seg_group_white;
    imgs_BRF.tex_seg_gray = tex_seg_gray;
    imgs_BRF.tex_seg_size = tex_seg_size;
    imgs_BRF.tex_seg_change = tex_seg_change;
    BRF = im2bw(tex_seg_change,0);
end

