
clear;
clc;
input_directory = '/home/minjikim/calibration/data/output_image/1118-3/line_detected/plus';  
output_directory = '/home/minjikim/calibration/data/output_image/1118-3/line_detected/plus'; 
width = 300;  
height = 226;


process_all_files(input_directory, output_directory, width, height);



function process_all_files(input_directory, output_directory, width, height)
   
    files = dir(fullfile(input_directory, '*.txt'));

  
    for i = 1:length(files)
        input_file = fullfile(input_directory, files(i).name);
        output_file = fullfile(output_directory, files(i).name);
        

        convert_endpoints(input_file, output_file, width, height);
    end
end

function convert_endpoints(input_file, output_file, width, height)
    
    data = load(input_file);

    
    fid = fopen(output_file, 'w');

    for i = 1:size(data, 1)
        x1 = data(i, 1);
        y1 = data(i, 2);
        x2 = data(i, 3);
        y2 = data(i, 4);

        intersections = calculate_intersection(x1, y1, x2, y2, width, height);

        if size(intersections, 1) >= 2
        
            new_x1 = intersections(1, 1);
            new_y1 = intersections(1, 2);
            new_x2 = intersections(2, 1);
            new_y2 = intersections(2, 2);

           
            fprintf(fid, '%.6f %.6f %.6f %.6f\n', new_x1, new_y1, new_x2, new_y2);
        end
    end

   
    fclose(fid);
end

function intersections = calculate_intersection(x1, y1, x2, y2, width, height)
    intersections = [];

    if x2 == x1
        
        intersections = [intersections; x1, 0];
        intersections = [intersections; x1, height];
        return;
    end

    if y2 == y1
        
        intersections = [intersections; 0, y1];
        intersections = [intersections; width, y1];
        return;
    end

    x0 = 0;
    y0 = 0;
    x_width = width;
    y_height = height;

  
    y_at_0 = (y2 - y1) / (x2 - x1) * (x0 - x1) + y1;
    if y_at_0 >= 0 && y_at_0 <= height
        intersections = [intersections; 0, y_at_0];
    end

    y_at_width = (y2 - y1) / (x2 - x1) * (x_width - x1) + y1;
    if y_at_width >= 0 && y_at_width <= height
        intersections = [intersections; width, y_at_width];
    end


    x_at_0 = (x2 - x1) / (y2 - y1) * (y0 - y1) + x1;
    if x_at_0 >= 0 && x_at_0 <= width
        intersections = [intersections; x_at_0, 0];
    end

    x_at_height = (x2 - x1) / (y2 - y1) * (y_height - y1) + x1;
    if x_at_height >= 0 && x_at_height <= width
        intersections = [intersections; x_at_height, height];
    end

    return;
end
