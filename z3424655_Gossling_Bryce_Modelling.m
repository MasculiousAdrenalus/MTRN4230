%% Bryce Gossling z3424655
close all;clear all;clc;

%undistort Image
load('cameraParams.mat');
board = imread('Images/blank_image2.jpg');
undistortedImage = undistortImage(board, cameraParams);
board = undistortedImage;
I = rgb2gray(board);
imshow(board);

startup_rvc

%% Q1 DH table 
%             [theta d a alpha sigma offset] sigma=0
L(1) = Link([0 0.29  0     pi/2    0   pi ], 'standard');        % L link 2 
L(2) = Link([0   0   0.27     0     0  pi/2], 'standard');        % L link 3 
L(3) = Link([0   0   0.07   -pi/2   0   0  ], 'standard');        % L link 4 
L(4) = Link([0 0.302  0     pi/2    0   0  ], 'standard');        % L link 5 
L(5) = Link([0   0    0     pi/2    0   pi ], 'standard');        % L link 6
L(6) = Link([0 0.137   0      0     0   0  ], 'standard');        % L link 6


ABB_IRB120 = SerialLink(L, 'name', 'abb irb120');
home_pos = [0, 0, 0, 0, 0, 0];            % all 0 angles
ABB_IRB120.plot(home_pos)                 % robot facing x direction 
pause; 
%% q4 Visualisation 
worldPoints = [175,-520; 175,0; 175, 520; 548.6,0];
worldPoints = worldPoints/1000; 

h2 = figure;
ABB_IRB120.plot(home_pos, 'workspace', [-1.1 1.1 -1.1 1.1 -1 1]);
hold on;
robotCenterToTable = 0.129; 
% plot3(worldPoints(:,1)+robotCenterToTable,worldPoints(:,2),zeros(size(worldPoints, 1),1),'*');
plot3(worldPoints(:,1),worldPoints(:,2),zeros(size(worldPoints, 1),1),'*');
% "Table" 75x150x72cm 
plot_box('topleft',[robotCenterToTable,-0.75], 'size',[0.75, 0.6], 'fillcolor', 'k', 'alpha', 0.5);
% Camera 
camera_location = [robotCenterToTable 0 1];
R = [-1 0 0; 
      0 1 0;
      0 0 -1];
plotCamera('Location',camera_location,'Orientation', R, 'Opacity',0.8, 'Size',0.04);

% to get 3d co-ordinate frame 
R = rotx(180, 'deg'); % * rotz(0, 'deg');
% table frame
trplot([rotx(0, 'deg') [robotCenterToTable 0 0]'; 0 0 0 1], 'length', 0.2);
% camera frame
% camera_axis = SE3([0.3+0.2 0 1]);
trplot([R camera_location'; 0 0 0 1], 'length', 0.2);
fprintf("Done part 4\n");
pause; 

%% q5 Reachability of the arm 
radiusEndEffector = 0.52+0.03;
% plot_circle([0,0,0], 0.52)
 plot_circle([0,0,0], radiusEndEffector);
% plot_circle([0,0,0], 0.58)
view([0 0 1])
fprintf("radius of the end effector about the robot origin is %.2f\n",radiusEndEffector);

fprintf("Done part 5\n");
pause; 


%% q8 plot the path "Animated"

my_traj_path = z3424655_Gossling_Bryce_ImageProcessing(); % path in pixel locations 
my_traj_path = round(my_traj_path);
figure; 
t = [0:0.1:1];                 % steps (start: middle: end. 3 steps)
% plot the path "Animated": plots the positions of each block 
q0 = home_pos;
for i = 1:length(my_traj_path)-1
    quat = UnitQuaternion([0, 0, 1, 0]);
    % position 1
    pos1 = z3424655_Gossling_Bryce_CameraCalibration_input(my_traj_path(i,1),my_traj_path(i,2));
    % gives the required position 
    posXYZ1= [pos1(1)/1000,pos1(2)/1000,0]; 
    % orientation given my quaternion
    T1 = r2t(quat.R);
    T1(1:3, 4) =  posXYZ1';
    % position 2
    pos2 = z3424655_Gossling_Bryce_CameraCalibration_input(my_traj_path(i+1,1),my_traj_path(i+1,2));
    % gives the required position 
    posXYZ2= [pos2(1)/1000,pos2(2)/1000,0]; 
    % orientation given my quaternion
    T2 = r2t(quat.R);
    T2(1:3, 4) =  posXYZ2';
    
    CTraj_motion = ctraj(T1, T2, t);
    % joint angles 
    q = ABB_IRB120.ikine(CTraj_motion, 'q0', q0);

    for c = 1:length(t)
        ABB_IRB120.plot(q(c,:));
    end 
    % pause(0.01); 
end 
fprintf("Done part 8\n");
pause;
ABB_IRB120.plot(home_pos)

