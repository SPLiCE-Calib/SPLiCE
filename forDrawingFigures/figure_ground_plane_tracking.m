%% figure_ground_plane_tracking

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

% read selected image
imgIdx = 645;
imageCurForLine = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'gray');
imageCurForMW = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'rgb');
depthCurForMW = getImgInTUMRGBDdataset(datasetPath, ICLNUIMdataset, cam, imgIdx, 'depth');
[imageCurForMW, depthCurForMW] = getImgPyramid(imageCurForMW, depthCurForMW, optsMWMS.imagePyramidLevel);


% detect ground dominant plane
pNV = R_cM_MWMS{imgIdx}(:,1);
[sNV, sPP] = estimateSurfaceNormalGradient_mex(imageCurForMW, depthCurForMW, cam, optsMWMS);
[pNV, isTracked] = trackSinglePlane(pNV, sNV, optsMWMS);


% plot ground plane plane on RGB image
optsMWMS.halfApexAngle = deg2rad(7);
figure;
plot_plane_image(pNV, sNV, sPP, imageCurForMW, optsMWMS);    % AlphaData: 0.50
set(gca,'units','pixels'); x = get(gca,'position');
set(gcf,'units','pixels'); y = get(gcf,'position');
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
set(gca,'units','normalized','position',[0 0 1 1]);


% plot surface normal vector tracking
optsMWMS.halfApexAngle = deg2rad(15);
figure;
plot_plane_sphere(pNV, sNV, optsMWMS);
set(gcf,'color','w'); axis off; grid off; view(-1, -71);
set(gcf,'Units','pixels','Position',[800 150 800 800]);
f = FigureRotator(gca());


% copy current figure as vector graphics format
copygraphics(gcf,'ContentType','vector','BackgroundColor','none');


% for legend
figure;
h_plane = plot3(sNV(1,1:2), sNV(2,1:2), sNV(3,1:2),'Color','b','LineWidth',3.0); hold on;
h_sNV = plot3(sNV(1,1:2), sNV(2,1:2), sNV(3,1:2),'.','Color','k','MarkerSize',15); hold off;
set(gcf,'color','w'); axis equal; grid off;
legend([h_plane h_sNV],{'Ground Plane','Surface Normals'},'Orientation','vertical','FontSize',15,'FontName','Times New Roman');






