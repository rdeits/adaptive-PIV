from __future__ import division

import Image
import subprocess
import time
import os

image_dir = '../../data/vort_sim/'
source_pairs = [('single_vort_sim_0001.tif', 'single_vort_sim_0001.tif')]

os.system('killall bluectl')
bsim_proc = subprocess.Popen(['./bsim_dut'], cwd='../scemi/sim')
time.sleep(1)
tb_proc = subprocess.Popen(['./tb'],stdin=subprocess.PIPE, stdout=subprocess.PIPE, cwd='../scemi/sim')
# while True:
#     data = tb_proc.stdout.read()
#     if len(data) == 0:
#         break
#     print data

for pair in source_pairs:
    imageA = Image.open(os.path.join(image_dir, pair[0])).convert("L").crop([0, 0, 40, 40])
    imageB = Image.open(os.path.join(image_dir, pair[1])).convert("L").crop([1, 1, 41, 41])
    for pix in imageA.getdata():
        tb_proc.stdin.write(str(pix) + '\n')
    tb_proc.stdin.write('.\n')
    # while True:
    #     data = tb_proc.stdout.read()
    #     if len(data) == 0:
    #         break
    #     print data
    for pix in imageB.getdata():
        tb_proc.stdin.write(str(pix) + '\n')
    tb_proc.stdin.write('.\n')

    # while True:
    #     data = tb_proc.stdout.read()
    #     if len(data) == 0:
    #         break
    #     print data
    # print tb_proc.communicate('0\n.\n')
    tb_proc.stdin.write('0\n.\n')
    while True:
        data = tb_proc.stdout.read()
        if data != '':
            print data
        else:
            break

