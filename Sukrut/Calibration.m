close all;
clear all;
clc;

figure;
RGB = imread('blank_image.jpg');
imshow(RGB);
[x_pixel,y_pixel] = ginput(1);

K = [8797.7923 -101.91989997282 775.7871; 0 9081.4609 1288.3461; 0 0 1];
Ke = [0.076613 0.954313 0.1852 92.64102; -0.96559 0.053238 0.125163 -561.888; 0.114613 -0.19646 0.973763 5609.976];
TestCoords = [1; 1; 147; 1];
Vector = K*Ke*TestCoords;

x3 = Vector(3);
x1 = x_pixel*x3;
x2 = y_pixel*x3;

Coordinates = (K*Ke)\[x1;x2;x3];

Coordinates(1)=-(Coordinates(1)-240);
Coordinates(2)=Coordinates(2)+85;

display(Coordinates);

message = sprintf('The selected point is: x = %.2f, y = %.2f, z = %.2f',[Coordinates(1) Coordinates(2) Coordinates(3)]);
uiwait(msgbox(message));