"""Gym Tross app icon.

Amber mark on the app's dark surface. Flat geometry, no gradient, no glow.

The shape was chosen by testing it small: a simpler two-plate version looked
better at 1024px and read as the letter H at 40px, which is the size it has in
a Settings list. The stepped outer plates are what keep the silhouette a
dumbbell, so the extra detail earns its place.
"""
from PIL import Image, ImageDraw

S = 1024
AMBER = (224, 98, 26)   # Brand.seed from lib/app/brand.dart
DARK = (26, 18, 14)     # ColorScheme.fromSeed(seed, dark).surface


def rr(d, box, r):
    d.rounded_rectangle(box, radius=r, fill=AMBER)


def build():
    img = Image.new("RGB", (S, S), DARK)
    d = ImageDraw.Draw(img)
    cy = S // 2

    BAR_H, BAR_W = 92, 430
    rr(d, (S / 2 - BAR_W / 2, cy - BAR_H / 2, S / 2 + BAR_W / 2, cy + BAR_H / 2), BAR_H / 2)

    PL_W, PL_H = 116, 408
    for sx in (-1, 1):
        x = S / 2 + sx * (BAR_W / 2 + PL_W / 2 - 46)
        rr(d, (x - PL_W / 2, cy - PL_H / 2, x + PL_W / 2, cy + PL_H / 2), 36)

    PO_W, PO_H = 88, 232
    for sx in (-1, 1):
        x = S / 2 + sx * (BAR_W / 2 + PL_W + 4)
        rr(d, (x - PO_W / 2, cy - PO_H / 2, x + PO_W / 2, cy + PO_H / 2), 26)
    return img


if __name__ == "__main__":
    icon = build()
    icon.save("design/app-icon-1024.png")

    strip = Image.new("RGB", (700, 300), (245, 245, 245))
    strip.paste(icon.resize((260, 260), Image.LANCZOS), (10, 20))
    x = 300
    for px in (120, 80, 60, 40):
        strip.paste(icon.resize((px, px), Image.LANCZOS), (x, 20))
        x += px + 16
    strip.save("/tmp/icon_dark_strip.png")
    print("written")
