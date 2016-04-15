clear all; close all;

img = imread('Moedas1.jpg');

imgDummy = uint8(zeros(size(img,1), size(img,2), size(img,3)));
imgR = img(:,:,1);
imgG = img(:,:,2);
imgB = img(:,:,3);


imgHSV = uint8(rgb2hsv(img)*255); 
imgH = imgHSV(:,:,1); 
imgS = imgHSV(:,:,2); 
imgV = imgHSV(:,:,3); 

imshow(img); title('Original');

figure, imshow(imgR); title('Image in Red');
figure, imshow(imgG); title('Image in Gree');
figure, imshow(imgB); title('Image in Blue');

figure, imshow(imgH); title('Image in Hue');
figure, imshow(imgS); title('Image in Saturation');
figure, imshow(imgV); title('Image in Value');

imgg = imgH;
figure, imhist(imgg);

BW = imgg<128;
figure, imshow(BW); title('Original BW');
se = strel('disk', 3);
%se = strel('line', 3, 45);
%se = strel('square', 3);
%se = strel('ball', 3, 3, 2);

BW1 = imerode(BW, se);
figure, imshow(BW1); title('Erode');

perimeterMask = BW-BW1;
figure, imshow(perimeterMask); title('Perimeter Mask');

imgWithPerimeter = img;

[perimeterRow, perimeterCol] = find(perimeterMask==1);

perimeterIndexes = sub2ind([size(perimeterMask, 1), size(perimeterMask, 2)], perimeterRow, perimeterCol);

pixelsInImage = size(perimeterMask, 1) * size(perimeterMask, 2);

imgWithPerimeter(perimeterIndexes + 0*pixelsInImage) = 255; %red channel
imgWithPerimeter(perimeterIndexes + 1*pixelsInImage) = 0;  %green channel
imgWithPerimeter(perimeterIndexes + 2*pixelsInImage) = 0; %blue channel
figure, imshow(imgWithPerimeter); title('Perimeter in Original Image');


BW2 = imdilate(BW, se);
figure, imshow(BW2); title('Dilate');

BW3 = imopen(BW, se);
figure, imshow(BW3); title('Opening');

[L, N] = bwlabel(BW3);
N

figure, imshow(mat2gray(L)); title('labels');

figure;
for i=1:N
    A = zeros(size(L));
    A(find(L==i)) = 255;
     subplot(3,3, i); imshow(A);
end

areas = [];

for k=1:N
    areas = [areas length(find(L==k))];
end

[ind,val] = max(areas);

%BW4 = imclose(BW, se);
%figure, imshow(BW4); title('Closing');