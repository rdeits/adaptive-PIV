from __future__ import division

import Image
import ImageOps

source_files = ['../../data/vort_sim/single_vort_sim_0001.tif', '../../data/vort_sim/single_vort_sim_0002.tif']

for source_file in source_files:
    dest_file = source_file.replace('.tif', '.txt')
    with open(dest_file, 'w') as f:
        original = Image.open(source_file)
        bit_8 = original.convert("L")
        bit_4 = ImageOps.posterize(bit_8, 4)
        for pix in bit_4.getdata():
            f.write(str(pix)+'\n')
