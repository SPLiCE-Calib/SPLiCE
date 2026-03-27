function [planeNormalVector] = getGravityInTelloUrbanDataset(datasetPath, TelloUrbanDataset, frameIdx)

% read gravity direction vector (= plane normal vector)
planeNormalVector = importdata([datasetPath '/' TelloUrbanDataset.gravity.textName{frameIdx}]).';


end

