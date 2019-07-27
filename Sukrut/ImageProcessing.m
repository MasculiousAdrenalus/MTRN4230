close all;
clear all;
clc;

image1 = 'Asst1_example_path.jpg';
board = imread(image1);
board_gry =rgb2gray(board);
level = graythresh(board_gry);
BW = imbinarize(board_gry,level);

% figure;
% imshow(BW);

%% Section to get the start point
% Convert RGB image to chosen color space
I = board;

% Define thresholds for channel 1 based on histogram settings
channel1Min = 158.000;
channel1Max = 194.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 21.000;
channel2Max = 114.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 31.000;
channel3Max = 127.000;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
board_mask = board;

% Set background pixels where BW is false to zero.
board_mask(repmat(~BW,[1 1 3])) = 0;

% se = strel('sphere',25);
% board_mask = imerode(board_mask,se);
% 
% figure;
% imshow(board_mask);

[centers, radii, metric] = imfindcircles(board_mask,[16 25],'ObjectPolarity','bright','Sensitivity',0.972,'EdgeThreshold',0.5);
% figure;
% imshow(board);
% hold on;
% viscircles(centers, radii,'EdgeColor','b');

start_point = centers;

%% Section to get the end point

I = board;

% Define thresholds for channel 1 based on histogram settings
channel1Min = 90.000;
channel1Max = 113.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 120.000;
channel2Max = 146.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 90.000;
channel3Max = 114.000;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
board_mask = board;

% Set background pixels where BW is false to zero.
board_mask(repmat(~BW,[1 1 3])) = 0;

s = regionprops(board_mask,'centroid')
areas = cat(1,s.Centroid);

figure;
imshow(board_mask);
hold on;
plot(areas(:,1),areas(:,2),'*b');


[centers, radii, metric] = imfindcircles(board_mask,[8 15],'ObjectPolarity','bright','Sensitivity',0.972,'EdgeThreshold',0.5);
% figure;
% imshow(board);
% hold on;
% viscircles(centers, radii,'EdgeColor','b');

end_point = centers;

%% Section to determine the points for path

I = board_gry;

% Detect MSER regions.
[mserRegions, mserConnComp] = detectMSERFeatures(I, ... 
    'RegionAreaRange',[200 8000],'ThresholdDelta',4);

% Use regionprops to measure MSER properties
mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
    'Solidity', 'Extent', 'Euler', 'Image');

% Compute the aspect ratio using bounding box data.
bbox = vertcat(mserStats.BoundingBox);
w = bbox(:,3);
h = bbox(:,4);
aspectRatio = w./h;

% Threshold the data to determine which regions to remove. These thresholds
% may need to be tuned for other images.
filterIdx = aspectRatio' > 3; 
filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
filterIdx = filterIdx | [mserStats.Solidity] < .3;
filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

% Remove regions
mserStats(filterIdx) = [];
mserRegions(filterIdx) = [];

% Get a binary image of the a region, and pad it to avoid boundary effects
% during the stroke width computation.
regionImage = mserStats(6).Image;
regionImage = padarray(regionImage, [1 1]);

% Compute the stroke width image.
distanceImage = bwdist(~regionImage); 
skeletonImage = bwmorph(regionImage, 'thin', inf);

strokeWidthImage = distanceImage;
strokeWidthImage(~skeletonImage) = 0;

% Compute the stroke width variation metric 
strokeWidthValues = distanceImage(skeletonImage);   
strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

% Threshold the stroke width variation metric
strokeWidthThreshold = 0.4;
strokeWidthFilterIdx = strokeWidthMetric > strokeWidthThreshold;

% Process the remaining regions
for j = 1:numel(mserStats)
    
    regionImage = mserStats(j).Image;
    regionImage = padarray(regionImage, [1 1], 0);
    
    distanceImage = bwdist(~regionImage);
    skeletonImage = bwmorph(regionImage, 'thin', inf);
    
    strokeWidthValues = distanceImage(skeletonImage);
    
    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
    
    strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;
    
end

% Remove regions based on the stroke width variation
mserRegions(strokeWidthFilterIdx) = [];
mserStats(strokeWidthFilterIdx) = [];

% Get bounding boxes for all the regions
bboxes = vertcat(mserStats.BoundingBox);

% Convert from the [x y width height] bounding box format to the [xmin ymin
% xmax ymax] format for convenience.
xmin = bboxes(:,1);
ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

% Expand the bounding boxes by a small amount.
expansionAmount = 0.02;
xmin = (1-expansionAmount) * xmin;
ymin = (1-expansionAmount) * ymin;
xmax = (1+expansionAmount) * xmax;
ymax = (1+expansionAmount) * ymax;

% Clip the bounding boxes to be within the image bounds
xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(I,2));
ymax = min(ymax, size(I,1));

% Show the expanded bounding boxes
expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
IExpandedBBoxes = insertShape(board,'Rectangle',expandedBBoxes,'LineWidth',3);
centers = [(expandedBBoxes(:,1)+(expandedBBoxes(:,3)/2)) (expandedBBoxes(:,2)+(expandedBBoxes(:,4)/2))];
centers = unique(centers, 'rows');
newCenters = [];
for i=1:length(centers(:,1))-1
    for j=i+1:length(centers(:,1))
    distance = sqrt((centers(j, 1) - centers(i, 1))^2 + (centers(j, 2) - centers(i, 2))^2);
        if distance < 30
            centers(j,1) = 10000;
            centers(j,2) = 10000;
        end
    end
end
unique_centers = unique(centers,'rows');

figure
imshow(board)
title('Points')
hold on;
plot(unique_centers(:,1),unique_centers(:,2),'*b');
plot(start_point(:,1),start_point(:,2),'*r');
plot(end_point(:,1),end_point(:,2),'*g');

%% Section to write the path

path = [start_point];

unique_centers_path = [unique_centers; end_point];

distance_path = [];

while path(length(path(:,1))) ~= end_point(1) && path(length(path(:,2))) ~= end_point(2)
    for j=1:length(unique_centers_path(:,1))
        distance_path(j) = sqrt((unique_centers_path(j, 1) - path(length(path(:,1)),1))^2 + (unique_centers_path(j, 2) - path(length(path(:,2)),2))^2);
    end
    [next_dist,next_index] = min(distance_path);
    path = [path;unique_centers_path(next_index,:)];
    unique_centers_path(next_index,:) = [10000 10000];
end

figure;
imshow(board)
hold on;
plot(path(:,1),path(:,2),'-y');
hold off