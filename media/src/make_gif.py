#!/usr/bin/env python3
"""Build media/kwiklegacy-demo.gif from the four simulator panel frames.

usage: make_gif.py <frame0.png> <frame1.png> <frame2.png> <frame3.png>
Frames are the 2x panel crops rendered by src/showcase (main, f2, f3, f4).
"""
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = pathlib.Path(__file__).resolve().parent
OUT = HERE.parent / 'kwiklegacy-demo.gif'
CAPTIONS = [
    'Your closest unlocks, ranked',
    'Tailoring 288 \u2192 296: Artisan Tailor takes the lead',
    'Shadowfang Keep cleared: Novice Spelunker is done',
    'Gnomeregan cleared: Experienced Spelunker climbs',
]
DURATIONS = [2200, 2200, 2200, 3000]
BAR = 64
INK, TEXT = (18, 20, 26), (243, 233, 210)

font = ImageFont.truetype(str(HERE / 'fonts' / 'AlegreyaSans-Medium.ttf'), 26)
frames = []
for path, caption in zip(sys.argv[1:5], CAPTIONS):
    shot = Image.open(path).convert('RGB')
    canvas = Image.new('RGB', (shot.width, shot.height + BAR), INK)
    canvas.paste(shot, (0, 0))
    draw = ImageDraw.Draw(canvas)
    width = draw.textlength(caption, font=font)
    draw.text(((shot.width - width) / 2, shot.height + (BAR - 26) / 2 - 3), caption, font=font, fill=TEXT)
    frames.append(canvas.quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE))
frames[0].save(OUT, save_all=True, append_images=frames[1:], duration=DURATIONS, loop=0, optimize=True, disposal=1)
print(OUT, OUT.stat().st_size)
