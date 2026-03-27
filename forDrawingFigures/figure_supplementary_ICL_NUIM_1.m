%% figure_supplementary_ICL_NUIM_1 (lr_kt2 (420), lr_kt0_pure(945), of_kt0(415), of_kt1(550))

clc;
clear;
close all;

addpath('addon/lsd_1.6');
addpath('addon/lsd_1.6/Matlab');
addpath(genpath(pwd));


% ICL NUIM dataset (1~8)
expCase = 1;
setupParams_ICL_NUIM;


% load saved data in SaveDir
SaveDir = [datasetPath '/IROS2021'];
load([SaveDir '/MWMS.mat']);


%% plot original image with raw lines

% selected image index
imgIdx = 420;


% read rgb and gray images
imageCurForRGB = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'rgb');
imageCurForLine = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'gray');


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


%% plot tracked plane on the image

% read selected image
imageCurForMW = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'rgb');
depthCurForMW = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'depth');
[imageCurForMW, depthCurForMW] = getImgPyramid(imageCurForMW, depthCurForMW, optsMWMS.imagePyramidLevel);


% detect ground dominant plane
pNV = pNV_MWMS{imgIdx};
[sNV, sPP] = estimateSurfaceNormalGradient_mex(imageCurForMW, depthCurForMW, cam, optsMWMS);
[pNV, isTracked] = trackSinglePlane(pNV, sNV, optsMWMS);


% plot ground plane on RGB image
optsMWMS.halfApexAngle = deg2rad(7);
figure;
plot_plane_image(pNV, sNV, sPP, imageCurForMW, optsMWMS);    % AlphaData: 0.50
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);


%% plot RGB image with clustered lines

% read rgb and gray images, R_cM
imageCurForRGB = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'rgb');
imageCurForLine = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'gray');
R_cM = R_cM_MWMS{imgIdx};


% detect lines and related line normals
[lines, ~, lineNormals] = extractLinesAndGreatcircle(imageCurForLine, cam, optsMWMS);
lineNormals = lineNormals.';


% find the MW direction index
lines_labels_true = zeros(17,1);
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
lines_labels_true(17) = 3;


% plot RGB image with clustered lines
figure;
imshow(imageCurForRGB, []); hold on;
for k = 1:size(lines,1)
    if (lines_labels_true(k) == 1)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'g','LineWidth',6.0);
    elseif (lines_labels_true(k) == 2)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'b','LineWidth',6.0);
    elseif (lines_labels_true(k) == 3)
        plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'r','LineWidth',6.0);
    else
        k
    end
end
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);


%% plot true and estimated camera frame with MW

% plot drift-free camera orientation with MW
figure;
hold on; grid on; axis equal; view(110,20);
plot_Manhattan_camera_frame(R_cM, R_gc_MWMS(:,:,imgIdx));
set(gcf,'color','w'); axis off;
plot_true_camera_frame(R_gc_true(:,:,imgIdx)); hold off;
set(gcf,'Units','pixels','Position',[900 120 500 500]);


% copy current figure as vector graphics format
copygraphics(gcf,'ContentType','vector','BackgroundColor','none');












