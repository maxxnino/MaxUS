from colour import Color
from PIL import Image
import colorsys

output_dir = "output"
base_size = 128
row_pixel = 4
total_row = int(base_size / row_pixel)
hue_shift = 0.07
saturate_shift = 0.07
segment = [0.25, 0.25, 0.25]
hue_count = 4

accu = 0
for i in range(len(segment)):
    value = int(segment[i] * base_size)
    segment[i] = value
    accu += value
segment.append(base_size - accu)


def getVRanges():
    count = 6
    step = 0.8 / count
    jump = count / 10
    yield (
        0.1,
        0.1 + jump * 2 * step,
        0.1 + jump * 4 * step,
        0.1 + jump * 8 * step,
        0.1 + jump * 10 * step,
    )
    for i in range(count + 1):
        v = 0.1 + i * step
        end_v = v + 4 * step
        if end_v > 1:
            break
        else:
            yield (v, v + step, v + 2 * step, v + 3 * step, end_v)


def getSRanges():
    count = 6
    step = 0.8 / count
    for i in range(count + 1):
        s = 0.1 + i * step
        end_s = s + 4 * saturate_shift
        if end_s <= 0.9:
            yield (
                s,
                s + saturate_shift,
                s + 2 * saturate_shift,
                s + 3 * saturate_shift,
                end_s,
            )


def getHAnalog():
    hue_shift = 1 / (hue_count * 5)
    step = 1 / hue_count
    for i in range(hue_count + 1):
        h = i * step
        end_h = h + 4 * hue_shift
        if end_h <= 1:
            yield (
                h,
                h + hue_shift,
                h + 2 * hue_shift,
                h + 3 * hue_shift,
                end_h,
            )
            yield (
                end_h,
                h + 3 * hue_shift,
                h + 2 * hue_shift,
                h + hue_shift,
                h,
            )


def getHTriad():
    hue_shift = 1 / 3
    step = hue_shift / hue_count
    for i in range(hue_count + 1):
        h = i * step
        end_h = h + 4 * hue_shift
        if end_h <= 1:
            yield (
                h,
                h + hue_shift,
                h + 2 * hue_shift,
                h + 3 * hue_shift,
                end_h,
            )
            yield (
                end_h,
                h + 3 * hue_shift,
                h + 2 * hue_shift,
                h + hue_shift,
                h,
            )


def getHSVRange():
    all_range = []
    unique_set = set()
    for ih_range in H_range:
        for is_range in S_range:
            for iv_range in V_range:
                item = (
                    (ih_range[0], is_range[0], iv_range[0]),
                    (ih_range[1], is_range[1], iv_range[1]),
                    (ih_range[2], is_range[2], iv_range[2]),
                    (ih_range[3], is_range[3], iv_range[3]),
                )
                if item in unique_set:
                    continue
                unique_set.add(item)
                colors = []
                for h, s, v in zip(ih_range, is_range, iv_range):
                    r, g, b = colorsys.hsv_to_rgb(h, s, v)
                    h, l, s = colorsys.rgb_to_hls(r, g, b)
                    colors.append(
                        Color(
                            hue=h,
                            luminance=l,
                            saturation=s,
                        )
                    )
                all_range.append(colors)
    return all_range


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
    for i, value in enumerate(segment):
        color_lists.append([colors[i], colors[i + 1], value])
        # if i < len(segment) - 1:
        #     color_lists.append([colors[i], colors[i + 1], value])
        # else:
        #     color_lists.append([colors[-1], colors[0], value])
    return color_lists


# H_range = list(getHAnalog())
H_range = list(getHTriad())
S_range = list(getSRanges())
V_range = list(getVRanges())
print(len(H_range), len(S_range), len(V_range))
palette_generated = getHSVRange()

print("total palette", len(palette_generated))
print("total image", len(palette_generated) / total_row)
# base = Image.new("RGB", (base_size, base_size), (0, 0, 0))
# i_image = 0
# for palette in palette_generated:
#     gradient_range = generateColorGradientRange(palette)
#     image = getGradientImage(gradient_range)
#     row = i_image % total_row
#     for offset in range(row_pixel):
#         base.paste(image, (0, row * row_pixel + offset))
#     if row >= total_row - 1:
#         save_name = f"{output_dir}/gradient_map{int(i_image / total_row)}.png"
#         print(save_name)
#         base.save(save_name)
#         base.close()
#         base = Image.new("RGB", (base_size, base_size), (0, 0, 0))
#     image.close()
#     i_image += 1
# if len(palette_generated) % total_row > 0:
#     save_name = f"{output_dir}/gradient_map{int(i_image / total_row)}.png"
#     print(save_name)
#     base.save(save_name)
