%% figure_supplementary_Tello_Urban_1
% rgb_dataset_renaissance_03_corridor1 (1, 9)
% rgb_dataset_renaissance_04_corridor1 (6, 23)
% rgb_dataset_snowflake_square_building1 (29, 40)
% rgb_dataset_central_library_building1 (1, 4)

clc;
clear;
close all;

addpath('addon/lsd_1.6');
addpath('addon/lsd_1.6/Matlab');
addpath(genpath(pwd));


% Tello Urban Dataset (1~XX)
expCase = 1;
setupParams_Tello_Urban;


% load saved data in SaveDir
SaveDir = [datasetPath '/IROS2021'];
load([SaveDir '/MWMS.mat']);


%% plot original image with raw lines

% selected image index
imgIdx = 9;


% read rgb and gray images
imageCurForRGB = getImgInTelloUrbanDataset(datasetPath, TelloUrbanDataset, imgIdx, 'rgb');
imageCurForLine = getImgInTelloUrbanDataset(datasetPath, TelloUrbanDataset, imgIdx, 'gray');


% line detection with LSD
lineDetector = optsMWMS.lineDetector;
lineLength = optsMWMS.lineLength;
dimageCurForLine = double(imageCurForLine);
if (strcmp(lineDetector,'lsd'))
    [lines, ~] = lsdf(dimageCurForLine, (lineLength^2));
elseif (strcmp(lineDetector,'gpa'))
    [lines, ~] = gpa(imageCurForLine, lineLength);
end
lines = extractUniqueLines(imageCurForLine, lines, cam);


% plot original image and raw lines
figure;
imshow(imageCurForRGB, []); hold on;
for k = 1:size(lines,1)
    plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'c','LineWidth',4.0);
end
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);


%% plot RGB image with clustered lines

% read rgb and gray images, R_cM
imageCurForRGB = getImgInTelloUrbanDataset(datasetPath, TelloUrbanDataset, imgIdx, 'rgb');
imageCurForLine = getImgInTelloUrbanDataset(datasetPath, TelloUrbanDataset, imgIdx, 'gray');
R_cM = R_cM_MWMS{imgIdx};


% detect lines and related line normals
[lines, ~, lineNormals] = extractLinesAndGreatcircle(imageCurForLine, cam, optsMWMS);
lineNormals = lineNormals.';


% find the MW direction index
lines_labels_true = zeros(29,1);
for k = 1:size(lines,1)
    
    % find the MW direction
    MW_index = find(abs(90 - rad2deg(acos(lineNormals(:,k).' * R_cM))) <= 2);
    
    % save the MW direction
    if (MW_index == 1)
        lines_labels_true(k) = 1;
    elseif (MW_index == 2)
        lines_labels_true(k) = 2;
    elseif (MW_index == 3)
        lines_labels_true(k) = 3;
    else
        k
    end
end
lines_labels_true(2) = 1;
lines_labels_true(9) = 3;
lines_labels_true(10) = 3;
lines_labels_true(13) = 2;
lines_labels_true(28) = 3;


% plot RGB image with clustered lines
figure;
imshow(imageCurForRGB, []); hold on;
for k = 1:size(lines,1)
    if (lines_labels_true(k) == 1)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'r','LineWidth',6.0);
    elseif (lines_labels_true(k) == 2)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'g','LineWidth',6.0);
    elseif (lines_labels_true(k) == 3)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'b','LineWidth',6.0);
    else
        k
    end
end
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);







