%% figure_eval_multiple_image_array
%% 1) York Urban Dataset

clc;
clear;
close all;

addpath('addon/lsd_1.6');
addpath('addon/lsd_1.6/Matlab');
addpath(genpath(pwd));


% York Urban Dataset (1~XX)
expCase = 1;
setupParams_York_Urban;


% load saved data in SaveDir
SaveDir = [datasetPath '/IROS2021'];
load([SaveDir '/MWMS.mat']);


%% plot original image

% selected image index
imgIdx = 77;


% read gray image & labeled lines
[imageCurForRGB, lines, lines_labels_true] = getImgInYorkUrbanDataset(datasetPath, YorkUrbanDataset, imgIdx, 'rgb');


% plot original image and raw lines
figure;
imshow(imageCurForRGB, []); hold on;
for k = 1:size(lines,1)
    plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'c','LineWidth',2.5);
end
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);


%% plot clustered lines

% plot original image and raw lines
figure;
imshow(imageCurForRGB, []); hold on;
for k = 1:size(lines,1)
    if (lines_labels_true(k) == 1)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'g','LineWidth',3.0);
    elseif (lines_labels_true(k) == 2)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'b','LineWidth',3.0);
    elseif (lines_labels_true(k) == 3)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'r','LineWidth',3.0);
    end
end
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);



%% 2) ICL NUIM Dataset

% selected image index
imgIdx = 290;


% read RGB image
imageCurForRGB = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'rgb');


% plot original image and raw lines
figure;
imshow(imageCurForRGB, []); hold on;
for k = 1:size(lines,1)
    plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'c','LineWidth',2.5);
end
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);










































%% 3) Tello Urban Dataset





%% plot original image

% selected image index
imgIdx = 23;


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
lineNormals(:,9) = [];
lines(9,:) = [];


% plot original image and raw lines
figure;
imshow(imageCurForRGB, []); hold on;
for k = 1:size(lines,1)
    plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'c','LineWidth',2.5);
end
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);


% plot clustered lines
figure;
imshow(imageCurForRGB, []); hold on;
for k = 1:size(lines,1)
    
    % find the MW direction
    MW_index = find(abs(90 - rad2deg(acos(lineNormals(:,k).' * R_cM))) <= 5);
    
    % draw MW clustered line
    if (MW_index == 1)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'r','LineWidth',6.0);
    elseif (MW_index == 2)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'g','LineWidth',6.0);
    elseif (MW_index == 3)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'b','LineWidth',6.0);
    else
        k
    end
end
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);










