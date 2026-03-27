clear;
clc;
close all;
mtx = [181.927658, 0, 163.103508; 0, 182.394592, 158.665134; 0, 0, 1];            
dist = [0,0,0, 0, 0];
cameraParams = cameraParameters('IntrinsicMatrix', mtx', ...
                                'RadialDistortion', dist(1:2), ...
                                'TangentialDistortion', dist(3:4));
Kinv = inv(mtx); 
filename = '/home/minjikim/calibration/data/output_image/0822-6/selected/finaltouch/img_1724304129732.txt';  
lines = dlmread(filename);
numLines = size(lines, 1);
greatcirclePoints = zeros(numLines,6);
greatcirclePoints1 = zeros(numLines,6);
greatcircleNormal = zeros(numLines, 3);
for k = 1:numLines
    linedata = lines(k, 1:4);
    ptEnd1_p_d = [linedata(1:2), 1].'; 
    ptEnd2_p_d = [linedata(3:4), 1].'; 
    ptEnd1_n_d = Kinv * ptEnd1_p_d;
    ptEnd2_n_d = Kinv * ptEnd2_p_d;
    ptEnd1_n_u = undistortPoints(ptEnd1_n_d(1:2).', cameraParams);
    ptEnd2_n_u = undistortPoints(ptEnd2_n_d(1:2).', cameraParams);
    ptEnd1_n_u = [ptEnd1_n_u, 1].';  
    ptEnd2_n_u = [ptEnd2_n_u, 1].';
    pt1_sphere = ptEnd1_n_u / norm(ptEnd1_n_u);
    pt2_sphere = ptEnd2_n_u / norm(ptEnd2_n_u);
    greatcirclePoints(k,:) = [pt1_sphere.', pt2_sphere.'];
    circleNormal = cross(ptEnd1_n_u.', ptEnd2_n_u.');
    circleNormal = circleNormal / norm(circleNormal);
    greatcircleNormal(k, :) = circleNormal;
end

addpath(genpath(pwd))
%plot_unit_sphere(18, 1); 
hold on; axis equal;

f = FigureRotator(gca());
%% Draw line great circle 
% for m = 1:3
%         pt1 = greatcirclePoints(m,1:3);
%         pt2 = greatcirclePoints(m,4:6);
%         plot_great_circle(pt1, pt2, 1.5, 'r', 'greatcircle');
% end
for m = 4:6
        pt1 = greatcirclePoints(m,1:3);
        pt2 = greatcirclePoints(m,4:6);
        plot_great_circle(pt1, pt2, 1, [0, 0, 0.8], 'greatcircle');
end
for m = 7:7
        %pt1 = greatcirclePoints(m,1:3);
        %pt2 = greatcirclePoints(m,4:6);
        %plot_great_circle(pt1, pt2, 1.5, 'y', 'greatcircle');
end
% for m = 9:9
%         pt1 = greatcirclePoints(m,1:3);
%         pt2 = greatcirclePoints(m,4:6);
%         %plot_great_circle(pt1, pt2, 1.5, 'yellow', 'greatcircle');
% end

%%
for k = 1:2
    linedata = greatcircleNormal(k, 1:3);
    linedata1 =greatcircleNormal(k+1,1:3);

    ptEnd1_p_d = [linedata(1:3)].';  
    ptEnd2_p_d = [linedata1(1:3)].'; 

    ptEnd1_n_d = ptEnd1_p_d;
    ptEnd2_n_d = ptEnd2_p_d;

    ptEnd1_n_u = ptEnd1_n_d.'; 
    ptEnd2_n_u = ptEnd2_n_d.'; 

    pt1_sphere = ptEnd1_n_u / norm(ptEnd1_n_u);
    pt2_sphere = ptEnd2_n_u / norm(ptEnd2_n_u);
    greatcirclePoints1(k,:) = [pt1_sphere, pt2_sphere];

    circleNormal = cross(ptEnd1_n_u.', ptEnd2_n_u.');
    circleNormal = circleNormal / norm(circleNormal);
    
    verticalDominantDirection1(k, :) = circleNormal;
end
for k = 3:3
    linedata = greatcircleNormal(k, 1:3);
    linedata1 =greatcircleNormal(1,1:3);

    ptEnd1_p_d = [linedata(1:3)].';  
    ptEnd2_p_d = [linedata1(1:3)].'; 

    ptEnd1_n_d = ptEnd1_p_d;
    ptEnd2_n_d = ptEnd2_p_d;

    ptEnd1_n_u = ptEnd1_n_d.'; 
    ptEnd2_n_u = ptEnd2_n_d.'; 

    pt1_sphere = ptEnd1_n_u / norm(ptEnd1_n_u);
    pt2_sphere = ptEnd2_n_u / norm(ptEnd2_n_u);
    greatcirclePoints1(k,:) = [pt1_sphere, pt2_sphere];

    circleNormal = cross(ptEnd1_n_u.', ptEnd2_n_u.');
    circleNormal = circleNormal / norm(circleNormal);
    
    verticalDominantDirection1(k, :) = circleNormal;
end
for k = 4:5
    linedata = greatcircleNormal(k, 1:3);
    linedata1 =greatcircleNormal(k+1,1:3);
    
    ptEnd1_p_d = [linedata(1:3)].';  
    ptEnd2_p_d = [linedata1(1:3)].'; 
    
    ptEnd1_n_d = ptEnd1_p_d;
    ptEnd2_n_d = ptEnd2_p_d;

    ptEnd1_n_u = ptEnd1_n_d.';
    ptEnd2_n_u = ptEnd2_n_d.'; 

    pt1_sphere = ptEnd1_n_u / norm(ptEnd1_n_u);
    pt2_sphere = ptEnd2_n_u / norm(ptEnd2_n_u);
    greatcirclePoints1(k,:) = [pt1_sphere, pt2_sphere];

    circleNormal = cross(ptEnd1_n_u.', ptEnd2_n_u.');
    circleNormal = circleNormal / norm(circleNormal);

    verticalDominantDirection1(k, :) = circleNormal;
end
for k = 6:6
    linedata = greatcircleNormal(k, 1:3);
    linedata1 =greatcircleNormal(4,1:3);
    
    ptEnd1_p_d = [linedata(1:3)].';  
    ptEnd2_p_d = [linedata1(1:3)].'; 
    
    ptEnd1_n_d = ptEnd1_p_d;
    ptEnd2_n_d = ptEnd2_p_d;

    ptEnd1_n_u = ptEnd1_n_d.';
    ptEnd2_n_u = ptEnd2_n_d.'; 

    pt1_sphere = ptEnd1_n_u / norm(ptEnd1_n_u);
    pt2_sphere = ptEnd2_n_u / norm(ptEnd2_n_u);
    greatcirclePoints1(k,:) = [pt1_sphere, pt2_sphere];

    circleNormal = cross(ptEnd1_n_u.', ptEnd2_n_u.');
    circleNormal = circleNormal / norm(circleNormal);

    verticalDominantDirection1(k, :) = circleNormal;
end
for i = 1:3
    greatcircleNormal2=[0.3720,0,0.9282];
    verticalDominantDirection = greatcircleNormal2';  % 라인 법선 벡터
    %[h1, h2] = plot_vertical_dominant_direction(verticalDominantDirection, 'y', 0.008);
    %[h_line, h_plane] = plot_vertical_dominant_plane(verticalDominantDirection, 1.5,'y');
    %plot_great_circle(greatcirclePoints1(i,1:3),greatcirclePoints1(i,4:6),1.5,'r','greatcircle');
    %h=mArrow3(0,verticalDominantDirection,'color', 'red','stemWidth',0.01);

end

for i = 4:6
    verticalDominantDirection = verticalDominantDirection1(i, :)';  % 라인 법선 벡터
    %[h1, h2] = plot_vertical_dominant_direction(verticalDominantDirection, 'b', 0.004);
    %[h_line, h_plane] = plot_vertical_dominant_plane(verticalDominantDirection, 1.5, 'b');
    %[h_line, h_plane] = plot_vertical_dominant_plane(verticalDominantDirection, 1.5, 'b');
    %plot_great_circle(greatcirclePoints1(i,1:3),greatcirclePoints1(i,4:6),1.5,'b','greatcircle')
    %h=mArrow3(0,verticalDominantDirection,'color', 'red','stemWidth',0.01);

end
for i = 7:7
    verticalDominantDirection = greatcircleNormal(i, :)';  
    %[h1, h2] = plot_vertical_dominant_direction(verticalDominantDirection, 'g', 0.008);
    %[h_line, h_plane] = plot_vertical_dominant_plane(verticalDominantDirection, 1.5, 'r');
    %h=mArrow3(0,verticalDominantDirection,'color', 'red','stemWidth',0.01);

end
% for i = 9:9
%      greatcircleNormal2=[0.3720,0,0.9282];
%     verticalDominantDirection = greatcircleNormal2'; 
%     %verticalDominantDirection = greatcircleNormal(i, :)'; 
%      [h1, h2] = plot_vertical_dominant_direction(verticalDominantDirection, 'y', 0.008);
%      [h_line, h_plane] = plot_vertical_dominant_plane(verticalDominantDirection, 1.5, 'y');
    %h=mArrow3(0,verticalDominantDirection,'color', 'red','stemWidth',0.01);

% end
% for i = 9:9
%     verticalDominantDirection = [-0.0131;-1;0.069]; 
%     [h1, h2] = plot_vertical_dominant_direction(verticalDominantDirection, 'k', 0.008);
%     %[h_line, h_plane] = plot_vertical_dominant_plane(verticalDominantDirection, 1.5, 'r');
%     %h=mArrow3(0,verticalDominantDirection,'color', 'red','stemWidth',0.01);
% 
% end
%%
lineNormals=greatcircleNormal;
for k = 1:3
    normal = lineNormals(k,:);
    plot3(normal(1),normal(2),normal(3),'o','MarkerSize',10,'LineWidth',1.5,'Color','k','MarkerFaceColor',[180/255,180/255,180/255]);
end
for k = 4:6
    normal = lineNormals(k,:);
    plot3([0 normal(1)],[0 normal(2)],[0 normal(3)], 'Color',[0.5,0.5,0.5], 'LineWidth', 0.5);
    plot3(normal(1),normal(2),normal(3),'o','MarkerSize',10,'LineWidth',1.5,'Color','k','MarkerFaceColor',[180/255,180/255,180/255]);
end
for k = 7:7
    normal = lineNormals(k,:);
    plot3(normal(1),normal(2),normal(3),'o','MarkerSize',10,'LineWidth',1.5,'Color','k','MarkerFaceColor',[180/255,180/255,180/255]);
end


%%
%RANSAC start 
optsOLVO.lineInlierThreshold = 0.05;
filename1 = '/home/minjikim/calibration/data/output_image/0822-6/line_detected/lsd/img_1724304129732.txt';  
lines1 = dlmread(filename1);

linesforransac=lines1;
linesforransac1=lines(1:6,:);
[R_cM_final, clusteredLineIdx_final] = detectOrthogonalLineRANSAC_3line(linesforransac1,Kinv,cameraParams, optsOLVO,verticalDominantDirection1);

%% angle find
% A = verticalDominantDirection1(4, :);  % 첫 번째 행 벡터
% %B = verticalDominantDirection1(4, :);  % 두 번째 행 벡터
% %B=greatcircleNormal(7,:);
% B=[-0.0131;-1;0.069]; 
% dot_product = dot(A, B);
% 
% 
% magnitude_A = norm(A);
% magnitude_B = norm(B);
% 
% cos_theta = dot_product / (magnitude_A * magnitude_B);
% 
% theta_radians = acos(cos_theta); 
% theta_degrees = rad2deg(theta_radians); 
% 
% disp(num2str(theta_degrees));
% 

%% Result RANSAC 
R_cM_final=[ -0.8333,-0.0176,0.5527 ; 0.0146,   0.9998,-0.0097;  -0.5528,    -0.0000,    -0.8333 ];
% R1 = [-0.8643 ,  -0.5005,	  0.0507;
%      0.0504 ,  -0.1865 ,  -0.9812;
%      0.5005 ,  -0.8454,	 0.1865]; 
R1 = [0.8061, -0.0205, -0.5914;
      0.0149, -0.9984, 0.0549;
     -0.5916, -0.0530, -0.8045];



verticalDominantDirection = R_cM_final(1, :)'; 
[h1, h2] = plot_vertical_dominant_direction(verticalDominantDirection, 'blue', 0.008);
[h_line, h_plane] = plot_vertical_dominant_plane(verticalDominantDirection, 1.5, 'b');
verticalDominantDirection = R_cM_final(2, :)'; 
[h11, h12] = plot_vertical_dominant_direction(verticalDominantDirection, 'red', 0.008);

verticalDominantDirection = R_cM_final(3, :)'; 
[h12, h22] = plot_vertical_dominant_direction(verticalDominantDirection, 'green', 0.008);
disp(R_cM_final);
% 
% verticalDominantDirection = R1(1, :)'; 
% [h1, h2] = plot_vertical_dominant_direction(verticalDominantDirection, 'b', 0.01);
% %
% verticalDominantDirection = R1(2, :)'; 
% [h11, h12] = plot_vertical_dominant_direction(verticalDominantDirection, 'r', 0.008);
% %[h_line1, h_plan1] = plot_vertical_dominant_plane(verticalDominantDirection, 1.5, 'r');
% verticalDominantDirection = R1(3, :)'; 
% [h12, h22] = plot_vertical_dominant_direction(verticalDominantDirection, 'g', 0.008);
% %[h_line, h_plane] = plot_vertical_dominant_plane(verticalDominantDirection, 1.5, 'g');
% disp(R_cM_final);
% view(32,-60);
% 
% f = FigureRotator(gca());
% 
% % copy current figure as vector graphics format
% exportgraphics(gcf, 'mySphere.png', 'Resolution', 300, 'ContentType', 'image');
% 
% R_error = R1 * R_cM_final';
% 
% % Calculate the rotation error angle
% theta = acos((trace(R_error) - 1) / 2);
% 
% % Convert the result to degrees
% theta_deg = rad2deg(theta);
% 
% % Display the result
% fprintf('The rotation error between the frames is %.4f radians (%.4f degrees)\n', theta, theta_deg);

%% Image to Gaussian Sphere 
datasetPath='/home/minjikim/calibration/figure/output_image.png';
imageCurForRGB= getImgInTUMRGBDdataset(datasetPath, cameraParams, 'rgb');


% assign current parameters
imageHeight = size(imageCurForRGB,1);
imageWidth = size(imageCurForRGB,2);



% compute 3D position on the Gaussian sphere
sphereX = zeros(imageHeight,imageWidth);
sphereY = zeros(imageHeight,imageWidth);
sphereZ = zeros(imageHeight,imageWidth);
for v = 1:imageHeight
    for u = 1:imageWidth

        % current pixel position
        pt_p_d = [u; v; 1];
        pt_n_d = Kinv * pt_p_d;
        pt_n_u = [undistortPts_normal(pt_n_d(1:2), cameraParams); 1];
        pt_n_u_norm = pt_n_u / norm(pt_n_u);

        % save 3D position on the Gaussian sphere
        sphereX(v,u) = pt_n_u_norm(1);
        sphereY(v,u) = pt_n_u_norm(2);
        sphereZ(v,u) = pt_n_u_norm(3);
    end
end
sphereX(2:2:end,:) = [];
sphereX(:,2:2:end) = [];
sphereY(2:2:end,:) = [];
sphereY(:,2:2:end) = [];
sphereZ(2:2:end,:) = [];
sphereZ(:,2:2:end) = [];
save('textureMappingMatrix_Tello_Urban.mat','sphereX','sphereY','sphereZ');

plot_image_Gaussian_sphere_ICL_NUIM(imageCurForRGB);
% copy current figure as vector graphics format
f = FigureRotator(gca());
hold on; axis equal;
exportgraphics(gcf, 'mySphere.png', 'Resolution', 300, 'ContentType', 'image');
