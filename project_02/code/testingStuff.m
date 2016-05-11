function testingStuff()

    clear all, close all

    vid = VideoReader('training_video.mp4');
    nFrames = vid.Duration * vid.FrameRate;
    %step = 20;

    img = rgb2gray(readFrame(vid));
    bkg = zeros(size(img));

    boxCounter = 0;
    lastFrameBoxes= zeros(0,5); %divided in index, x, y, width, height

    %alpha = 0.01;
    figure;
    for i=1 : nFrames-1
        alpha = 1/i; %each frame counts equally in the overral calculation
        %i
        img = readFrame(vid);
        Y = rgb2gray(img);

        %showing original image
        %subplot(2,2,1);
        %imshow(img); 
        %title('Original Image'); 

        %calculating background estimation and image difference
        bkg = alpha * double(Y) + (1-alpha) * double(bkg);
        bkgImage = uint8(bkg); 
        differenceImage = imabsdiff(Y,bkgImage);

        %creating binary image
        %subplot(2,2,2);
        differenceImgBW = im2bw(differenceImage, 0.05);
        %imshow(differenceImgBW);
        %title('Binary Difference');

        %using morphologic operations to reduce noise
        %subplot(2,2,3);
        %seOpen = strel('disk', 2);
        %seClose = strel('disk', 2);
        %transformedImage = imclose(imopen(transformedImage, seOpen), seClose);
        %transformedImage = imopen(differenceImgBW, seOpen);
        transformedImage = medfilt2(differenceImgBW);
        transformedImage = imfill(transformedImage, 'holes');
        %imshow(transformedImage);
        %title('Binary Difference Transformed');

        %drawing the regions that were found
        regionProperties = regionprops('table',transformedImage,...
                                        'Area', 'Centroid', 'BoundingBox');
        %subplot(2,2,4);
        imshow(img); 
        title('Original Image'); 

        mergedBoxes = mergeBoxes(regionProperties.BoundingBox, 0.1);
        %only keeping boxes with an area bigger than threshold
        if(size(mergedBoxes,1) ~= 0)
            mergedBoxes = mergedBoxes(mergedBoxes(:,3).*mergedBoxes(:,4) > 500,:);
        end

        nRegions = size(mergedBoxes,1);
        %drawing the final regions
        for j=1:nRegions
            rectangle('Position',mergedBoxes(j,:), 'EdgeColor', 'blue');
        end

        [newBoxesIds, mergeSplitData, boxCounter] = matchBoxes(...
                    lastFrameBoxes, mergedBoxes, 0.6, boxCounter);

        for j=1:nRegions
            box = mergedBoxes(j,:);
            t = text(box(1) + box(3)/2, box(2) + box(4)/2, int2str(newBoxesIds(j)));
            t.FontSize = 10;
            t.Color = 'black';
            t.FontWeight = 'bold';
            t.HorizontalAlignment = 'center';
        end
        
        if(nRegions == 0)
            lastFrameBoxes = zeros(0,5);
        else
            lastFrameBoxes = [newBoxesIds mergedBoxes];
        end
        
        %print merges
        nMerges = size(mergeSplitData.merges,1);
        for j=1:nMerges
            mergeEntry = mergeSplitData.merges(j);
            nMergedRegions = size(mergeEntry.mergedFrom,1);
            output = 'Regions ';
            for k=1:nMergedRegions-1
                output = [output, int2str(mergeEntry.mergedFrom(k)), ', '];
            end
            output = [output ... 
                      int2str(mergeEntry.mergedFrom(nMergedRegions)) ...
                    ' where MERGED into the region ' ...
                    int2str(mergeEntry.mergedTo) ...
                    '.']
        end
        
        %print splits
        nSplits = size(mergeSplitData.splits,1);
        for j=1:nSplits
            splitEntry = mergeSplitData.splits(j);
            nSplittedRegions = size(splitEntry.splittedTo,1);
            output = [  'Region ' int2str(splitEntry.splittedFrom) ... 
                        ' was SPLIT into the regions '];
            for k=1:nSplittedRegions-1
                output = [output, int2str(splitEntry.splittedTo(k)), ', '];
            end
            output = [  output ... 
                        int2str(splitEntry.splittedTo(nSplittedRegions)) ...
                        '.']
        end
        
        drawnow
    end

function mergedBoxes = mergeBoxes(originalBoxes, threshold)

    if size(originalBoxes,1) == 0
        mergedBoxes = originalBoxes;
        return;
    end

    %change coordenate system from x1, y1, w, h to x1, y1, x2, y2
    %this makes operations easier
    inputBoxes = originalBoxes;
    inputBoxes = toCoorSystem(inputBoxes);

    mergeCounter = 1; %must start non-zero
    while(mergeCounter ~= 0)
        mergeCounter = 0;
        nBoxes = size(inputBoxes,1);
        outputBoxes = zeros(size(inputBoxes));
        boxMerged = zeros(nBoxes,1);

        for i=1:nBoxes
            if boxMerged(i)
                continue;
            end

            for j=i+1:nBoxes
                if boxMerged(j)
                    continue;
                end

                box1 = inputBoxes(i,:);
                box2 = inputBoxes(j,:);
                
                intersectionBoxArea = getIntersectionArea(box1, box2);
                
                if(intersectionBoxArea == 0)
                    continue;
                end

                box1Area = getArea(box1);
                box2Area = getArea(box2);

                if( intersectionBoxArea/box1Area>threshold && ...
                    intersectionBoxArea/box2Area>threshold)

                    boxMerged(i) = 1; boxMerged(j) = 1; 
                    mergeCounter = mergeCounter+1;
                    outputBoxes(mergeCounter,:) =   [min(box1(1:2),box2(1:2))... 
                                                    max(box1(3:4),box2(3:4))];
                end

            end
        end

        unmergedBoxes = inputBoxes(boxMerged==0,:);
        %now our output is our new input
        inputBoxes = [outputBoxes(1:mergeCounter,:) ; unmergedBoxes];
    end

    %Returning again in the original system 
    mergedBoxes = fromCoorSystem(inputBoxes);
    
    
function [newBoxesIds, mergeSplitLog, counter] = ...
            matchBoxes(oldBoxes, newBoxes, threshold, counter)
    %separating ID from box location info
    oldBoxesIds = oldBoxes(:,1);
    oldBoxes = oldBoxes(:,2:5);
    
    if size(oldBoxes,1) ~= 0 
        oldBoxes = toCoorSystem(oldBoxes);
    end
    if size(newBoxes,1) ~= 0 
        newBoxes = toCoorSystem(newBoxes);
    end
    
    oldBoxesLength = size(oldBoxes,1);
    newBoxesLength = size(newBoxes,1);
    %set all to -1 which means no match
    newBoxesIds = zeros(newBoxesLength,1) - 1;
    
    matchMatrix = zeros(oldBoxesLength,newBoxesLength);
    for i=1:oldBoxesLength
        for j=1:newBoxesLength
            oldBox = oldBoxes(i,:);
            newBox = newBoxes(j,:);
            
             intersectionBoxArea = getIntersectionArea(oldBox, newBox);
                
            if(intersectionBoxArea == 0)
                continue;
            end

            oldBoxArea = getArea(oldBox);
            newBoxArea = getArea(newBox);
            
            if intersectionBoxArea/oldBoxArea>threshold
                
                %%case 1 -> perfect match
                if intersectionBoxArea/newBoxArea>threshold
                    matchMatrix(i,j) = 1;
                %case 2 -> only old box matches (we have a merge)
                else
                    matchMatrix(i,j) = 2;
                end
            %case 3 -> only new box matches (we have a split)
            elseif intersectionBoxArea/newBoxArea>threshold
                matchMatrix(i,j) = 3;
            end   
        end
    end
    
    %now get a new ID for every region.
    for i=1:newBoxesLength
        %looking for perfect matches
        match = oldBoxesIds(matchMatrix(:,i) == 1);
        
        %only case where it gets an ID
        if(length(match) == 1)
            newBoxesIds(i) = match;
        else
            counter = counter+1;
            newBoxesIds(i) = counter;
        end
    end
    
    %Create split log entries
    splitLog = [];
    for i=1:oldBoxesLength
        splittedBoxesIDs = newBoxesIds(matchMatrix(i,:) == 3);
        
        if(size(splittedBoxesIDs) <= 1)
            %found nothing
            continue;
        end
        
        %Each log info has the inform
        splitLogEntry = struct( 'splittedFrom', {oldBoxesIds(i)},... 
                                'splittedTo', {splittedBoxesIDs});
        splitLog = [splitLog splitLogEntry];
    end
    
    %Create merge log entries
    mergeLog = [];
    for i=1:newBoxesLength
        mergedBoxesIDs = oldBoxesIds(matchMatrix(:,i) == 2);
        
        
        if(size(mergedBoxesIDs) <= 1)
            %found nothing
            continue;
        end
        
        %Each log info has the inform
        mergeLogEntry = struct( 'mergedFrom', {mergedBoxesIDs},... 
                                'mergedTo', {newBoxesIds(i)});
        mergeLog = [mergeLog mergeLogEntry];
    end
    
    mergeSplitLog = struct('splits', {splitLog}, 'merges', {mergeLog});
    
%--------------------------------------------------------------------------    
%-- Utility functions related with boxes using the X1, Y1, X2, Y2 system --
%--------------------------------------------------------------------------
function newBoxes = toCoorSystem(boxes)
    newBoxes = boxes;
    newBoxes(:,3) = newBoxes(:,1) + newBoxes(:,3);
    newBoxes(:,4) = newBoxes(:,2) + newBoxes(:,4);

function newBoxes = fromCoorSystem(boxes)
    newBoxes = boxes;
    newBoxes(:,3) = newBoxes(:,3) - newBoxes(:,1);
    newBoxes(:,4) = newBoxes(:,4) - newBoxes(:,2);

function area = getArea(boxes)
    area = (boxes(:,3)-boxes(:,1)) * (boxes(:,4)-boxes(:,2));
    
function area = getIntersectionArea(box1, box2)
    area = 0;
    if( box1(3)<box2(1)||... X1+W1>X2 
        box2(3)<box1(1)||... X2+W2>X1 
        box1(4)<box2(2)||... Y1+H1>Y2 
        box2(4)<box1(2)) %   Y2+H2>Y1
        %no intersection
        return;
    end
    intersectionBox = [max(box1(1:2),box2(1:2)) min(box1(3:4),box2(3:4))];
    
    area = getArea(intersectionBox);