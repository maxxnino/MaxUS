
from PIL import Image
import os, random

input_dir = "input"
output_dir = "output"
base_size = 128
row_pixel = 4
total_row = int(base_size / row_pixel)

all_images = list(map(lambda image_name: f"{input_dir}/{image_name}", os.listdir(input_dir)))
random.shuffle(all_images)

base = Image.new("RGB", (base_size, base_size), (0, 0, 0))
for i, image in enumerate(all_images):
    im = Image.open(image)
    im = im.resize((base_size, row_pixel), Image.LANCZOS)
    row = i % total_row
    if row == 0 and i > total_row - 1:
        base.save(f"{output_dir}/gradient_map{int(i / total_row)}.png")
        base.close()
        base = Image.new("RGB", (base_size, base_size), (0, 0, 0))
    base.paste(im, (0, row * row_pixel), mask=im) 

base.save(f"{output_dir}/gradient_map-end.png")