from __future__ import division

from collections import namedtuple
from PIL import Image
import matplotlib.pyplot as plt
import numpy as np
import os
from config import frame_rows, frame_cols, get_px_ndx, source_pairs, window_spacing, frame_size


def parse_and_show(stdout, image_dir):
    Displacements = namedtuple('Displacements', ['u', 'v'])
    results = [int(line[1:]) for line in stdout.split('\n') if len(line) > 0 and line[0] == '$']
    results = [(results[i], Displacements(*results[i+1:i+3])) for i in range(0, len(results), 3)]
    disp_map = dict(results)
    V = np.zeros([frame_rows, frame_cols])
    U = np.zeros([frame_rows, frame_cols])
    for frame_row in range(frame_rows):
        for frame_col in range(frame_cols):
            pixel_ndx = get_px_ndx(frame_row, frame_col)
            U[frame_row][frame_col] = disp_map[pixel_ndx].u - 4
            V[frame_row][frame_col] = disp_map[pixel_ndx].v - 4
    imageA = Image.open(os.path.join(image_dir, source_pairs[0][0]))
    f = plt.figure()
    a = f.add_axes([.1, .1, .8, .8])
    a.imshow(imageA.transpose(Image.FLIP_TOP_BOTTOM))
    a.hold(True)
    X = np.array(range(frame_cols)) * window_spacing + frame_size / 2
    Y = np.array(range(frame_rows)) * window_spacing + frame_size / 2
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
