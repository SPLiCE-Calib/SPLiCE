===========================

This code is organized into input data, intermediate outputs, and final results
for calibration and geometric processing.

--------------------------------------------------
1. Input Data
--------------------------------------------------

input_calibration_board/
└── {date-trial}/
    ├── img_{timestamp}.jpg
    ├── ...
    └── multiranger_data_with.txt

Description:
- Raw calibration dataset.
- Contains RGB images captured at different timestamps.
- Includes multiranger (ToF/LiDAR) measurements aligned with images.



--------------------------------------------------
2. Line Detection Results
--------------------------------------------------

line_detected/
├── hough_trans/
│   ├── img_{timestamp}.jpg
│   ├── img_{timestamp}.txt
│   └── ...
└── lsd/
    ├── img_{timestamp}.jpg
    ├── img_{timestamp}.txt
    └── ...

Description:
- Stores line detection outputs using different methods:
  - hough_trans: Hough Transform-based detection
  - lsd: Line Segment Detector (LSD)
- Each image has:
  - .jpg → visualization
  - .txt → detected line parameters



--------------------------------------------------
3. Output Images & Intermediate Results
--------------------------------------------------

output_image/
└── {date-trial}/
    └── selected/
        ├── 3D_points/
        │   └── calculated_3D_points.txt
        │
        ├── 2D_lines/
        │   ├── img_{timestamp}.jpg
        │   ├── img_{timestamp}.txt
        │   └── ...
        │
        └── reprojection/
            ├── opti_1/
            │   ├── img_{timestamp}.txt
            │   └── ...
            │
            ├── opti_2/
            │   ├── img_{timestamp}.txt
            │   └── ...
            │
            └── truth/
                ├── truth_optimize_1.txt
                └── ...

Description:
- Selected features and processed data used for optimization.

Subfolders:
- 3D_points:
  - Reconstructed 3D points from sensor fusion.

- 2D_lines:
  - Selected 2D line features used for geometric constraints.

- reprojection:
  - Results of reprojection under different optimization settings:
    - opti_1 / opti_2 → different optimization strategies
    - truth → ground truth or reference results



--------------------------------------------------
4. Final Results
--------------------------------------------------

Result/
└── {date-trial}/
    ├── extrinsic parameter.txt
    └── pixel error.txt

Description:
- Final calibration outputs.

Files:
- extrinsic parameter.txt:
  - Estimated extrinsic parameters (rotation & translation).

- pixel error.txt:
  - Reprojection error statistics.



--------------------------------------------------
Notes
--------------------------------------------------

- {date-trial} indicates experiment runs separated by date or trial ID.
- {timestamp} corresponds to each captured frame.
- All .txt files store numerical results for further processing or evaluation.
- Visualization images (.jpg) are provided for debugging and qualitative analysis.

