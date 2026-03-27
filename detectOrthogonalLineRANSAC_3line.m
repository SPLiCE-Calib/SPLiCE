function [R_cM_final, clusteredLineIdx_final] = detectOrthogonalLineRANSAC_3line(lines, Kinv,cameraParams,optsOLVO,verticalDominantDirection1)
numLines = size(lines,1);
greatcircleNormal = zeros(numLines, 3);
vertical_dominant_direction1=verticalDominantDirection1;
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
    circleNormal = cross(ptEnd1_n_u.', ptEnd2_n_u.');
    circleNormal = circleNormal / norm(circleNormal);
    greatcircleNormal(k, :) = circleNormal;
end

%% 3-line RANSAC

% initialize RANSAC model parameters
totalLineNum = size(greatcircleNormal,1);
sampleLineNum = 3;
ransacMaxIterNum = 1000;
ransacIterNum = 30;
ransacIterCnt = 0;
maxClusteringNum = 0;
isSolutionFound = 0;

ProximityThresh = deg2rad(3);
ThreshInlier = optsOLVO.lineInlierThreshold;


% do 3-line RANSAC
while (true)
    
    % sample 3 line features
    [sampleIdx] = randsample(totalLineNum, sampleLineNum).';
    lineSampleIdxSet1 = sampleIdx(1:2);
    lineSampleIdxSet2 = sampleIdx(3);
    
    
    % estimate VP1
    if (abs(acos(dot(greatcircleNormal(lineSampleIdxSet1(1),:), greatcircleNormal(lineSampleIdxSet1(2),:)))) < ProximityThresh)
        continue;
    end
    VP1 = cross(greatcircleNormal(lineSampleIdxSet1(1),:), greatcircleNormal(lineSampleIdxSet1(2),:));
    VP1 = VP1 / norm(VP1);
   % [h1, h2] = plot_vertical_dominant_direction(VP1, 'black', 0.004);

    
    
    % estimate VP2
    VP2 = cross(VP1, greatcircleNormal(lineSampleIdxSet2,:));
    VP2 = VP2 / norm(VP2);
    if (abs(acos(dot(VP1, greatcircleNormal(lineSampleIdxSet2,:))) - pi/2) < ProximityThresh)
        continue;
    end
    
   % [h1, h2] = plot_vertical_dominant_direction(VP2, 'black', 0.004);
    % estimate VP3
    VP3 = cross(VP1, VP2);
    VP3 = VP3 / norm(VP3);

  %  [h1, h2] = plot_vertical_dominant_direction(VP3, 'black', 0.004);
    % estimate rotation model parameters
    my_rotation_angles = Fn_Rotation_Between_2_Coord_Syst_angles([1 0 0; 0 1 0; 0 0 1], [VP1; VP2; VP3]);
    
    
    % check number of inliers
    [~, ~, ~, distance_results_curr, ~] = Fn_GetLineClustering_GivenRotation(greatcircleNormal, my_rotation_angles, ThreshInlier, 3, 0, 0);
    
    
    % save the large consensus set
    if (distance_results_curr(4) >= maxClusteringNum)
        maxClusteringNum = distance_results_curr(4);
        best_rotation_angles = my_rotation_angles;
        maxClusteringIdx = [lineSampleIdxSet1, lineSampleIdxSet2];
        isSolutionFound = 1;
        
        % calculate the number of iterations (http://en.wikipedia.org/wiki/RANSAC)
        clusteringRatio = maxClusteringNum / totalLineNum;
        ransacIterNum = ceil(log(0.01)/log(1-(clusteringRatio)^sampleLineNum));
    end
    
    ransacIterCnt = ransacIterCnt + 1;
    if (ransacIterCnt >= ransacIterNum || ransacIterCnt >= ransacMaxIterNum)
        break;
    end
end


% re-formulate 3-line RANSAC result
if (isSolutionFound == 1)
    MyAngles_ByMultiRansac = best_rotation_angles;
    [dominant_directions, List_ClusteredNormals, List_ClusteredNormalsIndices,best_distances,~] = ...
        Fn_GetLineClustering_GivenRotation(greatcircleNormal, MyAngles_ByMultiRansac, ThreshInlier, 3, 1, 0);
    
    R_cM_final = dominant_directions.';
    clusteredLineIdx_final = List_ClusteredNormalsIndices.';

    for i = 1:3
        if sign(R_cM_final(1,i)) ~= sign(vertical_dominant_direction1(1,i))
            R_cM_final(1,i) = -R_cM_final(1,i);  % 부호 반전하여 일치시킴
        end
    end

    % 두 번째 행
    for i = 1:3
        if sign(R_cM_final(2,i)) ~= sign(vertical_dominant_direction1(4,i))
            R_cM_final(2,i) = -R_cM_final(2,i);  % 부호 반전하여 일치시킴
        end
    end

else
    R_cM_final = [];
    clusteredLineIdx_final = [];
end


end

