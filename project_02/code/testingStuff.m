clear all, close all

% ------------ EXEMPLE 1 ------------------- %

vid = VideoReader('training_video.mp4');
nFrames = vid.Duration * vid.FrameRate;
%step = 20;

img = rgb2gray(readFrame(vid));
bkg = zeros(size(img));

%alpha = 0.01;
figure;
for i=1 : nFrames
    alpha = 1/i; %each frame counts equally in the overral calculation
    i
    img = readFrame(vid);
    Y = rgb2gray(img);
    
    %showing original image
    subplot(2,3,1);
    imshow(img); 
    title('Original Image');
   
    subplot(2,3,2);
    imshow(Y); 
    title('Original Image (BW)');  
    
    %showing background estimation
    bkg = alpha * double(Y) + (1-alpha) * double(bkg);
    bkgImage = uint8(bkg); 
    subplot(2,3,3);
    imshow(bkgImage); 
    title('Background Estimation (BW)');
    
    %showing image difference
    differenceImage = imabsdiff(Y,bkgImage);
    subplot(2,3,4);
    imshow(differenceImage);
    title('Image Difference');
    
    %calculating correct threshold
    subplot(2,3,5);
    differenceImgBW = im2bw(differenceImage, 0.1);
    imshow(differenceImgBW);
    title('Binary Difference');
    
    subplot(2,3,6);
    seOpen = strel('disk', 5);
    seClose = strel('disk', 2);
    transformedImage = imclose(imopen(differenceImgBW, seClose), seOpen); 
    imshow(transformedImage);
    title('Binary Difference Transformed');
   
    drawnow
end

