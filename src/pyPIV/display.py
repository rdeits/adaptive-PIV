from __future__ import division

from PIL import Image
import matplotlib.pyplot as plt
import numpy as np
import os
from config import frame_rows, frame_cols, get_px_ndx, get_image_pair, window_spacing, frame_size
from collections import namedtuple
Displacements = namedtuple('Displacements', ['u', 'v'])

def displacement_field(stdout, image_dir, adaptive=False):
    results = [int(line[1:]) for line in stdout.split('\n') if len(line) > 0 and line[0] == '$']
    results = [(results[i], Displacements(*results[i+1:i+3])) for i in range(0, len(results), 3)]
    disp_map = dict(results)
    im_pair = get_image_pair(image_dir)

    if not adaptive:
        num_rows = frame_rows(im_pair.A)
        num_cols = frame_cols(im_pair.A)
        V = np.zeros([num_rows, num_cols])
        U = np.zeros([num_rows, num_cols])
        for frame_row in range(num_rows):
            for frame_col in range(num_cols):
                pixel_ndx = get_px_ndx(im_pair.A, frame_row, frame_col)
                U[frame_row][frame_col] = disp_map[pixel_ndx].u - 4
                V[frame_row][frame_col] = disp_map[pixel_ndx].v - 4
        X = np.array(range(num_cols)) * window_spacing + frame_size / 2
        Y = np.array(range(num_rows)) * window_spacing + frame_size / 2
    else:
        ndxs = np.array(disp_map.keys())
        U = np.array([disp_map[k].u for k in disp_map])
        V = np.array([disp_map[k].v for k in disp_map])
        X = ndxs % im_pair.A.size[0]
        Y = ndxs // im_pair.A.size[0]

    return X, Y, U, V



def parse_and_show(stdout, image_dir, adaptive):
    im_pair = get_image_pair(image_dir)
    X, Y, U, V = displacement_field(stdout, image_dir, adaptive)
    f = plt.figure()
    a = f.add_axes([.1, .1, .8, .8])
    a.imshow(im_pair.A.transpose(Image.FLIP_TOP_BOTTOM))
    a.hold(True)
    a.quiver(X, Y, U, V, color='y', units='x')
    # a.invert_yaxis()
    plt.savefig(os.path.join(image_dir, 'PIV.png'))
    plt.show()

if __name__ == '__main__':
    import pickle
    import sys
    image_dir = sys.argv[1]

    stdout = pickle.load(open(os.path.join(image_dir, 'stdout.pck'), 'rb'))
    parse_and_show(stdout, image_dir)
