function [ BRF,imgs_BRF ] = regionFilter( img,TS,imgs_IICD,HFCD_IICD )
    % group white color segments
    img_adj = imadjustRGB(img);
    tex_seg_group_white = groupWhiteRegions(TS,img_adj,0.7);
    
    % remove nongray regions
    tex_seg_gray = removeRegions(tex_seg_group_white,'nonGray',[0.1 0.1 0.2],imgs_IICD.img_histeq);
    
    % remove segments which do not have enough changes
    tex_seg_change = removeRegions(tex_seg_gray,'noChange',0.8,HFCD_IICD);

    % return images
    imgs_BRF.img_adj = img_adj;
    imgs_BRF.tex_seg_group_white = tex_seg_group_white;
    imgs_BRF.tex_seg_gray = tex_seg_gray;
    BRF = im2bw(tex_seg_change,0);
end

