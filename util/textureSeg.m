function tex = textureSeg( img )
    % compute Laws' texture energy measures for segmentation
    kernel{1} = [1,4,6,4,1]; % L5 = average gray level
    kernel{2} = [-1,-2,0,2,1]; % E5 = edges
    kernel{3} = [-1,0,2,0,-1]; % S5 = spots
    kernel{4} = [1,-4,6,-4,1]; % R5 = ripples
    kernel{5} = [-1,2,0,-2,1]; % W5 = waves
    filter = zeros(5,5,25);
    for i=1:5
        for j=1:5
            filter(:,:,(i-1)*5+j) = kernel{i}'*kernel{j};
        end
    end
    
    % compute texture features
    feature = zeros([size(img,1),size(img,2),size(filter,3)*3]);
    for k=1:size(filter,3)
        feature(:,:,k*3-2:k*3) = mat2gray(imfilter(img,filter(:,:,k),'same','conv','replicate'));
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
    [~,idx] = vl_kmeans(feature',15,'maxNumIterations',5,'algorithm','elkan','initialization','plusplus');
    
    % smoothing
    tex = uint8(reshape(idx,size_origin(1),size_origin(2)));
    tex = morphology(tex,1);
    tex = removeSmallRegions(tex,200);
end

