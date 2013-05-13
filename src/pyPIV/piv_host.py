from __future__ import division

from display import parse_and_show
import subprocess
import time
import cPickle as pickle
import os
import sys
from config import frame_cols, frame_rows, get_px_ndx, get_image_pair
import sys; sys.stdout = open('log', 'w')

image_dir = sys.argv[1]
use_fpga = int(sys.argv[2])

os.system('killall bluetcl')
if use_fpga:
    tb_proc = subprocess.Popen(['runtb', './tb'],stdin=subprocess.PIPE, stdout=subprocess.PIPE, cwd='../scemi/fpga')
else:
    bsim_proc = subprocess.Popen(['./bsim_dut'], cwd='../scemi/sim')
    time.sleep(1)
    tb_proc = subprocess.Popen(['./tb'],stdin=subprocess.PIPE, stdout=subprocess.PIPE, cwd='../scemi/sim')

im_pair = get_image_pair(image_dir)
bspec_im_width = int(subprocess.check_output('cat ../bspec/PIVTypes.bsv | grep "ImageWidth;"', shell=True).split(' ')[1])

if bspec_im_width != im_pair.A.size[0]:
    print >> sys.stderr, "WARNING: Image width doesn't match parameters used when compling bspec file. Press Enter to continue anyway."
    raw_input()

for im in im_pair:
    for pix in im.convert('L').getdata():
        tb_proc.stdin.write(str(pix) + '\n')
        # print pix
    tb_proc.stdin.write('.\n')
    print '.'

start = time.time()
for frame_row in range(frame_rows(im_pair.A)):
    for frame_col in range(frame_cols(im_pair.A)):
        pixel_ndx = get_px_ndx(im_pair.A, frame_row, frame_col)
        tb_proc.stdin.write(str(pixel_ndx) + '\n')
stdout, stderr = tb_proc.communicate('.\n')
print >> sys.stderr, "Elapsed time =",  time.time() - start
pickle.dump(stdout, open(os.path.join(image_dir, 'stdout.pck'), 'wb'))
parse_and_show(stdout, image_dir)
