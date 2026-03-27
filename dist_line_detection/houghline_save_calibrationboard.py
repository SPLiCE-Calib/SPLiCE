import cv2
import numpy as np
import os
import glob

# 입력 및 출력 디렉토리 설정
input_dir = '/home/minjikim/calibration/data/output_image/1119/undistorted/'
output_dir = '/home/minjikim/calibration/data/output_image/1119/line_detected/hough_r/'
os.makedirs(output_dir, exist_ok=True)
image_files = glob.glob(os.path.join(input_dir, '*.jpg'))

def line_intersection_with_borders(x1, y1, x2, y2, width, height):
    """ 이미지의 경계를 고려하여 직선의 교점을 찾는 함수 """
    intersections = []
    
    if x2 - x1 == 0:  # 수직선일 때 (x = constant)
        intersections.append((x1, 0))
        intersections.append((x1, height))
        return intersections

    if y2 - y1 == 0:  # 수평선일 때 (y = constant)
        intersections.append((0, y1))
        intersections.append((width, y1))
        return intersections

    # 직선의 방정식 y = mx + c 계산
    m = (y2 - y1) / (x2 - x1)
    c = y1 - m * x1

    # 네 개의 경계선과의 교점 찾기
    y_at_x0 = c  # x=0일 때 y 값
    y_at_x_width = m * width + c  # x=width일 때 y 값
    x_at_y0 = -c / m  # y=0일 때 x 값
    x_at_y_height = (height - c) / m  # y=height일 때 x 값

    # 유효한 교점 추가
    if 0 <= y_at_x0 <= height:
        intersections.append((0, int(y_at_x0)))
    if 0 <= y_at_x_width <= height:
        intersections.append((width, int(y_at_x_width)))
    if 0 <= x_at_y0 <= width:
        intersections.append((int(x_at_y0), 0))
    if 0 <= x_at_y_height <= width:
        intersections.append((int(x_at_y_height), height))

    return intersections[:2]  # 정확히 두 개의 교점만 반환

for image_path in image_files:
    image = cv2.imread(image_path)
    if image is None:
        continue

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    height, width = gray.shape

    blurred = cv2.GaussianBlur(gray, (3, 3), 0)
    edges = cv2.Canny(blurred, 30, 150, apertureSize=3)

    # 기존 HoughLines 대신 HoughLinesP 사용
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, 50, minLineLength=50, maxLineGap=5)
    image_name = os.path.basename(image_path).split('.')[0]
    txt_file_path = os.path.join(output_dir, f"{image_name}.txt")

    with open(txt_file_path, 'w') as file:
        if lines is not None:
            for line in lines:
                x1, y1, x2, y2 = line[0]

                # 이미지 경계와의 교점 계산
                intersections = line_intersection_with_borders(x1, y1, x2, y2, width, height)

                # 교점이 2개인 경우에만 직선 그리기
                if len(intersections) == 2:
                    (ix1, iy1), (ix2, iy2) = intersections
                    cv2.line(image, (ix1, iy1), (ix2, iy2), (0, 255, 0), 1)

                    # 교점 좌표 파일에 저장
                    file.write(f"{ix1} {iy1} {ix2} {iy2}\n")

        output_path = os.path.join(output_dir, os.path.basename(image_path))
        cv2.imwrite(output_path, image)
