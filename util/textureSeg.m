function imgs_filtered = textureSeg( img,filter_bank )
    % color adjustment
    img_adj = imadjustRGB(img);

    % normalize image
    img_normalized = double(img_adj);
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
    K = 40;
    [~,idx] = vl_kmeans(feature',K,'verbose','maxNumIterations',5,'algorithm','elkan','initialization','plusplus','NumRepetitions',2);
    tex = uint8(reshape(idx,size_origin(1),size_origin(2)));
    cluster = 1:K;
    
    % remove white segments
    img_gray = rgb2gray(img_adj);
    for i=1:numel(cluster)
        idx_label = (tex==cluster(i));
        thr = 0.6;
        if(median(img_gray(idx_label))>thr)
            tex(idx_label) = 0;
            cluster(i) = 0;
        end
    end
    cluster(cluster==0) = [];
    
    % remove non-grayish segments
    img_r = img_adj(:,:,1);
    img_g = img_adj(:,:,2);
    img_b = img_adj(:,:,3);
    for i=1:numel(cluster)
        idx_label = (tex==cluster(i));
        thr = 0.1;
        r = median(img_r(idx_label));
        g = median(img_g(idx_label));
        b = median(img_b(idx_label));
        if(abs(r-g)>thr || abs(r-b)>thr || abs(g-b)>thr)
            tex(idx_label) = 0;
            cluster(i) = 0;
        end
    end
    cluster(cluster==0) = [];
    
    % image morphology and smoothing
    tex = removeLabelNoise(tex);
    tex = morphology(tex,1,'close');
    tex = morphology(tex,2,'open');
    tex = removeSmallRegions(tex,50);
    tex = morphology(tex,2,'open');
    tex = removeSmallRegions(tex,100);
    tex = morphology(tex,2,'close');
    
    % remove pixels that have non-grayish texture in the current image
    img_DoG = mat2gray(abs(diffOfGaussian(img,0.5,3)));
%     img_DoG = morphology(img_DoG,5,'close');
    img_DoG = imadjustRGB(img_DoG);
    img_DoG_entropy = mat2gray(entropyfilt(img_DoG,true(9,9)));
	img_DoG_entropy = bilateralSmooth(img_DoG_entropy,0.2,10);
%     img_DoG_entropy = imadjustRGB(img_DoG_entropy);
    r = img_DoG_entropy(:,:,1);
    g = img_DoG_entropy(:,:,2);
    b = img_DoG_entropy(:,:,3);
    thr = 0.15;
    img_DoG_entropy_gray = abs(r-g)<thr & abs(r-b)<thr & abs(g-b)<thr;
    tex(~img_DoG_entropy_gray) = 0;
    imgs_filtered.img_DoG_entropy = img_DoG_entropy;
    imgs_filtered.img_DoG_entropy_gray = img_DoG_entropy_gray;
    
    imgs_filtered.img_adj = img_adj;
    imgs_filtered.tex = tex;
    imgs_filtered.img_DoG = img_DoG;
end

