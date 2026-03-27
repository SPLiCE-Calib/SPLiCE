clear;
clc;

% 입력 및 출력 디렉토리 설정 (같은 디렉토리에서 처리)
input_directory = '/home/minjikim/calibration/data/output_image/1119/line_detected/hough';  
output_directory = input_directory;  % 결과를 같은 디렉토리에 저장

% 디렉토리 내 모든 .txt 파일 목록 가져오기
files = dir(fullfile(input_directory, '*.txt'));

% 모든 파일 처리
for file_idx = 1:length(files)
    % 각 파일 경로 설정
    input_file = fullfile(input_directory, files(file_idx).name);
    output_file = fullfile(output_directory, files(file_idx).name);  % 덮어쓰기
    
    % txt 파일에서 데이터 읽기
    data = readmatrix(input_file);

    % 두 번째 값이 0인 데이터와 나머지 데이터 분리
    zero_second_value = data(data(:, 2) == 0, :);
    non_zero_second_value = data(data(:, 2) ~= 0, :);

    % 두 번째 값이 0인 데이터는 첫 번째 값 기준으로 정렬
    zero_second_value = sortrows(zero_second_value, 1);

    % 나머지 데이터는 두 번째 값 기준으로 정렬
    non_zero_second_value = sortrows(non_zero_second_value, 2);

    % 정렬된 데이터를 합침
    sorted_data = [zero_second_value; non_zero_second_value];

    % 결과 파일에 저장 (덮어쓰기)
    writematrix(sorted_data, output_file, 'Delimiter', ' ');

    % 처리 완료 메시지 출력
    fprintf('정렬 후 결과가 저장되었습니다: %s\n', files(file_idx).name);
end

disp('모든 파일 정렬이 완료되었습니다.');
