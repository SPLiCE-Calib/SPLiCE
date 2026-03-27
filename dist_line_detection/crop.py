import os
from PIL import Image

#input_folder = '/home/minjikim/calibration/data/output_image/0822-6/undistorted'

#output_folder = '/home/minjikim/calibration/data/output_image/0822-6/undistorted'

input_folder='/home/minjikim/calibration/ev22'
output_folder='/home/minjikim/calibration/ev22'

if not os.path.exists(output_folder):
    os.makedirs(output_folder)


for filename in os.listdir(input_folder):
    if filename.endswith(('.png', '.jpg', '.jpeg', '.bmp', '.tiff')):  
        image_path = os.path.join(input_folder, filename)
        
        image = Image.open(image_path)

        width, height = image.size

        crop_rectangle = (0, 0, width, height - 31)

        cropped_image = image.crop(crop_rectangle)


        output_path = os.path.join(output_folder, filename)

        cropped_image.save(output_path)

        print(f'Cropped image saved as {output_path}')

print('All images have been processed.')
