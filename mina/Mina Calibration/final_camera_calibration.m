figure;
RGB = imread('blank_image2.jpg');
imshow(RGB);
load('cameraParams');
undistortedImage = undistortImage(RGB, cameraParams);
imshow(undistortedImage);

IM1 = [798, 288];
IM2 = [21, 288];
IM3 = [1586, 296];
IM4 = [793, 856];
IM5 = [795.5,572]; %midpoint of IM1 and IM4
imagePoints = [IM1; IM2; IM3; IM4; IM5];

T1 = [175,0];
T2 = [175,-520];
T3 = [175,520];
T4 = [548.6,0];
T5 = [361.8,0]; %midpoint of T1 and T4
worldPoints = [T1; T2; T3; T4; T5];

[rotationMatrix,translationVector] = extrinsics(imagePoints,worldPoints,cameraParams)

R = rotationMatrix;
t = translationVector;

[x_pixel,y_pixel] = ginput(1);
worldPoints = pointsToWorld(cameraParams, R, t, [x_pixel, y_pixel])

