function [targetImage, lines, lines_labels_true] = getImgInYorkUrbanDataset(datasetPath, YorkUrbanDataset, frameIdx, imgType)

% load York urban dataset data
subfolderName = YorkUrbanDataset.subfolder{frameIdx};
subfolderFile = dir(subfolderName);
subfolderFile(1:2) = [];


% read rgb image
imRgb = imread([subfolderName subfolderFile(2).name]);


% read labeled lines
LinesAndVP = importdata([subfolderName subfolderFile(5).name]);

% re-arrange lines
tempLines = LinesAndVP.lines;
numLines = size(tempLines,1)/2;
lines = zeros(numLines,4);
for k = 1:numLines
    lines(k,1:2) = tempLines(2*k-1,:);
    lines(k,3:4) = tempLines(2*k,:);
end

% ground-truth labels for lines
lines_labels_true = LinesAndVP.vp_association;


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


% figure;
% imshow(imRgb, []); hold on;
% for m = 1:numLines
%     plot([lines(m,1),lines(m,3)],[lines(m,2),lines(m,4)],'color','r','LineWidth',2.0);
% end
%
%
% figure;
% imshow(imRgb, []); hold on;
% for m = 1:numLines
%     if (lines_labels_true(m) == 1)
%         plot([lines(m,1),lines(m,3)],[lines(m,2),lines(m,4)],'color','r','LineWidth',2.0);
%     elseif (lines_labels_true(m) == 2)
%         plot([lines(m,1),lines(m,3)],[lines(m,2),lines(m,4)],'color','g','LineWidth',2.0);
%     elseif (lines_labels_true(m) == 3)
%         plot([lines(m,1),lines(m,3)],[lines(m,2),lines(m,4)],'color','b','LineWidth',2.0);
%     end
% end


