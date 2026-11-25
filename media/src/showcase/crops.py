#!/usr/bin/env python3
"""Crop the 2x showcase renders into media/screenshots and rebuild the demo GIF.

usage: crops.py <render-dir> <media-dir>
At --width 3200 --height 1800 --ui-scale 2 one UI unit is two pixels. The fixture
anchors LegacySystemFrame at (40, 60) units; KwikLegacy docks its 284-unit panel at
(1013, 60) with a height of 52 + 64 per row.
"""
import pathlib
import subprocess
import sys

from PIL import Image

render, media = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
shots = media / 'screenshots'
shots.mkdir(parents=True, exist_ok=True)
PANEL_5 = (2010, 104, 2610, 880)


def crop(name, box, dest, width=None):
    image = Image.open(render / f'hd_{name}.png').convert('RGB').crop(box)
    if width and image.width > width:
        image = image.resize((width, round(image.height * width / image.width)), Image.LANCZOS)
    image.save(dest, optimize=True)
    print(dest, image.size)


crop('main', PANEL_5, shots / 'panel.png')
crop('more', (2010, 104, 2610, 1264), shots / 'earned-elsewhere.png')
crop('tooltip', (2010, 104, 2962, 1028), shots / 'tooltip.png')
crop('main', (56, 96, 2618, 1294), shots / 'overview.png', width=1800)
frames = []
for i, name in enumerate(('main', 'f2', 'f3', 'f4')):
    path = render / f'gif_f{i}.png'
    Image.open(render / f'hd_{name}.png').convert('RGB').crop(PANEL_5).save(path)
    frames.append(str(path))
subprocess.run([sys.executable, str(pathlib.Path(__file__).resolve().parent.parent / 'make_gif.py'), *frames], check=True)
