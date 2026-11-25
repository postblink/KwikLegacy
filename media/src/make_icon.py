#!/usr/bin/env python3
"""Generate the KwikLegacy brand mark (media/kwiklegacy-icon.svg).

A faceted gold shield (legacy) holding a parchment dial whose gold ring is the
progress toward the next unlock; the unfinished part of the ring is dotted, echoing
the KwikWays route line. The star at the centre is the unlock itself. Palette and
outline weight follow the KwikWays compass icon.
"""
import math
import pathlib

GOLD_LIGHT = '#F7C84F'
GOLD_DARK = '#D99A32'
INK = '#171719'
PARCHMENT = '#F3E9D2'
PARCHMENT_SHADE = '#D2BE94'
BG = '#12141A'

SIZE = 1024
CX, CY = 512, 518
PROGRESS = 0.78


def polar(r, deg, cx=CX, cy=CY):
    a = math.radians(deg - 90)  # 0 degrees = 12 o'clock, clockwise
    return cx + r * math.cos(a), cy + r * math.sin(a)


def fmt(points):
    return ' '.join(f'{x:.1f},{y:.1f}' for x, y in points)


def arc(r, start, end):
    x1, y1 = polar(r, start)
    x2, y2 = polar(r, end)
    large = 1 if (end - start) % 360 > 180 else 0
    return f'M{x1:.1f},{y1:.1f} A{r},{r} 0 {large} 1 {x2:.1f},{y2:.1f}'


def star(r_tip, r_inner, cx=CX, cy=CY):
    """Four-point star split into light/dark facets, like the KwikWays compass rose."""
    parts = []
    for i in range(4):
        tip = polar(r_tip, i * 90, cx, cy)
        left = polar(r_inner, i * 90 - 45, cx, cy)
        right = polar(r_inner, i * 90 + 45, cx, cy)
        parts.append(f'<polygon points="{fmt([(cx, cy), left, tip])}" fill="{GOLD_LIGHT}"/>')
        parts.append(f'<polygon points="{fmt([(cx, cy), tip, right])}" fill="{GOLD_DARK}"/>')
    outline = []
    for i in range(4):
        outline += [polar(r_tip, i * 90, cx, cy), polar(r_inner, i * 90 + 45, cx, cy)]
    parts.append(f'<polygon points="{fmt(outline)}" fill="none" stroke="{INK}" stroke-width="12" stroke-linejoin="round"/>')
    return '\n    '.join(parts)


SHIELD = 'M222,196 Q512,140 802,196 L802,520 C802,724 650,838 512,902 C374,838 222,724 222,520 Z'
INNER_SHIELD = 'M262,232 Q512,186 762,232 L762,520 C762,700 630,800 512,856 C394,800 262,700 262,520 Z'

ring_r, ring_w = 152, 34
end_deg = 360 * PROGRESS
dots = []
n = 5
start_dots, stop_dots = end_deg + 17, 360 - 13  # clear of the endpoint marker and the start cap
for i in range(n):
    deg = start_dots + (stop_dots - start_dots) * i / (n - 1)
    x, y = polar(ring_r, deg)
    dots.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="7.5" fill="{GOLD_DARK}" stroke="{INK}" stroke-width="4"/>')
tip_x, tip_y = polar(ring_r, end_deg)

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {SIZE} {SIZE}" width="{SIZE}" height="{SIZE}">
  <title>KwikLegacy</title>
  <defs>
    <filter id="grain" x="0" y="0" width="100%" height="100%">
      <feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves="2" seed="7" result="noise"/>
      <feColorMatrix in="noise" type="matrix" values="0 0 0 0 0.30  0 0 0 0 0.34  0 0 0 0 0.40  0 0 0 0.22 0"/>
      <feComposite in2="SourceGraphic" operator="in"/>
    </filter>
    <radialGradient id="vignette" cx="50%" cy="46%" r="70%">
      <stop offset="0%" stop-color="#1E2230"/>
      <stop offset="100%" stop-color="{BG}"/>
    </radialGradient>
    <clipPath id="shield"><path d="{SHIELD}"/></clipPath>
  </defs>
  <rect width="{SIZE}" height="{SIZE}" fill="url(#vignette)"/>
  <rect width="{SIZE}" height="{SIZE}" fill="#000" filter="url(#grain)"/>
  <g>
    <path d="{SHIELD}" fill="{GOLD_DARK}"/>
    <rect x="0" y="0" width="{CX}" height="{SIZE}" fill="{GOLD_LIGHT}" clip-path="url(#shield)"/>
    <path d="{INNER_SHIELD}" fill="none" stroke="{INK}" stroke-width="8" stroke-opacity="0.55"/>
    <path d="{SHIELD}" fill="none" stroke="{INK}" stroke-width="22" stroke-linejoin="round"/>
  </g>
  <circle cx="{CX}" cy="{CY}" r="212" fill="{PARCHMENT}" stroke="{INK}" stroke-width="18"/>
  <circle cx="{CX}" cy="{CY}" r="{ring_r}" fill="none" stroke="{PARCHMENT_SHADE}" stroke-width="{ring_w}"/>
  <path d="{arc(ring_r, 0, end_deg)}" fill="none" stroke="{INK}" stroke-width="{ring_w + 12}" stroke-linecap="round"/>
  <path d="{arc(ring_r, 0, end_deg)}" fill="none" stroke="{GOLD_DARK}" stroke-width="{ring_w}" stroke-linecap="round"/>
  <path d="{arc(ring_r + 8, 4, end_deg - 4)}" fill="none" stroke="{GOLD_LIGHT}" stroke-width="10" stroke-linecap="round"/>
  {''.join(dots)}
  <circle cx="{tip_x:.1f}" cy="{tip_y:.1f}" r="15" fill="{GOLD_LIGHT}" stroke="{INK}" stroke-width="7"/>
  <g>
    {star(108, 30)}
  </g>
</svg>
'''

media = pathlib.Path(__file__).resolve().parent.parent
icon = media / 'kwiklegacy-icon.svg'
icon.write_text(svg)
# Transparent mark for layouts that supply their own background (banner, docs).
background = [line for line in svg.splitlines() if line.strip().startswith('<rect width="1024"')]
assert len(background) == 2, 'background rects changed; update the mark export'
mark = media / 'kwiklegacy-mark.svg'
mark.write_text('\n'.join(line for line in svg.splitlines() if line not in background) + '\n')
print(icon)
print(mark)
