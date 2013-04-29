from __future__ import division

from collections import namedtuple
import matplotlib.pyplot as plt
import numpy as np
from config import frame_rows, frame_cols, get_px_ndx

def parse_and_show(stdout):
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
    plt.quiver(U, V)
    plt.show()

if __name__ == '__main__':
    import pickle
    stdout = pickle.load(open('stdout.pck', 'rb'))
    parse_and_show(stdout)
