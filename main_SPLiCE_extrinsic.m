clear;
clc;

close all;


%% calibration method rule

% Position the crazyflie 10cm~15cm above the ground
% Place the checker board, which is 788mm*545mm in size, at a minimum distance of 35cm~55cm 
% Stay at the starting point for at least 20 seconds
% Rotate back and forth more than three times.
% Rotate the checker board more than 90 degrees


%% Minji Kim : minji0110@gm.gist.ac.kr

% =========================================================================
% Crazyflie Camera-Sensor Extrinsic Calibration Pipeline
%
% [Pipeline Structure]
%   Part 1 : Remove outliers from raw multiranger sensor data and save
%   Part 2 : Compute 3D coordinates based on checkerboard rotation model
%   Part 3 : Match images to timestamps from 2D line txt files and copy
%   Part 4 : Remove unmatched rows from 3D point file (reverse filtering)
%   Part 5 : Re-select images and txt files based on final 3D point timestamps
%   Part 6 : Match 3D points and 2D lines by timestamp
%   Part 7 : Two-stage extrinsic parameter optimization (R, t)
%   Part 8 : Reprojection visualization and result export
% =========================================================================


% =========================================================================
% PART 1 : Raw Data Loading and Outlier Removal
%
% [Input]  multiranger_data_with.txt
%          col1=X(dist mm), col2=Y, col3=Z, col4=timestamp, col5=image trigger(0/1)
% [Process] Remove rows where X > 30000 (sensor error) and overwrite original file
% [Output] multiranger_data_with.txt (overwritten, outliers removed)
% =========================================================================
%% read data (multiranger front)

filename_pointcloud = '/home/minjikim/calibration/data/input_calibrationboard/1118-3/multiranger_data_with.txt';
data_pointcloud = readmatrix(filename_pointcloud);


X2 = data_pointcloud(:, 1);



newfilename_pointcloud='/home/minjikim/calibration/data/input_calibrationboard/1118-3/multiranger_data_with.txt';
remove_index=X2>30000;
data_pointcloud(remove_index,:)=[];
writematrix(data_pointcloud, newfilename_pointcloud);


data_pointcloud = readmatrix(newfilename_pointcloud);
X1 = data_pointcloud(:, 1);
Y1 = data_pointcloud(:, 2);
Z1 = data_pointcloud(:, 3);



x1 = find_x1(X1, 200);


removeIndex=X1>x1;


data_pointcloud(removeIndex,:)=[];
newFileName= '/home/minjikim/calibration/data/input_calibrationboard/1118-3/multiranger_data.txt';
writematrix(data_pointcloud, newFileName);

dataPointCloud=readmatrix(newFileName);
X = data_pointcloud(:, 1);
Y = data_pointcloud(:, 2);
Z = data_pointcloud(:, 3);

% =========================================================================
% PART 2 : 3D Coordinate Calculation Based on Checkerboard Rotation Model
%
% [Assumption] Checkerboard rotates as an arc of radius Lb around fixed axis at x2
% [Process]    Derive line equation from sensor pos → measured X
%              Find intersection of line and arc (quadratic) → compute 3D points
% [Output] calculated_3Dpoints_for_video.txt
%          col1:index, col2:timestamp, col3:Lx1, col4:Ly1, col5:Lx2,
%          col6:Ly2, col7:Lx3, col8:Ly3, col9:x_line_2, col10:y_line_2
% =========================================================================
%% calculate rotation angle and circle center

Lb=300;  % board length
Lh=300;  % hole length 

%diff_X=diff(X);
x2=X(1);
%select the end point algorithm 
subset_data=X(1:10,:);
average_value=mean(subset_data);
line_length=x1-x2;
theta=asin(line_length/Lb);
deg=rad2deg(theta);
axis_distance=Lb*cos(theta);

center_x=x2;
center_y=-axis_distance;
radius=Lb;
theta_circle=linspace(0,2*pi,100);
x=center_x + radius*cos(theta_circle);
y=center_y + radius*sin(theta_circle);



%% calculate 3D points 

%point1
px1=center_x;
py1=-axis_distance;
pz1=0;



%find the pair with image
condition = data_pointcloud(:, 5) == 1;
index_find_with_image=find(condition);
T = data_pointcloud(condition, 4);
with_image=[index_find_with_image,T];
output_3Dpoints_file='/home/minjikim/calibration/data/output_image/1118-3/selected/3Dpoints/calculated_3Dpoints_for_video.txt';


for i = 1:length(index_find_with_image)
    index_with_image = index_find_with_image(i);
    t_value=T(i);
    px2 = X(index_with_image);
    py2 = 0;

    m = (py2 - py1) / (px2 - px1);
    b = py1 - m * px1;

    a = 1 + m^2;
    b2 = 2 * (m * (b - center_y) - center_x);
    c = (center_x)^2 + (b - center_y)^2 - Lb^2;

    root = b2^2 - 4 * a * c;
    x_intersect1 = (-b2 + sqrt(root)) / (2 * a);
    y_intersect1 = m * x_intersect1 + b;
    x_intersect2 = (-b2 - sqrt(root)) / (2 * a);
    y_intersect2 = m * x_intersect2 + b;

    Lx1 = center_x;
    Ly1 = center_y;
    Lx2 = x_intersect1;
    Ly2 = y_intersect1;
    theta_draw = atan(m);
    Lx3 = Lx2 + Lh * cos(theta_draw);
    Ly3 = Ly2 + Lh * sin(theta_draw);
    x_line_2=Lx3+Lh*cos(theta_draw);
    y_line_2=Ly3+Lh*sin(theta_draw);


    result = [index_with_image,t_value, Lx1, Ly1, Lx2, Ly2, Lx3, Ly3,x_line_2,y_line_2];
   
    fileID = fopen(output_3Dpoints_file, 'a');
    fprintf(fileID, '%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n', result);
    
end
fclose(fileID);



% =========================================================================
% PART 3 : Image-Timestamp Matching and File Copy (based on 2D line txt files)
%
% [Input]  ForDrawing/s3-line/*.txt  (2D line files, timestamp embedded in filename)
%          undistorted/*.jpg          (lens-undistorted camera images)
% [Process] Extract timestamps from txt filenames
%           Match to image filenames within ±3ms tolerance
% [Output] finaldata/ (matched images and txt files copied)
% =========================================================================

clear;
clc;

% 폴더 및 파일 경로 설정
image_folder = '/home/minjikim/calibration/data/output_image/1118-3/undistorted';
output_folder = '/home/minjikim/calibration/data/output_image/1118-3/selected/finaldata';
txt_input_folder = '/home/minjikim/calibration/ForDrawing/s3-line';
output_3Dpoints_file = '/home/minjikim/calibration/data/output_image/1118-3/selected/3Dpoints/calculated_3Dpoints_for_video.txt';

% 결과 폴더 생성
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% txt 파일 목록 가져오기 (2Dlines 폴더)
txtFiles = dir(fullfile(txt_input_folder, '*.txt'));

% 모든 txt 파일 이름에서 타임스탬프 추출
timestamps = [];
for i = 1:length(txtFiles)
    % 파일 이름에서 숫자(타임스탬프) 추출
    txtFileName = txtFiles(i).name; % 예: img_1731929819102.txt
    numbers = regexp(txtFileName, '\d+', 'match'); % 숫자 추출
    if ~isempty(numbers)
        timestamp = str2double(numbers{1}); % 숫자로 변환
        timestamps = [timestamps; timestamp]; % 타임스탬프 추가
    end
end

timestamps = unique(timestamps); % 중복 타임스탬프 제거

% 이미지 파일 목록 가져오기
jpgFiles = dir(fullfile(image_folder, '*.jpg'));

% 타임스탬프와 매칭되는 이미지 파일 복사
for i = 1:length(timestamps)
    timestamp = timestamps(i);

    for k = 1:length(jpgFiles)
        fileName = jpgFiles(k).name;
        numbers = regexp(fileName, '\d+', 'match'); % 파일 이름에서 숫자 추출
        if ~isempty(numbers)
            current_number = str2double(numbers{1}); % 숫자로 변환
            if abs(current_number - timestamp) <= 3
                % 매칭된 이미지 복사
                source_image_path = fullfile(image_folder, fileName);
                output_image_path = fullfile(output_folder, fileName);
                txtFilePath = fullfile(txt_input_folder, sprintf('img_%d.txt', timestamp));

                if exist(source_image_path, 'file')
                    % 이미지 복사
                    copyfile(source_image_path, output_image_path);

                    % 대응되는 txt 파일 복사
                    if exist(txtFilePath, 'file')
                        copyfile(txtFilePath, output_folder);
                    end

                    fprintf('이미지 및 텍스트 파일 복사: %s -> %s\n', source_image_path, output_image_path);
                end
            end
        end
    end
end
% =========================================================================
% PART 4 : Reverse Filtering of 3D Point File
%
% [Purpose] Remove rows from 3D point file that have no matching image timestamp
% [Process] Compare col2 (timestamp) of each row against image timestamps (±3ms)
%           Keep only rows with a matching image → overwrite original file
% [Warning] Overwrites original file directly — no backup created
%           Delimiter changes from comma (Part 2) to space here
% =========================================================================
if exist(output_3Dpoints_file, 'file')
    data_3Dpoints = readmatrix(output_3Dpoints_file); % 3D 포인트 데이터 읽기

    % 조건에 맞는 행만 유지
    filtered_3Dpoints = [];
    for i = 1:size(data_3Dpoints, 1)
        point_timestamp = data_3Dpoints(i, 2); % 두 번째 열 값
        if any(abs(timestamps - point_timestamp) <= 3)
            filtered_3Dpoints = [filtered_3Dpoints; data_3Dpoints(i, :)];
        end
    end

    % 수정된 3D 포인트 데이터를 덮어쓰기
    writematrix(filtered_3Dpoints, output_3Dpoints_file, 'Delimiter', ' ');
    fprintf('조건에 맞지 않는 3D 포인트가 제거되었습니다.\n');
else
    fprintf('3D 포인트 파일이 존재하지 않습니다: %s\n', output_3Dpoints_file);
end



% =========================================================================
% PART 5 : Final Image Re-selection Based on Filtered 3D Point Timestamps
%
% [Purpose] After Part 4 filtering, re-copy only the images and 2D txt files
%           that correspond to surviving 3D point timestamps
% [Difference from Part 3]
%   Part 3 : driven by 2D txt file timestamps → selects images
%   Part 5 : driven by 3D point timestamps    → selects images (post-filtering)
% [Note]  txt_input_folder points to selected/2Dlines, different from Part 3
% =========================================================================
%% Load images

data=readmatrix(output_3Dpoints_file);
image_folder ='/home/minjikim/calibration/data/output_image/1118-3/undistorted';
output_folder = '/home/minjikim/calibration/data/output_image/1118-3/selected/finaldata';
txt_input_folder ='/home/minjikim/calibration/data/output_image/1118-3/selected/2Dlines';


if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
filePattern = fullfile(image_folder, 'img_*.jpg');
txtPattern=fullfile(txt_input_folder,'img_*.txt');

txtFiles = dir(txtPattern);
jpgFiles = dir(filePattern);


timestamps=data(:,2);



for i = 1:length(timestamps)
    timestamp=timestamps(i);

    for k = 1:length(jpgFiles)
        fileName = jpgFiles(k).name;
        numbers = regexp(fileName, '\d+', 'match');
        if ~isempty(numbers)
            current_number = str2double(numbers{1}); 
            txtFileName = sprintf('img_%d.txt', current_number);
            txtFilePath = fullfile(txt_input_folder, txtFileName);
            if abs(current_number - timestamp) <= 3
                source_image_path = fullfile(image_folder, fileName);
                output_image_path = fullfile(output_folder, fileName);
                img = imread(source_image_path);
                imwrite(img, output_image_path);
                copyfile(txtFilePath, output_folder);
            end
        end
    end
end

% =========================================================================
% PART 6 : 3D Point and 2D Line Matching
%
% [Input]  calculated_3Dpoints.txt  — 3D point coordinates with timestamps
%          finalselected/*.txt      — 2D line data per image (timestamp in filename)
% [Process] For each 2D line txt file, find the 3D point row within ±4ms
%           Store matched pairs into points_3D_list and lines_2D_list
% [Output] points_3D_list : cell array of matched 3D point sets
%          lines_2D_list  : cell array of corresponding 2D line data
% =========================================================================
output_3Dpoints_file='/home/minjikim/calibration/data/output_image/0822-6/selected/3Dpoints/calculated_3Dpoints.txt';
points_data=readmatrix(output_3Dpoints_file);
folder_path = '/home/minjikim/calibration/data/output_image/0822-6/selected/finalselected';
files = dir(fullfile(folder_path, '*.txt'));
%camera matrix
K=[
    157.7666572378147,0.0, 163.23651892984847;
    0.0,160.97657447313924 ,161.98825486428757;
    0.0,0.0,1.0]; 
D=[0,0,0,0,0];
imagesize=[195,300];


R_init=[
    1,0,0;
    0,1,0;
    0,0,1];
t_init= [0;0;0];

% points_3D=[
%     Lx1,Ly1,0;
%     x_intersect1,y_intersect1,0;
%     Lx3,Ly3,0]; 

options = optimoptions('lsqnonlin', 'Algorithm', 'levenberg-marquardt');

%save the points and line in same images
points_3D_list={};
lines_2D_list={};

function timestamp = extract_timestamp(filename)
    timestamp = str2double(filename(5:17));
end


for k=1:length(files)
    file_path = fullfile(folder_path, files(k).name);
    data = readmatrix(file_path);

    timestamp = extract_timestamp(files(k).name);
    points_3D=[];

    for j=1:size(points_data, 1)
        if abs(points_data(j, 2) -  timestamp) <= 4
            points_3D = [
                points_data(j, 3), points_data(j, 4), 0;
                points_data(j, 5), points_data(j, 6), 0;
                points_data(j, 7), points_data(j, 8), 0
            ];
            
            break;
        end
    end

    if ~isempty(points_3D)
        points_3D_list{end+1} = points_3D;
        lines_2D_list{end+1} = data;
    end
end
disp(points_3D_list);
disp(points_3D);


% =========================================================================
% PART 7 : Two-Stage Extrinsic Parameter Optimization (R, t)
%
% [Method]  Levenberg-Marquardt via lsqnonlin
% [Stage 1] error_function_with    — optimizes R, t from initial guess
% [Stage 2] function_error_second  — refines using Stage 1 result as init
% [Params]  R (3x3 rotation), t (3x1 translation) → flattened to 12-element vector
% [Note]    R is not constrained to SO(3) during optimization
% =========================================================================
objective_function = @(params) error_function_with(reshape(params(1:9), [3, 3]), params(10:12), points_3D_list, lines_2D_list, K);
params_init = [R_init(:); t_init];

params_optimized = lsqnonlin(objective_function, params_init, [], [], options);

R_optimized = reshape(params_optimized(1:9), [3, 3]);
t_optimized = params_optimized(10:12);
disp(R_optimized);
disp(t_optimized);

% 

objective_function = @(params) function_error_second(reshape(params(1:9), [3, 3]), params(10:12), points_3D_list, lines_2D_list, K);
params_init = [R_optimized(:); t_optimized];

params_optimized2 = lsqnonlin(objective_function, params_init, [], [], options);

R_optimized2 = reshape(params_optimized2(1:9), [3, 3]);
t_optimized2 = params_optimized2(10:12);
disp(R_optimized2);
disp(t_optimized2);

% =========================================================================
% PART 8 : Reprojection Visualization and Result Export
%
% [Process] For each matched image:
%   Step 1. Project 3D points onto image plane using optimized R, t
%   Step 2. Draw projected points as circles on the image (yellow = optimized)
%   Step 3. Save annotated image to figure output folder
%   Step 4. Write projected 2D coordinates to txt files (opti_1, opti_2 folders)
%
% [Note] R_optimized is hardcoded inside the loop — overrides lsqnonlin result
%        Commented-out blocks show T1 (initial guess) and T2 (stage 2) projections
% =========================================================================
figure;
hold on;

for k = 1:length(files)
    img = imread(fullfile(folder_path, strrep(files(k).name, '.txt', '.jpg')));
    points = points_3D_list{k};
    T = [R_optimized, t_optimized; 0, 0, 0, 1];
    %T1 = [R_init, t_init; 0, 0, 0, 1];

    T1 = [R_optimized0, t_optimized0; 0, 0, 0, 1];
    T2= [R_optimized2, t_optimized2; 0, 0, 0, 1];
    
    imshow(img);
    drawnow;
    hold on;

    [projected, valid] = projection(points, K, T, D, imagesize, false);
    x = projected(:, 1);
    y = projected(:, 2);
   % plot(x, y, 'yo', 'MarkerSize', 5, 'LineWidth', 2);
    
    [projected2, valid2] = projection(points, K, T1, D, imagesize, false);
    x2 = projected2(:, 1);
    y2 = projected2(:, 2);
    plot(x2-10, y2, 'mo', 'MarkerSize', 5, 'LineWidth', 2);
   

    circles1 = [x, y, repmat(2, size(x))]; % 첫 번째 원 세트 (노란색)
    circles2 = [x2, y2, repmat(2, size(x2))]; % 두 번째 원 세트 (자홍색)
    % 원을 그리면서 선 두께 지정
    img = insertShape(img, 'circle', circles1, 'Color', 'yellow', 'LineWidth', 2);
    %img = insertShape(img, 'circle', circles2, 'Color', 'magenta', 'LineWidth', 2);
    %img = insertShape(img, 'circle', circles3, 'Color', 'green', 'LineWidth', 2);
    % img = insertShape(img, 'Line', [x2, y2, x2, y2], 'Color', 'red', 'LineWidth', 6);
    % img = insertShape(img, 'Line', [x1, y1, x2, y2], 'Color', 'red', 'LineWidth', 6);


    % 이미지 저장
    output_filename = sprintf('/home/minjikim/calibration/figure/1107_inital/output_image_%d.jpg', k);
    imwrite(img, output_filename); % 이미지 저장
    % %shapeInserter = vision.ShapeInserter('Shape','Circles', ...
    %                                      'BorderColor','Custom','CustomBorderColor',uint8([255 0 0]), ...
    %                                      'LineWidth', 2); % 'LineWidth'를 조정하여 두께를 맞춤
    % circles = int32([x2 y2 repmat(3, length(x), 1)]); % 세 번째 열은 점의 반지름 (MarkerSize)
    % img = step(shapeInserter, img, circles);
    % 
    % % %shapeInserter2 = vision.ShapeInserter('Shape','Circles', ...
    % %                                       'BorderColor','Custom','CustomBorderColor',uint8([0 255 0]), ...
    % %                                       'LineWidth', 2);
    % circles3 = int32([x3 y3 repmat(3, length(x3), 1)]);
    % img = step(shapeInserter2, img, circles3);
    % 
    % frame = getframe(gca); % 현재 축을 캡처
    % imagewithpoint = frame.cdata; % 캡처한 데이터를 이미지로 변환
    % FinalImageFilePath='/home/minjikim/calibration/data/output_image/0822-6/selected/reprojection/visualization';
    % OutPutImage = fullfile(FinalImageFilePath, strrep(files(k).name, '.txt', '.jpg'));
    % imwrite(img, OutPutImage);

    ReprojectionPath1='/home/minjikim/calibration/data/output_image/0822-6/selected/reprojection/opti_1';
    ReprojectionPath2='/home/minjikim/calibration/data/output_image/0822-6/selected/reprojection/opti_2';
    ReprojectionFile1 = fullfile(ReprojectionPath1, [files(k).name]);
    ReprojectionFile2 = fullfile(ReprojectionPath2, [files(k).name]);
    fileID1 = fopen(ReprojectionFile1, 'w');
    fileID2 = fopen(ReprojectionFile2, 'w');
    for i = 1:size(projected2, 1)
        fprintf(fileID1, '%0.1f, %0.1f\n', x(i), y(i));
       % text(x2(i), y2(i), sprintf('(%0.1f, %0.1f)', x2(i), y2(i)), 'Color', 'y', 'FontSize', 10);
    end
    % for i = 1:size(projected3, 1)
    %     %fprintf(fileID2, '%0.1f, %0.1f\n', x3(i), y3(i));
    %     %text(x3(i), y3(i)-25, sprintf('(%0.1f, %0.1f)', x3(i), y3(i)), 'Color', 'g', 'FontSize', 8);
    % end
    % 
    % frame=getframe(gca);
    % imagewithpoint=frame2im(frame);
    % 파일 닫기
    fclose(fileID1);
    fclose(fileID2);
    clf;


end

hold off;

