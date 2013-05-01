import os
from PIL import Image
from collections import namedtuple
ImPair = namedtuple('ImPair', ['A', 'B'])

test_crop = [0, 0, 40, 40]
window_spacing = 8
frame_size = 40

def frame_cols(im):
    im_width, im_height = im.size()
    return (im_width - frame_size) // window_spacing + 1

def frame_rows(im):
    im_width, im_height = im.size()
    return (im_height - frame_size) // window_spacing + 1


def get_px_ndx(im, frame_row, frame_col):
    im_width, im_height = im.size()
    return frame_row * im_width * window_spacing + frame_col * window_spacing

def get_image_pair(image_dir):
    for extension in ['.png', '.tif']:
        fnameA = os.path.join(image_dir, 'A' + extension)
        fnameB = os.path.join(image_dir, 'B' + extension)
        if os.path.exists(fnameA) and os.path.exists(fnameB):
            break
    else:
        raise IOError("no image files found")

    imageA = Image.open(fnameA).convert("L")
    imageB = Image.open(fnameB).convert("L")
    return ImPair(imageA, imageB)
