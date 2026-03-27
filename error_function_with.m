
% =========================================================================
% Stage 1 Objective Function : Point-to-Line Distance Error
%
% [Purpose]
%   Compute the total reprojection error between projected 3D points
%   and their corresponding 2D lines detected in the image.
%   Used in Stage 1 optimization to find an initial estimate of R and t.
%
% [Method]
%   For each matched pair (3D points, 2D lines):
%     1. Transform 3D points into camera frame : p_cam = R * p + t
%     2. Project onto image plane using intrinsic matrix K (pinhole model)
%     3. Compute perpendicular distance from each projected point to its 2D line
%     4. Accumulate squared distances as total error E
%
% [Input]
%   R            : 3x3 rotation matrix (sensor → camera)
%   t            : 3x1 translation vector
%   points_list  : cell array of Nx3 3D point sets {[L;C;R], ...}
%   lines_2D_list: cell array of 2D line data {[x1,y1,x2,y2; ...], ...}
%                  row 1 = left line (L), row 2 = center line (C), row 3 = right line (R)
%   K            : 3x3 camera intrinsic matrix
%
% [Output]
%   E : total squared point-to-line distance (scalar, minimized by lsqnonlin)
% =========================================================================



function E = error_function_with(R, t, points_list, lines_2D_list, K)
    E = 0;

    for idx = 1:length(points_list)

        points = points_list{idx};
        lines_2D = lines_2D_list{idx};

        transformed_point_L = R * points(1, :)' + t;
        homogeneous_point_L = transformed_point_L;
        projected_point_homogeneous_L = K * homogeneous_point_L;
        projected_point_L = projected_point_homogeneous_L(1:2) / projected_point_homogeneous_L(3);
        projected_point_L = projected_point_L';


        transformed_point_C = R * points(2, :)' + t;
        homogeneous_point_C = transformed_point_C;
        projected_point_homogeneous_C = K * homogeneous_point_C;
        projected_point_C = projected_point_homogeneous_C(1:2) / projected_point_homogeneous_C(3);
        projected_point_C = projected_point_C';

        transformed_point_R = R * points(3, :)' + t;
        homogeneous_point_R = transformed_point_R;
        projected_point_homogeneous_R = K * homogeneous_point_R;
        projected_point_R = projected_point_homogeneous_R(1:2) / projected_point_homogeneous_R(3);
        projected_point_R = projected_point_R';

      
        %line!!!
      
        px1_L = lines_2D(1, 1);
        py1_L = lines_2D(1, 2);
        px2_L = lines_2D(1, 3);
        py2_L = lines_2D(1, 4);
        % line([px1_L px2_L], [py1_L py2_L], 'Color', 'magenta', 'LineWidth', 1);
        % plot(projected_point_L(1), projected_point_L(2), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');

        a_L = py1_L - py2_L;
        b_L = -(px1_L - px2_L);
        c_L = -(py1_L - py2_L) * px1_L + py1_L * (px1_L - px2_L);
        dist_L = abs(a_L * projected_point_L(1) + b_L * projected_point_L(2) + c_L) / sqrt(a_L^2 + b_L^2);


        px1_C = lines_2D(2, 1);
        py1_C = lines_2D(2, 2);
        px2_C = lines_2D(2, 3);
        py2_C = lines_2D(2, 4);
        % line([px1_C px2_C], [py1_C py2_C], 'Color', 'green', 'LineWidth', 1);
        % plot(projected_point_C(1), projected_point_C(2), 'go', 'MarkerSize', 3, 'MarkerFaceColor', 'g');

        a_C = py1_C - py2_C;
        b_C = -(px1_C - px2_C);
        c_C = -(py1_C - py2_C) * px1_C + py1_C * (px1_C - px2_C);
        dist_C = abs(a_C * projected_point_C(1) + b_C * projected_point_C(2) + c_C) / sqrt(a_C^2 + b_C^2);

        px1_R = lines_2D(3, 1);
        py1_R = lines_2D(3, 2);
        px2_R = lines_2D(3, 3);
        py2_R = lines_2D(3, 4);
        % line([px1_R px2_R], [py1_R py2_R], 'Color', 'blue', 'LineWidth', 1);
        % plot(projected_point_R(1), projected_point_R(2), 'bo', 'MarkerSize', 3, 'MarkerFaceColor', 'b');

      

        a_R = py1_R - py2_R;
        b_R = -(px1_R - px2_R);
        c_R = -(py1_R - py2_R) * px1_R + py1_R * (px1_R - px2_R);


        dist_R = abs(a_R * projected_point_R(1) + b_R * projected_point_R(2) + c_R) / sqrt(a_R^2 + b_R^2);


        E = E + dist_L^2 + dist_C^2 + dist_R^2;
    end
end
