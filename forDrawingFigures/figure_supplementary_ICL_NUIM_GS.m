%% figure_supplementary_ICL_NUIM_GS

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
optsMWMS.lineLength = 60;


%% plot original image with raw lines

% selected image index
imgIdx = 645;


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
    plot([lines(k,1),lines(k,3)],[lines(k,2),lines(k,4)],'LineWidth',3.0);
end
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);


%% plot original image with extended lines

% read selected image
imgIdx = 645;
imageCurForRGB = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'rgb');
imageCurForLine = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'gray');
imageCurForMW = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'rgb');
depthCurForMW = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'depth');
[imageCurForMW, depthCurForMW] = getImgPyramid(imageCurForMW, depthCurForMW, optsMWMS.imagePyramidLevel);


% assign current parameters
lineDetector = optsMWMS.lineDetector;
lineDescriptor = optsMWMS.lineDescriptor;
dimageCurForLine = double(imageCurForLine);
K = cam.K_pyramid(:,:,1);
Kinv = inv(K);


% detect ground dominant plane
pNV = R_cM_MWMS{imgIdx}(:,1);
[sNV, sPP] = estimateSurfaceNormalGradient_mex(imageCurForMW, depthCurForMW, cam, optsMWMS);
[pNV, isTracked] = trackSinglePlane(pNV, sNV, optsMWMS);
planeNormalVector = pNV;


% check plane normal vector is on the hemisphere
[~, ~, planeNormalVector] = parametrizeVerticalDD(planeNormalVector);


% detect lines and related line normals
[lines, ~, lineNormals] = extractLinesAndGreatcircle(imageCurForLine, cam, optsMWMS);
lineNormals = lineNormals.';


% find useless (invalid) lines for Manhattan world
optsMWMS.verticalPolarRegionAngleThreshold = 2;
invalidIndex = findInvalidManhattanLines(planeNormalVector, lineNormals, optsMWMS);
lineNormals(:,invalidIndex) = [];
lines(invalidIndex,:) = [];


% estimate Manhattan world directions (R_cM) with max stabbing
[R_cM, optimalProbe, thetaIntervals] = ManhattanMaxStabbingIntervals(planeNormalVector, lineNormals);
[clusteredLinesIdx] = clusterManhattanMaxStabbingLines(R_cM, optimalProbe, thetaIntervals);
linesVP = cell(1,3);
for k = 1:3
    
    % current lines in VPs
    linesInVP = lines(clusteredLinesIdx{k},:);
    numLinesInVP = size(linesInVP,1);
    
    % line clustering for each VP
    line = struct('data',{},'length',{},'centerpt',{},'linenormal',{},'circlenormal',{});
    numLinesCnt = 0;
    for m = 1:numLinesInVP
        [linedata, centerpt, len, ~, linenormal, circlenormal] = roveFeatureGeneration(dimageCurForLine, linesInVP(m,1:4), Kinv, lineDescriptor);
        if (~isempty(linedata))
            numLinesCnt = numLinesCnt+1;
            line(numLinesCnt) = struct('data',linedata,'length',len,'centerpt',centerpt,'linenormal',linenormal,'circlenormal',circlenormal);
        end
    end
    
    % save line clustering results
    linesVP{k} = line;
end


% initialize vpInfo
vpInfo = struct('n',{},'line',{},'index',{});
for k = 1:3
    
    % current VP info
    line = linesVP{k};
    numLine = size(line,2);
    vpInfo(k) = struct('n',numLine,'line',line,'index',k);
end


% plot original image and extended lines
optsMWMS.imagePyramidLevel = 1;
figure;
imshow(imageCurForRGB,[]); hold on;
plot_extended_lines(R_cM, vpInfo, imageCurForLine, cam, optsMWMS);
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);


%% plot normal vectors on the Gaussian sphere

% plot normal vectors on the Gaussian sphere
figure;
plot_unit_sphere(1, 20, 0.5); hold on; grid on; axis equal;
plot_line_normals_unit_sphere(imageCurForLine, cam, optsMWMS);
plot_MW_unit_sphere(R_cM); hold off; axis off;
view(-1, -71);
f = FigureRotator(gca());
% plot3(normal(1),normal(2),normal(3),'o','MarkerSize',8,'LineWidth',1.5,'Color','k','MarkerFaceColor',[180/255,180/255,180/255]);


% copy current figure as vector graphics format
copygraphics(gcf,'ContentType','vector','BackgroundColor','none');


% for legend
figure;
h_VDD = plot3([0 1],[0 1],[0 1],'Color','b','LineWidth',3.0); hold on;
h_normal = plot3(1,1,1,'o','MarkerSize',8,'LineWidth',1.5,'Color','k','MarkerFaceColor',[180/255,180/255,180/255]); hold off;
set(gcf,'color','w'); axis equal; grid off;
legend([h_VDD h_normal],{'Ground Plane Direction','Normals of Great Circles'},'Orientation','vertical','FontSize',15,'FontName','Times New Roman');




