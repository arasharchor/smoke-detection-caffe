function [ img_DoG ] = diffOfGaussian( img, sigma, K )
    img = rgb2gray(img);
    sigma1 = sigma;
    sigma2 = sigma*K;
    img_DoG = gaussianSmooth(img,sigma1) - gaussianSmooth(img,sigma2);
    img_DoG = im2double(img_DoG);
end

