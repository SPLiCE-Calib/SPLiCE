import cv2
import numpy as np
import os
import glob

input_dir = '/home/minjikim/calibration/data/output_image/1119/undistorted/'
output_dir = '/home/minjikim/calibration/data/output_image/1119/line_detected/lsd/'

os.makedirs(output_dir, exist_ok=True)

image_files = glob.glob(os.path.join(input_dir, '*.jpg'))

print(f"발견된 이미지 파일 수: {len(image_files)}개")

lsd = cv2.createLineSegmentDetector()

for image_path in image_files:
    folder, imgName = os.path.split(image_path)

    src = cv2.imread(image_path, cv2.IMREAD_COLOR)
    gray = cv2.cvtColor(src, cv2.COLOR_BGR2GRAY)

    lsd = cv2.createLineSegmentDetector(0)
    lines = lsd.detect(gray)[0]
    img_lines = lsd.drawSegments(gray, lines)

    output_path = os.path.join(output_dir, os.path.basename(image_path))
    cv2.imwrite(output_path, img_lines)

    txt_file_path = os.path.join(output_dir, os.path.splitext(os.path.basename(image_path))[0] + '.txt')
    with open(txt_file_path, 'w') as f:
        for line in lines:
            for x1, y1, x2, y2 in line:
                # 기울기 계산 (라디안 단위)
                slope_rad = np.arctan2((y2 - y1), (x2 - x1))
                if slope_rad<0:
                    slope_rad = slope_rad + np.pi

                # 직선 방정식의 계수 A, B, C 계산 (Ax + By + C = 0)
                A = -slope_rad
                B = 1
                C = -(y1 - slope_rad * x1)

                # 원점(0, 0)에서 직선까지의 거리 계산
                distance = abs(C) / np.sqrt(A**2 + B**2)

                # 거리와 기울기를 파일에 쓰기
                f.write(f"{distance:.5f} {slope_rad:.5f}\n")

    if os.path.exists(output_path):
        print(f"선이 감지된 이미지 저장됨: {output_path}")
    else:
        print(f"선이 감지된 이미지 저장 실패: {output_path}")
