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
        % line([px1_L px2_L], [py1_L py2_L], 'ro', 'magenta', 'LineWidth', 2);

        a_L = py1_L - py2_L;
        b_L = -(px1_L - px2_L);
        c_L = -(py1_L - py2_L) * px1_L + py1_L * (px1_L - px2_L);
        dist_L = abs(a_L * projected_point_L(1) + b_L * projected_point_L(2) + c_L) / sqrt(a_L^2 + b_L^2);


        px1_C = lines_2D(2, 1);
        py1_C = lines_2D(2, 2);
        px2_C = lines_2D(2, 3);
        py2_C = lines_2D(2, 4);
        % line([px1_C px2_C], [py1_C py2_C], 'go', 'magenta', 'LineWidth', 2);

        a_C = py1_C - py2_C;
        b_C = -(px1_C - px2_C);
        c_C = -(py1_C - py2_C) * px1_C + py1_C * (px1_C - px2_C);
        dist_C = abs(a_C * projected_point_C(1) + b_C * projected_point_C(2) + c_C) / sqrt(a_C^2 + b_C^2);

        px1_R = lines_2D(3, 1);
        py1_R = lines_2D(3, 2);
        px2_R = lines_2D(3, 3);
        py2_R = lines_2D(3, 4);
      

        a_R = py1_R - py2_R;
        b_R = -(px1_R - px2_R);
        c_R = -(py1_R - py2_R) * px1_R + py1_R * (px1_R - px2_R);


        dist_R = abs(a_R * projected_point_R(1) + b_R * projected_point_R(2) + c_R) / sqrt(a_R^2 + b_R^2);


        E = E + dist_L^2/0.714626801 + dist_C^2/0.2473117442 + dist_R^2/0.0380614537;
    end
end
