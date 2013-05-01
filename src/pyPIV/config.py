import os

test_crop = [0, 0, 40, 40]

window_spacing = 8
im_width = 800
im_height = 600
frame_size = 40
frame_cols = (im_width - frame_size) // window_spacing + 1
frame_rows = (im_height - frame_size) // window_spacing + 1

source_pairs = [('A.png', 'B.png')]
# image_dir = '../../data/vort_sim/'
# source_pairs = [('single_vort_sim_0001.tif', 'single_vort_sim_0002.tif')]

def get_px_ndx(frame_row, frame_col):
    return frame_row * im_width * window_spacing + frame_col * window_spacing
