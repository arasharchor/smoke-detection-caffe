function imgs_filtered = textureSeg( img,filter_bank )
    % local contrast normalization
    img_lcn = mat2gray(localnormalize(double(gaussianSmooth(img,0.5)),128,128));
%     img_lcn = histeqRGB(img_lcn);
    
    % color adjustment
    img_adj = imadjustRGB(img);

    % histogram equalization
    img_histeq = histeqRGB(img);
    
    % normalize image
    img_normalized = double(img_histeq);
    for i=1:size(img,3)
        channel = img_normalized(:,:,i);
        img_normalized(:,:,i) = (channel - mean(channel(:)))./255;
    end
    
    % compute texture features using the filter bank
    feature = zeros([size(img,1),size(img,2),size(filter_bank,3)*3]);
    for k=1:size(filter_bank,3)
        feature(:,:,k*3-2:k*3) = mat2gray(imfilter(img_normalized,filter_bank(:,:,k),'same','conv','replicate'));
    end
    size_origin = size(feature);
    feature = single(reshape(feature,[],size(feature,3)));
    
    % principal component analysis
    [coeff,~,latent] = pca(feature);
    ratio = 0.95;
    bound = ratio*sum(latent);
    accum = 0;
    for p=1:numel(latent)
        accum = accum + latent(p);
        if(accum >= bound)
            break;
        end
    end
    coeff = coeff(:,1:p);
    feature = feature*coeff;

    % k-means clustering
    K = 30;
    [~,idx] = vl_kmeans(feature',K,'maxNumIterations',5,'algorithm','elkan','initialization','plusplus','NumRepetitions',2);
    tex = uint8(reshape(idx,size_origin(1),size_origin(2)));
    cluster = 1:K;
    
    % filter the texture image
    tex_filtered = removeSmallRegions(tex,30);
    tex_filtered = removeLabelNoise(tex_filtered);
    tex_filtered = removeSmallRegions(tex_filtered,50);
    
    % remove non-grayish segments
    tex_rm_nongray = tex_filtered;
    r = img_histeq(:,:,1);
    g = img_histeq(:,:,2);
    b = img_histeq(:,:,3);
    rg_thr = 0.1;
    gb_thr = 0.1;
    rb_thr = 0.15;
    img_gray_px = abs(r-g)<rg_thr & abs(r-b)<rb_thr & abs(g-b)<gb_thr;
    tex_rm_nongray(~img_gray_px) = 0;
    tex_rm_nongray_filtered = removeSmallRegions(tex_rm_nongray,50);
    tex_rm_nongray_filtered = morphology(tex_rm_nongray_filtered,2,'close');
    tex_rm_nongray_filtered = removeSmallRegions(tex_rm_nongray_filtered,200);
%     rg_thr = 0.07;
%     gb_thr = 0.07;
%     rb_thr = 0.07;
%     for i=1:numel(cluster)
%         idx_label = (tex==cluster(i));
%         r_med = median(r(idx_label));
%         g_med  = median(g(idx_label));
%         b_med  = median(b(idx_label));
%         if(abs(r_med-g_med)>rg_thr || abs(r_med-b_med)>rb_thr || abs(g_med-b_med)>gb_thr)
%             tex_rm_nongray(idx_label) = 0;
%             cluster(i) = 0;
%         end
%     end
%     cluster(cluster==0) = [];
    
    % remove non-black segments
    tex_rm_nonblack = tex_rm_nongray_filtered;
    r = img_histeq(:,:,1);
    g = img_histeq(:,:,2);
    b = img_histeq(:,:,3);
    r_thr = 0.5;
    g_thr = 0.5;
    b_thr = 0.6;
    img_black_px = r<r_thr & g<g_thr & b<b_thr;
    tex_rm_nonblack(~img_black_px) = 0;
%     r_thr = 0.35;
%     g_thr = 0.35;
%     b_thr = 0.4;
%     for i=1:numel(cluster)
%         idx_label = (tex==cluster(i));
%         r_med = median(r(idx_label));
%         g_med  = median(g(idx_label));
%         b_med  = median(b(idx_label));
%         if(r_med>r_thr && g_med>g_thr && b_med>b_thr)
%             tex_rm_white(idx_label) = 0;
%             cluster(i) = 0;
%         end
%     end
%     cluster(cluster==0) = [];
    
    % remove pixels that have non-black and non-white texture in the current image
    tex_rm_highfreq = tex_rm_nonblack;
    img_DoG = mat2gray(abs(diffOfGaussian(img_lcn,0.5,3)));
%     img_DoG = imadjustRGB(img_DoG);
    img_entropy = mat2gray(entropyfilt(img_DoG,true(9,9)));
    img_entropy = bilateralSmooth(img_entropy,0.2,10);
    r = img_entropy(:,:,1);
    g = img_entropy(:,:,2);
    b = img_entropy(:,:,3);
    r_whi_thr = 0.45;
    g_whi_thr = 0.45;
    b_whi_thr = 0.55;
    r_bla_thr = 0.5;
    g_bla_thr = 0.5;
    b_bla_thr = 0.65;
    img_entropy_white_px = r>r_whi_thr & g>g_whi_thr & b>b_whi_thr;
    img_entropy_black_px = r<r_bla_thr & g<g_bla_thr & b<b_bla_thr;
    tex_rm_highfreq(~(img_entropy_white_px | img_entropy_black_px)) = 0;
    
    % image morphology and smoothing
    tex_clean = tex_rm_highfreq;
%     tex_clean = removeLabelNoise(tex_clean);
%     tex_clean = morphology(tex_clean,1,'close');
%     tex_clean = morphology(tex_clean,2,'open');
%     tex_clean = removeSmallRegions(tex_clean,50);
%     tex_clean = morphology(tex_clean,2,'open');
%     tex_clean = removeSmallRegions(tex_clean,50);
%     tex_clean = morphology(tex_clean,2,'close');
    
    % return images
    imgs_filtered.img_lcn = img_lcn;
    imgs_filtered.img_adj = img_adj;
    imgs_filtered.img_histeq = img_histeq;
    imgs_filtered.tex = tex;
    imgs_filtered.tex_filtered = tex_filtered;
    imgs_filtered.img_gray_px = img_gray_px;
    imgs_filtered.tex_rm_nongray = tex_rm_nongray;
    imgs_filtered.tex_rm_nongray_filtered = tex_rm_nongray_filtered;
    imgs_filtered.img_black_px = img_black_px;
    imgs_filtered.tex_rm_nonblack = tex_rm_nonblack;
    imgs_filtered.img_entropy = img_entropy;
    imgs_filtered.img_entropy_white_px = img_entropy_white_px;
    imgs_filtered.img_entropy_black_px = img_entropy_black_px;
    imgs_filtered.tex_rm_highfreq = tex_rm_highfreq;
    imgs_filtered.tex_clean = tex_clean;
    imgs_filtered.img_DoG = img_DoG;
end

