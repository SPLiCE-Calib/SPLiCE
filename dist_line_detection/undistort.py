
import numpy as np
import cv2
import os
import glob
import matplotlib.pyplot as plt

dist = np.array([-0.08391311501063284, 0.009461830705281877, 0.0006716947226127646, -0.00045922224938570465, 5.565869381517528e-05])
mtx = np.array([[182.07895128257198, 0, 163.39618960852425],
                [0, 182.56655743194796, 158.9138960066947],
                [0, 0, 1]])


input_dir = '/home/minjikim/calibration/data/input_calibrationboard/1119/'
output_dir = '/home/minjikim/calibration/data/input_calibrationboard/1119-1/'


os.makedirs(output_dir, exist_ok=True)


image_files = glob.glob(os.path.join(input_dir, '*.jpg'))


print({len(image_files)})

for image_path in image_files:
    image = cv2.imread(image_path)
 
    h, w = image.shape[:2]
    newcameramtx, roi = cv2.getOptimalNewCameraMatrix(mtx, dist, (w, h), 1, (w, h))
    dst = cv2.undistort(image, mtx, dist, None, newcameramtx)
    x, y, w, h = roi
    dst = dst[y:y+h, x:x+w]
    print(newcameramtx)
    output_path = os.path.join(output_dir, os.path.basename(image_path))

    cv2.imwrite(output_path, dst)




'''
import numpy as np
import cv2
import matplotlib.pyplot as plt
import glob
import os

dist = np.array([-0.08391311501063284, 0.009461830705281877, 0.0006716947226127646, -0.00045922224938570465, 5.565869381517528e-05])
mtx = np.array([[182.07895128257198, 0, 163.39618960852425],
      [0, 182.56655743194796, 158.9138960066947],
      [0, 0, 1]])

input_dir = '/home/minjikim/calibration/data/output_image/selected/'
output_dir = '/home/minjikim/calibration/data/output_image/undistorted/'

os.makedirs(output_dir, exist_ok=True)
image_files = glob.glob(os.path.join(input_dir, '*.jpg'))

for image_path in image_files:
   
    image = cv2.imread(image_path)
    if image is None:
        continue
    

    h, w = image.shape[:2]

  
    newcameramtx, roi = cv2.getOptimalNewCameraMatrix(mtx, dist, (w, h), 1, (w, h))


    dst = cv2.undistort(image, mtx, dist, None, newcameramtx)


    x, y, w, h = roi
    dst = dst[y:y+h, x:x+w]


    output_path = os.path.join(output_dir, os.path.basename(image_path))


    cv2.imwrite(output_path, dst)

    plt.imshow(cv2.cvtColor(dst, cv2.COLOR_BGR2RGB))
    plt.title('Undistorted Image')
    plt.show()
    
'''


#cv2.imshow('result', dst)
#cv2.imwrite('img_1721702532802_undistored.jpg', dst)
#cv2.destroyAllWindows()
'''
{"RMS": 0.22458155563276783, 
"CameraMatrix": 
[[182.07895128257198, 0.0, 163.39618960852425], 
[0.0, 182.56655743194796, 158.9138960066947],# 
[0.0, 0.0, 1.0]], 


"DistortionCoefficients": 
[-0.08391311501063284, 0.009461830705281877, 0.0006716947226127646, -0.00045922224938570465, 5.565869381517528e-05], 


"NewCameraMatrix": 
[[157.7666572378147, 0.0, 163.23651892984847], 
[0.0, 160.97657447313924, 161.98825486428757], 
[0.0, 0.0, 1.0]], 

"ROI": [11, 12, 300, 226]}
'''
