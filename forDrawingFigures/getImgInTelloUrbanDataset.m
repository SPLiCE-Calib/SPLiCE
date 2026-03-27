function [targetImage] = getImgInTelloUrbanDataset(datasetPath, TelloUrbanDataset, frameIdx, imgType)
% Project:    Manhattan World Max Stabbing (MWMS)
% Function:  getImgInTelloUrbanDataset
%
% Description:
%   get gray image from Tello Urban Dataset
%
% Example:
%   OUTPUT:
%   targetImage : imported images to workspace from [datasetPath]
%                  if imgType is 'gray' -> targetImage is a gray image. (uint8)
%
%
%   INPUT:
%   datasetPath: absolute path to Tello Urban dataset directory
%   TelloUrbanDataset: compact and synchronized rgb datasets
%   frameIdx: frame index of Tello Urban Dataset ( 1-based index )
%   ImgType: the type of images ( 'gray' or 'rgb' )
%
%
% NOTE:
%
% Author: Pyojin Kim
% Email: pjinkim@sookmyung.ac.kr
% Website: http://mpil.sookmyung.ac.kr/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% log:
% 2021-02-01: Complete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%


% read rgb image
imRgb = imread([ datasetPath '/' TelloUrbanDataset.rgb.imgName{frameIdx} ]);


% determine what imgType is ( 'gray' or 'rgb' )
if ( strcmp(imgType, 'gray') )
    
    % convert rgb to gray image
    targetImage = uint8(rgb2gray(imRgb));
    
    % show current situation
    fprintf('----''%s'' images are imported to workspace [%04d] ---- \n', imgType, frameIdx);
    
    
elseif ( strcmp(imgType, 'rgb') )
    
    % raw rgb image
    targetImage = imRgb;
    
    % show current situation
    fprintf('----''%s'' images are imported to workspace [%04d] ---- \n', imgType, frameIdx);
    
    
else
    
    fprintf('\nWrong input(imgType) parameter!!! \n');
    fprintf('What is the ''%s'' ??\n',imgType);
    error('Wrong input(imgType) parameter!!!')
    
end

end