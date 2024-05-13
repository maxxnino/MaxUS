import os
import shutil
import math
input_dir = "input"
output_dir = "input"
input_files = os.listdir(input_dir)
# A: Stone, Brick
# B: Ceramics, Marble
# C: Wood
# D: Conceare
# E: Metal
# F: Cotton, Wool, Nylon, Plastic
# G: Glass
udim = {
    "NormalColor": [],
    "ORM": [],
}
for file in input_files:
    for k in udim:
        if k in file:
            udim[k].append(f"{input_dir}/{file}")
        
for k in udim:
    u = 1
    v = 0
    total = len(udim[k])
    max_size = int(math.sqrt(total)) + 1
    for item in udim[k]:
        shutil.move(item, f"{output_dir}/{k}.10{v}{u}.png")
        u += 1
        if u == max_size:
            u = 1
            v += 1

