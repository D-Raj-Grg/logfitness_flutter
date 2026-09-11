from PIL import Image, ImageDraw

S = 1024
AMBER = (224, 98, 26)   # Brand.seed from lib/app/brand.dart
DARK  = (26, 17, 13)    # the app's own surface, so icon and app agree

def rr(d, box, r, fill):
    d.rounded_rectangle(box, radius=r, fill=fill)

def build():
    img = Image.new("RGB", (S, S), AMBER)
    d = ImageDraw.Draw(img)
    cy = S // 2

    BAR_H, BAR_W = 92, 430
    rr(d, (S/2 - BAR_W/2, cy - BAR_H/2, S/2 + BAR_W/2, cy + BAR_H/2), BAR_H/2, DARK)

    # Inner plates: the tall pair.
    PL_W, PL_H = 116, 408
    for sx in (-1, 1):
        x = S/2 + sx * (BAR_W/2 + PL_W/2 - 46)
        rr(d, (x - PL_W/2, cy - PL_H/2, x + PL_W/2, cy + PL_H/2), 36, DARK)

    # Outer plates: shorter, and held clear of the inner pair. The step is what
    # stops the mark reading as a letter H once it is 40px wide -- a simpler
    # two-plate version tested as exactly that.
    PO_W, PO_H = 88, 232
    for sx in (-1, 1):
        x = S/2 + sx * (BAR_W/2 + PL_W + 4)
        rr(d, (x - PO_W/2, cy - PO_H/2, x + PO_W/2, cy + PO_H/2), 26, DARK)
    return img

icon = build()
icon.save("/tmp/icon_final_1024.png")

strip = Image.new("RGB", (700, 300), (245,245,245))
strip.paste(icon.resize((260,260), Image.LANCZOS), (10, 20))
x = 300
for px in (120, 80, 60, 40):
    strip.paste(icon.resize((px, px), Image.LANCZOS), (x, 20))
    x += px + 16
strip.save("/tmp/icon_final_strip.png")
print("final written")
