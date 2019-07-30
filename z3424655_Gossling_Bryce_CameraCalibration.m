%% Bryce Gossling z3424655


function worldPts = z3424655_Gossling_Bryce_CameraCalibration()
    close all;clear all;clc;

    %undistort Image
    load('cameraParams.mat');
    board = imread('Images/blank_image2.jpg');
    undistortedImage = undistortImage(board, cameraParams);
    board = undistortedImage;
    I = rgb2gray(board);
    imshow(board);
    %pixel points
    pt1 = [798, 288];
    pt2 = [21, 288];
    pt3 = [1586, 296];
    pt4 = [793, 856];
    pt5 = [795.5,572]; %midpt of pt1 and pt4
    localPts = [pt1; pt2; pt3; pt4; pt5];
    %real world measurements
    pt1 = [175,0];
    pt2 = [175,-520];
    pt3 = [175,520];
    pt4 = [548.6,0];
    pt5 = [361.8,0]; %midpoint of pt1 and pt1
    worldPts = [pt1; pt2; pt3; pt4; pt5];
    %Rotation Matrix & Translation Vector
    [R,t] = extrinsics(localPts,worldPts,cameraParams)
    [x,y] = ginput(1);
    worldPts = pointsToWorld(cameraParams, R, t, [x, y])
end