from __future__ import division

import Image
from display import parse_and_show
import subprocess
import time
import cPickle as pickle
import os
from config import frame_cols, frame_rows, get_px_ndx

image_dir = '../../data/vort_sim/'
source_pairs = [('single_vort_sim_0001.tif', 'single_vort_sim_0002.tif')]

os.system('killall bluectl')
bsim_proc = subprocess.Popen(['./bsim_dut'], cwd='../scemi/sim')
time.sleep(1)
tb_proc = subprocess.Popen(['./tb'],stdin=subprocess.PIPE, stdout=subprocess.PIPE, cwd='../scemi/sim')

for pair in source_pairs:
    imageA = Image.open(os.path.join(image_dir, pair[0])).convert("L")
    imageB = Image.open(os.path.join(image_dir, pair[1])).convert("L")
    for im in [imageA, imageB]:
        for pix in im.getdata():
            tb_proc.stdin.write(str(pix) + '\n')
        tb_proc.stdin.write('.\n')

    for frame_row in range(frame_rows):
        for frame_col in range(frame_cols):
            pixel_ndx = get_px_ndx(frame_row, frame_col)
            tb_proc.stdin.write(str(pixel_ndx) + '\n')
    stdout, stderr = tb_proc.communicate('.\n')
    pickle.dump(stdout, open('stdout.pck', 'wb'))
    parse_and_show(stdout)
