"""Flat illustrations for each scene, drawn with Pillow at 2x and downsampled.

Each scene returns a list of layers: (image, (cx, cy), anim, delay).
cx/cy are the layer centre on the 1080x1920 frame, anim is one of
'pop' (pop in, gentle bob), 'float' (pop in, larger drift), 'twinkle' (pop in, pulse),
'wobble' (pop in, small rotation).
"""
import math
from PIL import Image, ImageDraw, ImageFilter, ImageChops, ImageFont

NAVY = (44, 74, 92, 255)
WHITE = (255, 255, 255, 255)
SHADE = (214, 236, 246, 255)
PINK = (255, 170, 182, 255)
CORAL = (255, 111, 125, 255)
TEAL = (52, 184, 168, 255)
TEAL_D = (34, 140, 130, 255)
YELLOW = (255, 214, 92, 255)
SKY = (150, 214, 245, 255)
GREEN = (120, 200, 120, 255)
BROWN = (160, 110, 70, 255)
LAV = (160, 150, 240, 255)
OW = 14  # outline width at 2x

FONT = None


def set_font(path):
    global FONT
    FONT = path


def _f(size):
    return ImageFont.truetype(FONT, size)


def smooth(mask, r=4):
    return mask.filter(ImageFilter.GaussianBlur(r)).point(lambda v: 255 if v > 127 else 0)


def dilate(mask, w):
    return mask.filter(ImageFilter.GaussianBlur(w / 2)).point(lambda v: 255 if v > 10 else 0)


def solid(size, color):
    return Image.new("RGBA", size, color)


def stamp(canvas, mask, fill, outline=NAVY, ow=OW, shade=None):
    """Composite a filled shape with an outline (and optional inner shade) onto canvas."""
    if outline is not None:
        canvas.paste(solid(canvas.size, outline), (0, 0), smooth(dilate(mask, ow), 2))
    canvas.paste(solid(canvas.size, fill), (0, 0), mask)
    if shade is not None:
        col, dx, dy = shade
        shifted = ImageChops.offset(mask, dx, dy)
        crescent = ImageChops.subtract(mask, shifted)
        canvas.paste(solid(canvas.size, col), (0, 0), crescent)


def finish(img, scale=0.5):
    bbox = img.getbbox()
    img = img.crop(bbox) if bbox else img
    return img.resize((max(1, int(img.width * scale)), max(1, int(img.height * scale))), Image.LANCZOS)


# ---------------------------------------------------------------- tooth character
def tooth(S, eyes="normal", mouth="smile", brows=False, arms=None, blush=True):
    pad = int(S * 0.35)
    W, H = S + pad * 2, int(S * 1.1) + pad * 2
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ox, oy = pad, pad

    def box(a, b, c, d):
        return (ox + a * S, oy + b * S, ox + c * S, oy + d * S)

    # arms behind the body
    if arms:
        am = Image.new("L", (W, H), 0)
        ad = ImageDraw.Draw(am)
        if arms in ("wave", "hug"):
            ad.ellipse(box(-0.12, 0.42, 0.14, 0.62), 255)  # left arm resting
        if arms == "wave":
            ad.ellipse(box(0.84, 0.08, 1.06, 0.36), 255)  # right arm raised
        elif arms == "hug":
            ad.ellipse(box(0.86, 0.42, 1.12, 0.62), 255)
        stamp(img, smooth(am), WHITE)

    m = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(m)
    d.ellipse(box(0.04, 0.02, 0.58, 0.52), 255)
    d.ellipse(box(0.42, 0.02, 0.96, 0.52), 255)
    d.rounded_rectangle(box(0.04, 0.2, 0.96, 0.68), radius=int(0.18 * S), fill=255)
    d.ellipse(box(0.12, 0.45, 0.46, 1.04), 255)
    d.ellipse(box(0.54, 0.45, 0.88, 1.04), 255)
    d.rectangle(box(0.14, 0.5, 0.86, 0.74), 255)
    d.ellipse(box(0.40, 0.80, 0.60, 1.14), 0)
    m = smooth(m, 6)
    stamp(img, m, WHITE, shade=(SHADE, -int(S * 0.05), -int(S * 0.04)))

    g = ImageDraw.Draw(img)
    ey = 0.40
    for ex in (0.33, 0.67):
        if eyes == "happy":
            g.arc(box(ex - 0.07, ey - 0.04, ex + 0.07, ey + 0.08), 200, 340, fill=NAVY, width=int(S * 0.03))
        elif eyes == "wink" and ex > 0.5:
            g.arc(box(ex - 0.07, ey - 0.04, ex + 0.07, ey + 0.08), 200, 340, fill=NAVY, width=int(S * 0.03))
        else:
            g.ellipse(box(ex - 0.045, ey - 0.06, ex + 0.045, ey + 0.06), fill=NAVY)
            g.ellipse(box(ex - 0.02, ey - 0.04, ex + 0.01, ey - 0.005), fill=WHITE)
    if brows:
        w = int(S * 0.025)
        g.line([box(0.25, 0.27, 0, 0)[:2], box(0.39, 0.23, 0, 0)[:2]], fill=NAVY, width=w)
        g.line([box(0.61, 0.23, 0, 0)[:2], box(0.75, 0.27, 0, 0)[:2]], fill=NAVY, width=w)
    if blush:
        for ex in (0.2, 0.8):
            g.ellipse(box(ex - 0.07, 0.5, ex + 0.07, 0.57), fill=PINK)
    if mouth == "smile":
        g.pieslice(box(0.4, 0.44, 0.6, 0.6), 0, 180, fill=NAVY)
        g.chord(box(0.45, 0.53, 0.55, 0.61), 180, 360, fill=CORAL)
    elif mouth == "worried":
        pts = [box(0.40 + i * 0.04, 0.55 + (0.015 if i % 2 else -0.015), 0, 0)[:2] for i in range(6)]
        g.line(pts, fill=NAVY, width=int(S * 0.022), joint="curve")
    elif mouth == "grin":
        g.arc(box(0.41, 0.44, 0.59, 0.58), 20, 160, fill=NAVY, width=int(S * 0.025))
    return img


# ---------------------------------------------------------------- small props
def heart(S, color=CORAL):
    img = Image.new("RGBA", (S * 2, S * 2), (0, 0, 0, 0))
    m = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(m)
    o = S // 2
    d.ellipse((o, o, o + S * 0.55, o + S * 0.55), 255)
    d.ellipse((o + S * 0.45, o, o + S, o + S * 0.55), 255)
    d.polygon([(o + S * 0.04, o + S * 0.4), (o + S * 0.96, o + S * 0.4), (o + S * 0.5, o + S * 0.95)], 255)
    stamp(img, smooth(m, 4), color)
    ImageDraw.Draw(img).ellipse((o + S * 0.15, o + S * 0.14, o + S * 0.3, o + S * 0.26), fill=(255, 255, 255, 200))
    return img


def sparkle(S, color=YELLOW):
    img = Image.new("RGBA", (S * 2, S * 2), (0, 0, 0, 0))
    m = Image.new("L", img.size, 0)
    c = S
    r1, r2 = S * 0.5, S * 0.13
    pts = []
    for i in range(8):
        a = math.pi / 4 * i - math.pi / 2
        r = r1 if i % 2 == 0 else r2
        pts.append((c + r * math.cos(a), c + r * math.sin(a)))
    ImageDraw.Draw(m).polygon(pts, 255)
    stamp(img, smooth(m, 2), color, ow=10)
    return img


def drop(S, color=SKY):
    img = Image.new("RGBA", (S * 2, S * 2), (0, 0, 0, 0))
    m = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(m)
    o = S // 2
    d.ellipse((o, o + S * 0.35, o + S * 0.6, o + S * 0.95), 255)
    d.polygon([(o + S * 0.03, o + S * 0.6), (o + S * 0.57, o + S * 0.6), (o + S * 0.3, o)], 255)
    stamp(img, smooth(m, 3), color, ow=10)
    return img


def glyph(text, size, color=TEAL):
    img = Image.new("RGBA", (size * 3, size * 3), (0, 0, 0, 0))
    ImageDraw.Draw(img).text((size * 1.5, size * 1.5), text, font=_f(size), fill=color, anchor="mm",
                             stroke_width=max(6, size // 10), stroke_fill=NAVY)
    return img


def bubble(text, size, w, h, tail="left", fill=WHITE, fg=NAVY):
    img = Image.new("RGBA", (w + 120, h + 160), (0, 0, 0, 0))
    m = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle((60, 60, 60 + w, 60 + h), radius=h // 2, fill=255)
    bx = 60 + (w * 0.28 if tail == "left" else w * 0.72)
    d.polygon([(bx - 40, 40 + h), (bx + 40, 40 + h), (bx + (-50 if tail == "left" else 50), 140 + h)], 255)
    stamp(img, smooth(m, 3), fill)
    ImageDraw.Draw(img).text((60 + w / 2, 60 + h / 2), text, font=_f(size), fill=fg, anchor="mm")
    return img


def tree(S):
    img = Image.new("RGBA", (S * 2, int(S * 2.6)), (0, 0, 0, 0))
    o = S // 2
    tm = Image.new("L", img.size, 0)
    ImageDraw.Draw(tm).rounded_rectangle((o + S * 0.42, o + S * 0.7, o + S * 0.58, o + S * 1.5), radius=12, fill=255)
    stamp(img, tm, BROWN)
    lm = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(lm)
    d.ellipse((o, o + S * 0.15, o + S * 0.6, o + S * 0.8), 255)
    d.ellipse((o + S * 0.4, o + S * 0.15, o + S, o + S * 0.8), 255)
    d.ellipse((o + S * 0.18, o - S * 0.1, o + S * 0.82, o + S * 0.55), 255)
    stamp(img, smooth(lm, 4), GREEN, shade=((95, 170, 100, 255), -18, -14))
    return img


# ---------------------------------------------------------------- scene compositions
def clinic(S):
    W, H = int(S * 1.3), int(S * 1.25)
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    x0, x1 = S * 0.15, S * 1.15
    # body
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rectangle((x0, S * 0.32, x1, S * 1.1), 255)
    stamp(img, m, WHITE, shade=(SHADE, -20, 0))
    # roof
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((x0 - S * 0.06, S * 0.18, x1 + S * 0.06, S * 0.36), radius=24, fill=255)
    stamp(img, m, TEAL)
    # sign
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((S * 0.33, S * 0.02, S * 0.97, S * 0.2), radius=30, fill=255)
    stamp(img, m, YELLOW)
    t = finish(tooth(int(S * 0.12), eyes="happy", mouth="grin", blush=False), 1.0)
    img.alpha_composite(t, (int(S * 0.38), int(S * 0.11 - t.height / 2)))
    ImageDraw.Draw(img).text((S * 0.7, S * 0.11), "DENTAL", font=_f(int(S * 0.085)), fill=NAVY, anchor="mm")
    # windows
    for wx in (0.25, 0.75):
        m = Image.new("L", img.size, 0)
        ImageDraw.Draw(m).rounded_rectangle((S * wx, S * 0.46, S * (wx + 0.3), S * 0.72), radius=18, fill=255)
        stamp(img, m, SKY, ow=10, shade=((190, 232, 252, 255), 18, 18))
    # door
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((S * 0.52, S * 0.78, S * 0.78, S * 1.1), radius=16, fill=255)
    stamp(img, m, TEAL_D, ow=10)
    ImageDraw.Draw(img).ellipse((S * 0.73, S * 0.93, S * 0.76, S * 0.96), fill=YELLOW)
    # ground line
    ImageDraw.Draw(img).rounded_rectangle((0, S * 1.1 - 8, W, S * 1.1 + 8), radius=8, fill=NAVY)
    return img


def toothbrush(S):
    img = Image.new("RGBA", (int(S * 1.4), int(S * 0.5)), (0, 0, 0, 0))
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((S * 0.05, S * 0.26, S * 1.25, S * 0.4), radius=int(S * 0.07), fill=255)
    stamp(img, m, TEAL, shade=(TEAL_D, 0, -10))
    m = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(m)
    for i in range(6):
        x = S * (0.88 + i * 0.06)
        d.rounded_rectangle((x, S * 0.06, x + S * 0.045, S * 0.28), radius=10, fill=255)
    stamp(img, m, WHITE, ow=10, shade=(SKY, 0, 16))
    return img.rotate(28, expand=True, resample=Image.BICUBIC)


def block(S, color, kind):
    img = Image.new("RGBA", (S * 2, S * 2), (0, 0, 0, 0))
    o = S // 2
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((o, o, o + S, o + S), radius=int(S * 0.14), fill=255)
    stamp(img, m, color, shade=(tuple(int(c * 0.82) for c in color[:3]) + (255,), -16, -16))
    sym = {"star": "★", "heart": "♥", "circle": "●"}[kind]
    ImageDraw.Draw(img).text((o + S / 2, o + S / 2), sym, font=_f(int(S * 0.6)), fill=WHITE, anchor="mm")
    return img


def balloon(S, color=CORAL):
    img = Image.new("RGBA", (S * 2, int(S * 3)), (0, 0, 0, 0))
    o = S // 2
    d = ImageDraw.Draw(img)
    d.line([(o + S * 0.5, o + S * 1.15), (o + S * 0.42, o + S * 1.6), (o + S * 0.55, o + S * 2.1)], fill=NAVY, width=8, joint="curve")
    m = Image.new("L", img.size, 0)
    md = ImageDraw.Draw(m)
    md.ellipse((o, o, o + S, o + S * 1.15), 255)
    md.polygon([(o + S * 0.42, o + S * 1.1), (o + S * 0.58, o + S * 1.1), (o + S * 0.5, o + S * 1.2)], 255)
    stamp(img, smooth(m, 3), color, shade=(tuple(int(c * 0.85) for c in color[:3]) + (255,), -20, -16))
    ImageDraw.Draw(img).ellipse((o + S * 0.2, o + S * 0.18, o + S * 0.34, o + S * 0.42), fill=(255, 255, 255, 190))
    return img


def scene_layers(art):
    """Return animated layers for an illustrated scene, positions on the 1080x1920 frame."""
    L = []
    if art == "worried":
        L.append((finish(tooth(1100, eyes="normal", mouth="worried", brows=True)), (540, 840), "wobble", 0.0))
        L.append((finish(drop(260)), (870, 560), "float", 0.35))
        L.append((finish(glyph("？", 400, TEAL)), (190, 560), "twinkle", 0.25))
        L.append((finish(glyph("？", 260, YELLOW)), (930, 900), "twinkle", 0.45))
    elif art == "clinic":
        L.append((finish(tree(520)), (150, 960), "pop", 0.35))
        L.append((finish(tree(440)), (950, 990), "pop", 0.45))
        L.append((finish(clinic(1150)), (540, 830), "pop", 0.0))
        L.append((finish(sparkle(260)), (930, 520), "twinkle", 0.6))
    elif art == "gentle":
        L.append((finish(tooth(1000, eyes="happy", mouth="smile", arms="hug")), (540, 780), "pop", 0.0))
        L.append((finish(heart(460)), (540, 1060), "pop", 0.3))
        L.append((finish(heart(220, PINK)), (160, 580), "float", 0.5))
        L.append((finish(heart(170, CORAL)), (930, 640), "float", 0.65))
    elif art == "counseling":
        L.append((finish(tooth(860, eyes="normal", mouth="smile", arms="wave")), (560, 960), "pop", 0.0))
        L.append((finish(bubble("不安なこと…", 110, 840, 240, "right", fill=WHITE)), (330, 540), "pop", 0.35))
        L.append((finish(bubble("なんでも聞いてね！", 104, 1040, 240, "left", fill=(255, 236, 160, 255))), (700, 700), "pop", 0.75))
    elif art == "kids":
        L.append((finish(block(400, (120, 200, 250, 255), "star")), (230, 1050), "pop", 0.0))
        L.append((finish(block(400, (255, 190, 90, 255), "heart")), (450, 1050), "pop", 0.15))
        L.append((finish(block(400, (150, 220, 150, 255), "circle")), (340, 840), "pop", 0.3))
        L.append((finish(tooth(620, eyes="happy", mouth="smile", arms="wave")), (790, 930), "wobble", 0.45))
        L.append((finish(balloon(340, CORAL)), (880, 560), "float", 0.6))
        L.append((finish(balloon(280, LAV)), (190, 560), "float", 0.7))
    elif art == "prevent":
        L.append((finish(tooth(980, eyes="wink", mouth="smile")), (440, 860), "pop", 0.0))
        L.append((finish(toothbrush(900)), (810, 720), "wobble", 0.3))
        L.append((finish(sparkle(320)), (170, 580), "twinkle", 0.5))
        L.append((finish(sparkle(220)), (820, 1070), "twinkle", 0.6))
        L.append((finish(sparkle(180, WHITE)), (150, 1020), "twinkle", 0.7))
    elif art == "info":
        L.append((finish(tooth(640, eyes="happy", mouth="smile", arms="wave")), (540, 480), "wobble", 0.0))
        L.append((finish(sparkle(200)), (270, 360), "twinkle", 0.3))
        L.append((finish(sparkle(150)), (820, 330), "twinkle", 0.4))
    return L
