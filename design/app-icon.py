"""Gym Tross app icon.

An albatross knocked out of a hexagonal weight plate, on a dark field.

The name is the mark: Gym Tross comes from albatross, so the bird carries the
brand where a dumbbell would only say "gym" - a silhouette every other fitness
icon in the store already owns. The hex plate keeps the gym read and gives the
mark a solid outer shape, which is what actually survives at 40px in a Settings
row; the bird inside is negative space, so it costs no contrast.

Geometry tuned small:
  - Wing tips keep a 26px chord. Tapering them to a true point looked better at
    1024px and vanished by 60px.
  - The body is one rounded slab plus a tail wedge. A separately drawn neck
    turned to mud small, so the head is a circle that overlaps the slab.
  - The hexagon is stroked with joint="curve" over a closed point list. The
    first vertex needs the second point repeated or the top corner grows a nib.

Palette is monochrome by choice: near-white plate on a charcoal gradient
(#2A2D32 -> #0C0D0F). No brand amber - on a home screen the dark field reads as
depth, and colour here fought every wallpaper it landed on.

Everything is drawn 4x and downsampled, so curves and corners stay clean.

Run from the repo root:  python3 design/app-icon.py
"""
import math

from PIL import Image, ImageDraw

S = 1024
SS = 4          # supersample factor
N = S * SS

BG_TOP = (42, 45, 50)
BG_BOTTOM = (12, 13, 15)
PLATE = (248, 249, 250)

HEX_R = 344     # circumradius of the plate
HEX_ROUND = 30  # corner radius


def background():
    img = Image.new("RGB", (N, N))
    d = ImageDraw.Draw(img)
    for y in range(N):
        t = y / (N - 1)
        d.line(
            [(0, y), (N, y)],
            fill=tuple(round(BG_TOP[i] + (BG_BOTTOM[i] - BG_TOP[i]) * t) for i in range(3)),
        )
    return img


def hexagon(d, c, R, r, fill):
    pts = [
        ((c + (R - r) * math.cos(math.radians(-90 + a))) * SS,
         (c + (R - r) * math.sin(math.radians(-90 + a))) * SS)
        for a in range(0, 360, 60)
    ]
    d.polygon(pts, fill=fill)
    d.line(pts + [pts[0], pts[1]], fill=fill, width=int(2 * r * SS), joint="curve")


def wing(cx, cy, sx, span, rise, root_chord, tip_chord):
    """One swept wing, as a polygon: leading edge rises, chord tapers outward."""
    lead, trail = [], []
    for i in range(41):
        t = i / 40
        x = cx + sx * (18 + span * t)
        y = cy - rise * (t ** 1.25)
        ch = root_chord * (1 - t) + tip_chord * t
        lead.append((x, y - ch * 0.42))
        trail.append((x, y + ch * 0.58))
    return [(x * SS, y * SS) for x, y in lead + trail[::-1]]


def albatross(md, cx, cy):
    for sx in (-1, 1):
        md.polygon(wing(cx, cy, sx, span=254, rise=130, root_chord=92, tip_chord=26), fill=255)
    md.rounded_rectangle(
        [(cx - 36) * SS, (cy - 82) * SS, (cx + 36) * SS, (cy + 100) * SS], radius=34 * SS, fill=255
    )
    md.polygon(
        [((cx - 42) * SS, (cy + 60) * SS), ((cx + 42) * SS, (cy + 60) * SS), (cx * SS, (cy + 138) * SS)],
        fill=255,
    )
    md.ellipse([(cx - 30) * SS, (cy - 142) * SS, (cx + 30) * SS, (cy - 82) * SS], fill=255)
    md.polygon(
        [((cx - 6) * SS, (cy - 134) * SS), ((cx - 6) * SS, (cy - 108) * SS), ((cx - 118) * SS, (cy - 116) * SS)],
        fill=255,
    )


def build():
    img = background()
    hexagon(ImageDraw.Draw(img), S / 2, HEX_R, HEX_ROUND, PLATE)

    cut = Image.new("L", (N, N), 0)
    albatross(ImageDraw.Draw(cut), S / 2, S / 2 + 38)
    img.paste(background(), (0, 0), cut)

    return img.resize((S, S), Image.LANCZOS)


if __name__ == "__main__":
    icon = build()
    icon.save("design/app-icon-1024.png")

    strip = Image.new("RGB", (700, 300), (238, 238, 240))
    strip.paste(icon.resize((260, 260), Image.LANCZOS), (10, 20))
    x = 300
    for px in (120, 80, 60, 40):
        strip.paste(icon.resize((px, px), Image.LANCZOS), (x, 20))
        x += px + 16
    strip.save("/tmp/icon_dark_strip.png")
    print("written")
