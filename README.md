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

## Calibration Method
![](boardimage/calibrationboard1.png)
<p align="center">
  <img src="boardimage/calibrationboard2.png" width="30%"/>
  <img src="boardimage/calibrationboard3.png" width="30%"/>
</p>

### Requirements
- Position the Crazyflie **10~15cm** above the ground
- Place the checkerboard (788mm × 545mm) at **35~55cm** distance
- Stay at the starting point for at least **20 seconds**
- Rotate the checkerboard back and forth **more than 3 times**
- Rotate the checkerboard **more than 90 degrees**


## Requirements
- MATLAB (Image Processing Toolbox, Optimization Toolbox)
- Python 3 with OpenCV, NumPy
