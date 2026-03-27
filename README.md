# SPLiCE
Extrinsic calibration pipeline for Crazyflie camera and multiranger sensor using checkerboard rotation model and line-based optimization.


# Crazyflie Camera-Multiranger Extrinsic Calibration

This repository contains a calibration pipeline for estimating the extrinsic parameters (R, t) 
between a camera and a multiranger distance sensor mounted on a Crazyflie drone.

## Overview
A checkerboard is rotated in front of the drone while the multiranger sensor records distance data 
and the camera captures synchronized images. 3D coordinates of the checkerboard are computed from 
the sensor data using a rotation arc model, and 2D line features are extracted from the images. 
Extrinsic parameters are estimated by minimizing the reprojection error between the 3D points 
and the detected 2D lines via two-stage Levenberg-Marquardt optimization.

## Pipeline
1. Sensor data preprocessing and outlier removal
2. 3D coordinate computation from checkerboard rotation model
3. 2D line detection from camera images (LSD / Hough Transform)
4. Image-timestamp synchronization and data matching
5. Two-stage extrinsic parameter optimization (R, t)
6. Reprojection visualization and error evaluation

## Requirements
- MATLAB (Image Processing Toolbox, Optimization Toolbox)
- Python 3 with OpenCV, NumPy
