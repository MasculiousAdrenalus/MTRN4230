%bryce gossling z3424655
% close all;
% clear all;
% clc;

board = imread('Images/example.jpg');
undistortedImage = undistortImage(board, cameraParams);
board = undistortedImage;
I = rgb2gray(board);
%% GET STARTING AND ENDING POINTS
% figure(10); clf; hold on;
%get red
[bw_red, msk] = mask_red(board);
bw_red = bwareaopen(bw_red,100);
[centers_red, radii_red, metric_red] = imfindcircles(bw_red,[16 30],'ObjectPolarity','bright');
%get green
[bw_green, msk] = mask_green(board);
bw_green = bwareaopen(bw_green,100);
[centers_green, radii_green, metric_green] = imfindcircles(bw_green,[16 50],'ObjectPolarity','bright');
START = centers_red
FINISH = centers_green
% hold off;
%% GET BOXES
figure(11); clf; 
[bw, expandedBBoxes] = get_letters(board);
x = (expandedBBoxes(:,1)+(expandedBBoxes(:,3)/2));
y = (expandedBBoxes(:,2)+(expandedBBoxes(:,4)/2));
centers =  [x y]%zeros(length(expandedBBoxes(:,1)),4)
centers = unique(centers, 'rows');
for i= 1:(length(centers(:,1))-1)
    for j= (1+i):length(centers(:,1))
        dist = get_dist(centers(j, 1), centers(j, 2), centers(i, 1), centers(i, 2));
        if dist <30
            centers(j,1) = 99999999;
            centers(j,2) = 99999999;
        end
    end
end
centers = unique(centers, 'rows');
% [row,col] = find(centers(:,1) == 99999999)
centers(find(centers(:,1) == 99999999),:) = [];

imshow(board); hold on;
viscircles(centers_green, radii_green,'Color','g');
viscircles(centers_red, radii_green,'Color','r');
unique_centers = unique(centers,'rows');
plot(centers(:,1),centers(:,2),'*r');
hold off;
%% FIND PATH
path = [START];
temp = [centers; FINISH];

for i=1:length(centers(:,1))
    if (path(length(path(:,1))) ~= FINISH(1))
        for j=1:length(temp(:,1))
            if (path(length(path(:,1))) ~= FINISH(1))
            distance_path(j) = get_dist(temp(j, 1), (temp(j, 2)), path(length(path(:,1)),1) , path(length(path(:,2)),2))
            else
                break;
            end
        end
        [next_dist,next_index] = min(distance_path);
        path = [path;temp(next_index,:)];
        temp(next_index,:) = [10000 10000];
    else
        break;
    end
end
hold on;
plot(path(:,1),path(:,2),'-y');
hold off


%% FIND TOTAL DISTANCE
function [dis]=FindDistance(X,field)
    dis=0;
    assignin('base','X', X);
    assignin('base','field', field);
    %finds the dsitance between towns
    for z=1:length(X)-1       
        dx=field(1,X(z+1))-field(1,X(z));
        dy=field(2,X(z+1))-field(2,X(z));
        dxy=sqrt(dx^2+dy^2);
        dis=dis+dxy;
        assignin('base','z', z);
    end
    %finds the distance from the start the 2nd town
    dx=field(1,X(1))-start(1);
    dy=field(2,X(1))-start(2);
    dis=dis+sqrt(dx^2+dy^2);
    %finds the distance from the last the 2nd last town
    dx=field(1,X(end))-finish(1);
    dy=field(2,X(end))-finish(2);
    dis=dis+sqrt(dx^2+dy^2);
end
%% get distance func
function [dist]=get_dist(x_G, y_G, x_L, y_L)
    dist = sqrt((x_G - x_L)^2 + (y_G - y_L)^2);
end
%%
% figure(12); clf; hold on;
% gmag = imgradient(I);
% imshow(gmag,[])
% title('Gradient Magnitude')
% hold off;