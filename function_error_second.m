
% =========================================================================
% Stage 2 Objective Function : Line-Intersection Distance Error
%
% [Purpose]
%   Refine R and t using a more geometrically strict error metric.
%   Instead of point-to-line distance (Stage 1), this function computes
%   the distance between line intersections derived from:
%     - 2D detected lines in the image (top/bottom edges of checkerboard)
%     - Lines constructed from projected 3D points
%
% [Method]
%   For each matched pair (3D points, 2D lines):
%     1. Project 3D points (L, C, R) onto image plane via R, t, K
%     2. Extract top (t) and bottom (b) lines from detected 2D line data
%        — uses last 2 rows of lines_2D (line_index, line_index-1)
%     3. Construct 2 lines from projected points:
%        — line f : L → C
%        — line s : L → R
%     4. Compute 5 intersections between detected and projected lines:
%        — intersection1 : line_t ∩ line_b  (detected lines cross point)
%        — intersection2 : line_t ∩ line_s  (detected top vs projected L-R)
%        — intersection3 : line_t ∩ line_f  (detected top vs projected L-C)
%        — intersection4 : line_b ∩ line_s  (detected bottom vs projected L-R)
%        — intersection5 : line_b ∩ line_f  (detected bottom vs projected L-C)
%     5. Accumulate squared distance between intersection pairs as error:
%        E += dist(intersection1, intersection2)²
%           + dist(intersection1, intersection4)²
%
% [Input]
%   R            : 3x3 rotation matrix (sensor → camera)
%   t            : 3x1 translation vector
%   points_list  : cell array of Nx3 3D point sets {[L;C;R], ...}
%   lines_2D_list: cell array of 2D line data {[x1,y1,x2,y2; ...], ...}
%                  last row     = top edge line (t)
%                  second-to-last row = bottom edge line (b)
%   K            : 3x3 camera intrinsic matrix
%
% [Output]
%   E : total squared intersection distance error (scalar, minimized by lsqnonlin)
%
% [Note] intersection3 and intersection5 are computed but not used in E
%        — likely reserved for future extended error terms
% =========================================================================



function E = function_error_second(R, t, points_list, lines_2D_list, K)
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

      
        line_index=size(lines_2D_list{idx},1);
        %intersection add with line

        x1_t = lines_2D(line_index, 1);
        y1_t = lines_2D(line_index, 2);
        x2_t = lines_2D(line_index, 3);
        y2_t = lines_2D(line_index, 4);
        % line([x1_t, x2_t], [y1_t y2_t], 'Color', 'magenta', 'LineWidth', 1);
        
        a_t = y1_t - y2_t;
        b_t = -(x1_t - x2_t);
        c_t = -(y1_t - y2_t) * x1_t + y1_t * (x1_t - x2_t);


        x1_b = lines_2D(line_index-1, 1);
        y1_b = lines_2D(line_index-1, 2);
        x2_b = lines_2D(line_index-1, 3);
        y2_b = lines_2D(line_index-1, 4);
        % line([x1_b, x2_b], [y1_b y2_b], 'Color', 'magenta', 'LineWidth', 1);

        a_b = y1_b - y2_b;
        b_b = -(x1_b - x2_b);
        c_b = -(y1_b - y2_b) * x1_b + y1_b * (x1_b - x2_b);

        A1 = [a_t, b_t; a_b, b_b];
        B1 = [-c_t; -c_b];
        intersection1 = A1 \ B1;
        % plot(intersection1(1), intersection1(2), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
        %line maked by points

        x1_f = projected_point_L(1);
        y1_f = projected_point_L(2);
        x2_f = projected_point_C(1);
        y2_f = projected_point_C(2);

        a_f = y1_f - y2_f;
        b_f = -(x1_f - x2_f);
        c_f = -(y1_f - y2_f) * x1_f + y1_f * (x1_f - x2_f);
        % line([x1_f, x2_f], [y1_f y2_f], 'Color', 'magenta', 'LineWidth', 1);

        x1_s = projected_point_L(1);
        y1_s = projected_point_L(2);
        x2_s = projected_point_R(1);
        y2_s = projected_point_R(2);

        a_s = y1_s - y2_s;
        b_s = -(x1_s - x2_s);
        c_s = -(y1_s - y2_s) * x1_s + y1_s * (x1_s - x2_s);

        A2 = [a_t, b_t; a_s, b_s];
        B2 = [-c_t; -c_s];
        intersection2 = A2 \ B2;
        % plot(intersection2(1), intersection2(2), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');

        A3 = [a_t, b_t; a_f, b_f];
        B3 = [-c_t; -c_f];
        intersection3 = A3 \ B3;

        A4 = [a_b, b_b; a_s, b_s];
        B4 = [-c_b; -c_s];
        intersection4 = A4 \ B4;
        % plot(intersection4(1), intersection4(2), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');


        A5 = [a_b, b_b; a_f, b_f];
        B5 = [-c_b; -c_f];
        intersection5 = A5 \ B5;

        dist_intersection1 = (intersection1(1) - intersection2(1))^2 + (intersection1(2) - intersection2(2))^2;
        dist_intersection2 = (intersection1(1) - intersection4(1))^2 + (intersection1(2) - intersection4(2))^2;
  


        E=E+dist_intersection1+dist_intersection2;

    end
end
