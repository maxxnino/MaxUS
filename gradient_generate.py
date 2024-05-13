from colour import Color
from PIL import Image

input_file = "color.txt"
output_dir = "output"
base_size = 128
row_pixel = 4
total_row = int(base_size / row_pixel)

patterns = [
    # latin square, generate by sodoku solver
    [0, 1, 2, 3, 4],
    [1, 4, 0, 2, 3],
    [3, 0, 4, 1, 2],
    [4, 2, 3, 0, 1],
]

segments = [[0.2, 0.2, 0.2, 0.2]]
color_palettes = []

for i in range(len(segments)):
    accu = 0
    segment = segments[i]
    for j in range(len(segment)):
        value = int(segment[j] * base_size)
        if j == 0 or j == 2:
            value += 1
        segment[j] = value
        accu += value
    segment.append(base_size - accu)
    print(segment)

with open(input_file) as f:
    lines = f.read().splitlines()
    temp_track_color = set()
    for l in lines:
        if not l in temp_track_color:
            color_palettes.append(l.split(","))
            temp_track_color.add(l)


def colorToRGB(color: Color):
    rgb = color.rgb
    return (int(rgb[0] * 255), int(rgb[1] * 255), int(rgb[2] * 255))


def getGradientImage(gradient_range) -> Image:
    all_color = []
    for i, gradient_pair in enumerate(gradient_range):
        cur_range = gradient_pair[2]
        if i < len(gradient_range) - 1:
            cur_range += 1
        gradient = gradient_pair[0].range_to(gradient_pair[1], cur_range)
        new_color = list(map(colorToRGB, gradient))
        if i < len(gradient_range) - 1:
            new_color.pop()
        all_color += new_color
    image = Image.new("RGB", (base_size, 1), (0, 0, 0))
    image.putdata(all_color)
    return image


def generateColorGradientRange(colors: list[Color]):
    color_lists = []
    for seg in segments:
        l = []
        for i, value in enumerate(seg):
            if i < len(seg) - 1:
                l.append([colors[i], colors[i + 1], value])
            else:
                l.append([colors[-1], colors[0], value])
        color_lists.append(l)
    return color_lists


def generateColorList(colors) -> list[tuple[str]]:
    all_list = []
    for pattern in patterns:
        l = map(lambda x: colors[x], pattern)
        all_list.append(tuple(l))
    return all_list
    # print(len(all_list))
    # print(all_list)


palette_generated = []
for palette in color_palettes:
    palette_generated += generateColorList(palette)
palette_generated = list(
    map(lambda cl: list(map(lambda c: Color(c), cl)), palette_generated)
)
print("total palette", len(palette_generated))
print("total image", len(palette_generated) / total_row)
base = Image.new("RGB", (base_size, base_size), (0, 0, 0))
i_image = 0
for palette in palette_generated:
    a = generateColorGradientRange(palette)
    for value in a:
        image = getGradientImage(value)
        row = i_image % total_row
        for offset in range(row_pixel):
            base.paste(image, (0, row * row_pixel + offset))
        if row >= total_row - 1:
            save_name = f"{output_dir}/gradient_map{int(i_image / total_row)}.png"
            print(save_name)
            base.save(save_name)
            base.close()
            base = Image.new("RGB", (base_size, base_size), (0, 0, 0))
        image.close()
        i_image += 1

save_name = f"{output_dir}/gradient_map{int(i_image / total_row)}.png"
print(save_name)
base.save(save_name)
