
function Coordinates = convertPixelXYToRobotXY(x_pixel, y_pixel)

%     K = [8797.7923 -101.91989997282 775.7871; 0 9081.4609 1288.3461; 0 0 1];
%     Ke = [0.076613 0.954313 0.1852 92.64102; -0.96559 0.053238 0.125163 -561.888; 0.114613 -0.19646 0.973763 5609.976];
%     
%     TestCoords = [1; 1; 147; 1];
%     Vector = K*Ke*TestCoords;
% 
%     x3 = Vector(3);
%     x1 = x_pixel*x3;
%     x2 = y_pixel*x3;
% 
%     Coordinates = (K*Ke)\[x1;x2;x3];
%     Coordinates(1)=-(Coordinates(1)-209.4491);
%     Coordinates(2)=Coordinates(2)+70.24;
    load('cameraParams.mat');
    
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

    [rotationMatrix,translationVector] = extrinsics(imagePoints,worldPoints,cameraParams);

    R = rotationMatrix;
    t = translationVector;

    worldPoints = pointsToWorld(cameraParams, R, t, [x_pixel, y_pixel]);
    Coordinates = worldPoints; 
