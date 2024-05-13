from PIL import Image, ImageChops
import os, random

base_size = 1024
half_base_size = 512
scale_min = 0.2
scale_max = 0.4
number_images = 10
at_least_percent_area = 0.4
offset_pixel = 128
input_dir = "input"
output_dir = "output"

offset_size = int(base_size / offset_pixel) - 1
at_least_area = int(base_size * base_size * at_least_percent_area)
all_images = list(
    map(lambda image_name: f"{input_dir}/{image_name}", os.listdir(input_dir))
)

for i in range(0, number_images):
    base = Image.new("RGBA", (base_size, base_size), (0, 0, 0, 0))
    current = 0
    while current < at_least_area:
        im = Image.open(random.choice(all_images))
        width, height = im.size
        scale = random.uniform(scale_min, scale_max)
        base_scale = scale * base_size
        real_scale = base_scale / width
        scale_w = int(width * real_scale)
        scale_h = int(height * real_scale)
        rotale = random.randrange(1, 35) * 10
        im = im.resize((scale_w, scale_h), Image.LANCZOS)
        im = im.rotate(rotale, Image.BICUBIC, 1)
        # if random.randrange(0, 10) > 7:
        base = ImageChops.offset(
            base,
            random.randrange(1, offset_size) * offset_pixel,
            random.randrange(1, offset_size) * offset_pixel,
        )
        width, height = im.size
        x = random.randrange(offset_pixel, base_size - width - offset_pixel)
        y = random.randrange(offset_pixel, base_size - height - offset_pixel)
        base.paste(im, (x, y), mask=im)
        im.close()
        current += scale_w * scale_h
    base = base.resize((half_base_size, half_base_size), Image.LANCZOS)
    base.save(f"{output_dir}/{i}.png")
