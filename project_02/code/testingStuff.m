function testingStuff()

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
    subplot(2,2,1);
    imshow(img); 
    title('Original Image'); 
    
    %calculating background estimation and image difference
    bkg = alpha * double(Y) + (1-alpha) * double(bkg);
    bkgImage = uint8(bkg); 
    differenceImage = imabsdiff(Y,bkgImage);
    
    %creating binary image
    subplot(2,2,2);
    differenceImgBW = im2bw(differenceImage, 0.05);
    imshow(differenceImgBW);
    title('Binary Difference');
    
    %using morphologic operations to reduce noise
    subplot(2,2,3);
    seOpen = strel('disk', 2);
    %seClose = strel('disk', 2);
    %transformedImage = imclose(imopen(transformedImage, seOpen), seClose);
    transformedImage = imopen(differenceImgBW, seOpen);
    transformedImage = medfilt2(transformedImage);
    transformedImage = imfill(transformedImage, 'holes');
    imshow(transformedImage);
    title('Binary Difference Transformed');
   
    %drawing the regions that were found
    regionProperties = regionprops('table',transformedImage, 'Area', 'Centroid', 'BoundingBox');
    subplot(2,2,4);
    imshow(img); 
    title('Original Image'); 
    
    nRegions = size(regionProperties,1);
    
    %seeing if certain regions should be merged
    mergedMatrix = zeros(nRegions, nRegions);
    for j=1:nRegions
        for k=j:nRegions
            region1Box = regionProperties.BoundingBox(j,:);
            region2Box = regionProperties.BoundingBox(k,:);
            
            %Test for overlapp
            if(     region1Box(1)+region1Box(3)>region2Box(1)&&... X1+W1>X2 
                    region2Box(1)+region2Box(3)>region1Box(1)&&... X2+W2>X1 
                    region1Box(2)+region1Box(4)>region2Box(2)&&... Y1+H1>Y2 
                    region2Box(2)+region2Box(4)>region1Box(2)) %   Y2+H2>Y1
                mergedMatrix(j,k) = 1; 
                mergedMatrix(k,j) = 1; 
            end
        end
    end
    
    regionMarkers = zeros(nRegions, 1);
    regionCounter = 0;
    for j=1:nRegions
        if (regionMarkers(j) == 0)
            regionCounter = regionCounter+1;
            regionMarkers = findConnectedStructure(...
                j, regionCounter, mergedMatrix, regionMarkers);        
        end
    end
    
    finalRegionBoxes = zeros(regionCounter, 4)-1;
    for j=1:nRegions
        regionInd = regionMarkers(j);
        oldBox = regionProperties.BoundingBox(j,:);
        newBox = finalRegionBoxes(regionInd,:);
        
        %Updating x
        if(newBox(1) == -1 || oldBox(1) < newBox(1))
            finalRegionBoxes(regionInd,1) = oldBox(1);
        end
        
        %Updating y
        if(newBox(2) == -1 || oldBox(2) < newBox(2))
            finalRegionBoxes(regionInd,2) = oldBox(2);
        end
        
        %Updating w
        if(newBox(3) == -1 || oldBox(3) > newBox(3))
            finalRegionBoxes(regionInd,3) = oldBox(3);
        end
        
        %Updating h
        if(newBox(4) == -1 || oldBox(4) > newBox(4))
            finalRegionBoxes(regionInd,4) = oldBox(4);
        end
        
    end
    
    for j=1:regionCounter
        rectangle('Position',finalRegionBoxes(j,:), 'EdgeColor', 'blue');
    end
  
    drawnow
end


function connectedNodes = findConnectedStructure(currentNode, markerValue, adjacencyMatrix, connectedNodes)
    connectedNodes(currentNode) = markerValue;
    for i=1:size(adjacencyMatrix)
        if(adjacencyMatrix(currentNode,i) == 1 && connectedNodes(i) == 0)
            connectedNodes = findConnectedStructure(i, markerValue, adjacencyMatrix, connectedNodes);
        end
    end
