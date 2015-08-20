function [ val,imgs_filtered ] = detectSmoke3( img,img_bg,filter_bank )
    % first pass: high frequency change detection
    [HFCD,imgs_HFCD] = highFreqChangeDetection(img,img_bg);
    imgs_filtered.imgs_HFCD = imgs_HFCD;
    imgs_filtered.HFCD = HFCD;
    
    % second pass: image intensity change detection
    if(sum(imgs_filtered.HFCD(:))>0)
        [IICD,imgs_IICD] = imgIntensityChangeDetection(img,img_bg);
        imgs_filtered.imgs_IICD = imgs_IICD;
        imgs_filtered.IICD = IICD;
        % combine HFCD and IICD
        HFCD_IICD = HFCD & IICD;
        HFCD_IICD = im2bw(removeRegions(HFCD_IICD,'smaller',150),0);
        imgs_filtered.HFCD_IICD = HFCD_IICD;
    else
        imgs_filtered.HFCD_IICD = false(size(img,1),size(img,2));
    end
    
    % third pass: texture segmentation and basic region filter
    if(sum(imgs_filtered.HFCD_IICD(:))>0)
        [TS,imgs_TS] = textureSegmentation(img,filter_bank);
        imgs_filtered.imgs_TS = imgs_TS;
        imgs_filtered.TS = TS;
        [BRF,imgs_BRF] = regionFilter(img,TS,imgs_IICD,HFCD_IICD);
        imgs_filtered.imgs_BRF = imgs_BRF;
        imgs_filtered.BRF = BRF;
        val = sum(BRF(:));
    else
        imgs_filtered.BRF = false(size(img,1),size(img,2));
        val = 0;
    end
end