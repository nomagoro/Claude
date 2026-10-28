"""Render the dental clinic intro short (1080x1920).

Usage (from the dental-intro directory):
    python3 tools/render.py

Outputs
    dental_intro_preview.mp4      finished video (telops + BGM + sound effects)
    media/scenes/<id>.mp4         per-scene background clips without telops (for editing)
    media/telop/<id>.png          per-scene telops as transparent 1080x1920 PNG
    media/audio/bgm.wav, pop.wav  music and sound effect

Free stock footage: drop a file named after the scene id into media/stock/
(e.g. media/stock/s3_gentle.mp4 or s3_gentle.jpg) and that scene uses it instead
of the illustration. Any aspect ratio works; it is centre-cropped to 9:16.
"""
import json, math, os, subprocess, sys, wave
import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(__file__))
import art
import bgm

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
CFG = json.load(open("tools/scenes.json", encoding="utf-8"))
FONT = "fonts/MPLUSRounded1c-ExtraBold.ttf"
art.set_font(FONT)
W, H, FPS = 1080, 1920, CFG["fps"]
SR = 48000
NAVY = art.NAVY
ACCENT = (255, 224, 102, 255)
TEXT_Y = 1300
WIPE = 0.35


def font(size):
    return ImageFont.truetype(FONT, size)


def hexrgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def ease_back(x):
    x = min(max(x, 0.0), 1.0)
    c1 = 1.70158
    return 1 + (c1 + 1) * (x - 1) ** 3 + c1 * (x - 1) ** 2


# ---------------------------------------------------------------- telop pieces
def text_img(text, size, fill, stroke=14):
    f = font(size)
    l, t, r, b = f.getbbox(text, stroke_width=stroke)
    pad = 24
    img = Image.new("RGBA", (r - l + pad * 2, b - t + pad * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.text((pad - l + 6, pad - t + 9), text, font=f, fill=(0, 0, 0, 70), stroke_width=stroke + 2, stroke_fill=(0, 0, 0, 70))
    d.text((pad - l, pad - t), text, font=f, fill=fill, stroke_width=stroke, stroke_fill=NAVY)
    return img


def pill(text, size, fill=art.TEAL, fg=(255, 255, 255, 255)):
    f = font(size)
    l, t, r, b = f.getbbox(text)
    pw, ph = r - l + size * 1.4, b - t + size * 0.9
    img = Image.new("RGBA", (int(pw) + 20, int(ph) + 20), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((10, 10, 10 + pw, 10 + ph), radius=int(ph / 2), fill=fill, outline=NAVY, width=6)
    d.text((10 + pw / 2, 10 + ph / 2), text, font=f, fill=fg, anchor="mm")
    return img


def info_card(info, clinic):
    w, h = 900, 830
    img = Image.new("RGBA", (w + 20, h + 20), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((10, 10, 10 + w, 10 + h), radius=48, fill=(255, 255, 255, 245), outline=NAVY, width=8)
    d.text((10 + w / 2, 105), clinic, font=font(74), fill=NAVY, anchor="mm")
    d.line((70, 175, w - 50, 175), fill=(200, 225, 230, 255), width=4)
    y = 250
    for k, v in info["rows"]:
        d.rounded_rectangle((60, y - 42, 330, y + 42), radius=42, fill=art.TEAL)
        d.text((195, y), k, font=font(44), fill=(255, 255, 255, 255), anchor="mm")
        d.text((620, y), v, font=font(54), fill=NAVY, anchor="mm")
        y += 112
    d.rounded_rectangle((60, y - 20, w - 40, y + 110), radius=65, fill=art.CORAL, outline=NAVY, width=6)
    d.text((10 + w / 2, y + 45), info["cta"], font=font(60), fill=(255, 255, 255, 255), anchor="mm")
    d.text((10 + w / 2, y + 185), info["sub"], font=font(48), fill=art.TEAL_D, anchor="mm")
    return img


def telop_items(sc):
    """List of (image, (cx, cy), delay) for a scene's text."""
    items = []
    if sc.get("label"):
        items.append((pill(sc["label"], 56), (540, 270), 0.1))
    if sc.get("info"):
        items.append((info_card(sc["info"], CFG["clinic"]), (540, 1110), 0.25))
    y = TEXT_Y
    for i, (line, size) in enumerate(sc["lines"]):
        if i:
            y += int((sc["lines"][i - 1][1] + size) * 0.62)
        fill = ACCENT if sc.get("accent") == i else (255, 255, 255, 255)
        items.append((text_img(line, size, fill), (540, y), 0.2 + 0.18 * i))
    return items


# ---------------------------------------------------------------- backgrounds
def gradient(c0, c1):
    a, b = np.array(hexrgb(c0), float), np.array(hexrgb(c1), float)
    t = np.linspace(0, 1, H)[:, None, None]
    arr = (a * (1 - t) + b * t) * np.ones((1, W, 1))
    img = Image.fromarray(arr.astype(np.uint8), "RGB").convert("RGBA")
    d = ImageDraw.Draw(img, "RGBA")
    for yy in range(60, H, 120):  # subtle polka dots
        for xx in range(60 + (yy // 120 % 2) * 60, W, 120):
            d.ellipse((xx - 8, yy - 8, xx + 8, yy + 8), fill=(255, 255, 255, 70))
    return img


BUBBLES = [(np.random.RandomState(i).rand(4)) for i in range(14)]


def bubbles(t):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for rx, ry, rr, rs in BUBBLES:
        r = 20 + rr * 50
        y = (ry * (H + 200) - t * (40 + rs * 60)) % (H + 200) - 100
        x = rx * W + 30 * math.sin(t * 0.8 + rs * 6)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(255, 255, 255, 60), outline=(255, 255, 255, 130), width=4)
    return layer


def find_stock(sid):
    for ext in (".mp4", ".mov", ".webm", ".jpg", ".jpeg", ".png", ".webp"):
        p = f"media/stock/{sid}{ext}"
        if os.path.exists(p):
            return p
    return None


class Stock:
    """Frames from a stock video/photo, centre-cropped to 9:16 with a slow push-in."""

    def __init__(self, path, dur):
        self.n = 0
        self.still = path.lower().endswith((".jpg", ".jpeg", ".png", ".webp"))
        if self.still:
            im = Image.open(path).convert("RGB")
            s = max(W * 1.12 / im.width, H * 1.12 / im.height)
            self.img = im.resize((int(im.width * s), int(im.height * s)), Image.LANCZOS)
            self.dur = dur
        else:
            vf = f"scale={W}:{H}:force_original_aspect_ratio=increase,crop={W}:{H},fps={FPS},format=rgb24"
            self.p = subprocess.Popen(["ffmpeg", "-v", "error", "-stream_loop", "-1", "-i", path, "-t", str(dur),
                                       "-an", "-vf", vf, "-f", "rawvideo", "-"], stdout=subprocess.PIPE)
            self.last = None

    def frame(self, t):
        if self.still:
            z = 1.0 + 0.1 * (t / self.dur)  # Ken Burns push-in
            cw, ch = min(W * 1.12 / z, self.img.width), min(H * 1.12 / z, self.img.height)
            cx, cy = self.img.width / 2, self.img.height / 2
            box = (cx - cw / 2, cy - ch / 2, cx + cw / 2, cy + ch / 2)
            return self.img.resize((W, H), Image.BILINEAR, box=box).convert("RGBA")
        raw = self.p.stdout.read(W * H * 3)
        if len(raw) == W * H * 3:
            self.last = Image.frombytes("RGB", (W, H), raw).convert("RGBA")
        return self.last

    def close(self):
        if not self.still:
            self.p.stdout.close()
            self.p.wait()


def shade_overlay():
    """Darken the top and bottom of stock footage so white telops stay readable."""
    a = np.zeros((H, 1), float)
    y = np.arange(H)[:, None]
    a = np.maximum(a, np.clip((y - 1050) / 350, 0, 1) * 150)
    a = np.maximum(a, np.clip((420 - y) / 300, 0, 1) * 90)
    arr = np.zeros((H, W, 4), np.uint8)
    arr[..., 0:3] = (20, 40, 50)
    arr[..., 3] = (a * np.ones((1, W))).astype(np.uint8)
    return Image.fromarray(arr, "RGBA")


# ---------------------------------------------------------------- animation
def place(frame, img, cx, cy, local, delay, anim, seed):
    x = local - delay
    if x <= 0:
        return
    s = ease_back(x / 0.4)
    ang = 0.0
    dy = 0.0
    dx = 0.0
    tt = local
    if anim == "pop":
        dy = 8 * math.sin(tt * 2.2 + seed)
    elif anim == "float":
        dy = 22 * math.sin(tt * 1.8 + seed)
        dx = 10 * math.sin(tt * 1.1 + seed)
    elif anim == "twinkle":
        s *= 1 + 0.12 * math.sin(tt * 5 + seed)
    elif anim == "wobble":
        ang = 4 * math.sin(tt * 3 + seed)
        dy = 6 * math.sin(tt * 2.2 + seed)
    if s <= 0.02:
        return
    im = img
    if abs(s - 1) > 0.003:
        im = im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))), Image.BILINEAR)
    if abs(ang) > 0.05:
        im = im.rotate(ang, resample=Image.BICUBIC, expand=True)
    frame.alpha_composite(im, (int(cx + dx - im.width / 2), int(cy + dy - im.height / 2)))


def ffmpeg_writer(path, crf=18):
    return subprocess.Popen(["ffmpeg", "-y", "-v", "error", "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}",
                             "-r", str(FPS), "-i", "-", "-c:v", "libx264", "-preset", "medium", "-crf", str(crf),
                             "-pix_fmt", "yuv420p", path], stdin=subprocess.PIPE)


def circle_mask(r):
    m = Image.new("L", (W, H), 0)
    ImageDraw.Draw(m).ellipse((W / 2 - r, H / 2 - r, W / 2 + r, H / 2 + r), 255)
    return m


def main():
    os.makedirs("media/scenes", exist_ok=True)
    os.makedirs("media/telop", exist_ok=True)
    os.makedirs("media/audio", exist_ok=True)
    total = sum(s["dur"] for s in CFG["scenes"])
    nframes = int(round(total * FPS))
    preview = ffmpeg_writer("media/_preview_video.mp4")
    shade = shade_overlay()
    pops = []  # times for the pop sound effect
    prev_last = None
    t0 = 0.0
    timeline = []
    for si, sc in enumerate(CFG["scenes"]):
        sid = sc["id"]
        n = int(round(sc["dur"] * FPS))
        stock_path = find_stock(sid)
        stock = Stock(stock_path, sc["dur"]) if stock_path else None
        bg = gradient(*sc["bg"])
        layers = [] if stock else art.scene_layers(sc["art"])
        if stock and sc["art"] == "info":  # keep the waving tooth above the info card
            layers = [l for l in art.scene_layers("info")]
        items = telop_items(sc)
        # static telop PNG for editors
        tel = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        for img, (cx, cy), _ in items:
            tel.alpha_composite(img, (int(cx - img.width / 2), int(cy - img.height / 2)))
        tel.save(f"media/telop/{sid}.png")
        pops += [t0 + d for _, _, d in items] + [t0 + d for _, _, _, d in layers[:1]]
        scene_w = ffmpeg_writer(f"media/scenes/{sid}.mp4", crf=16)
        print(f"{sid}: {'stock ' + stock_path if stock else 'illustration'}", flush=True)
        for fi in range(n):
            local = fi / FPS
            if stock:
                frame = stock.frame(local).copy()
                frame.alpha_composite(shade)
            else:
                frame = bg.copy()
                frame.alpha_composite(bubbles(t0 + local))
            for li, (img, (cx, cy), anim, delay) in enumerate(layers):
                place(frame, img, cx, cy, local, delay, anim, li * 1.7)
            scene_w.stdin.write(frame.convert("RGB").tobytes())
            for ii, (img, (cx, cy), delay) in enumerate(items):
                place(frame, img, cx, cy, local, delay, "static", 0)
            out = frame.convert("RGB")
            if prev_last is not None and local < WIPE:
                r = ease_back(local / WIPE) * math.hypot(W, H) / 2 * 1.05
                out = Image.composite(out, prev_last, circle_mask(max(r, 1)))
            preview.stdin.write(out.tobytes())
            if fi == n - 1:
                prev_last = out
        scene_w.stdin.close()
        scene_w.wait()
        if stock:
            stock.close()
        timeline.append((sid, t0, t0 + sc["dur"]))
        t0 += sc["dur"]
    preview.stdin.close()
    preview.wait()

    # ---- audio: BGM + pop sound effects on each element's entrance
    music = bgm.make_bgm(total, SR)
    pop = bgm.make_pop(SR)
    bgm.write_wav("media/audio/bgm.wav", music, SR)
    bgm.write_wav("media/audio/pop.wav", pop, SR)
    mix = music.copy()
    for tp in pops:
        i = int(tp * SR)
        seg = pop[: max(0, min(len(pop), len(mix) - i))]
        mix[i:i + len(seg)] += seg * 0.55
    mix /= max(1.0, np.abs(mix).max() / 0.95)
    bgm.write_wav("media/_mix.wav", mix, SR)
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", "media/_preview_video.mp4", "-i", "media/_mix.wav",
                    "-c:v", "copy", "-c:a", "aac", "-b:a", "192k", "-shortest", "-movflags", "+faststart",
                    "dental_intro_preview.mp4"], check=True)
    os.remove("media/_preview_video.mp4")
    os.remove("media/_mix.wav")
    json.dump({"fps": FPS, "total": total, "scenes": timeline, "pops": pops},
              open("media/timeline.json", "w"), indent=1)
    write_srt(timeline)
    print("done:", total, "sec")


def write_srt(timeline):
    """Narration script as subtitles (for voice recording / auto captions)."""
    def ts(x):
        ms = int(round(x * 1000))
        return f"{ms // 3600000:02}:{ms // 60000 % 60:02}:{ms // 1000 % 60:02},{ms % 1000:03}"
    os.makedirs("captions", exist_ok=True)
    with open("captions/narration.srt", "w", encoding="utf-8") as f:
        for i, (sc, (_, a, b)) in enumerate(zip(CFG["scenes"], timeline), 1):
            f.write(f"{i}\n{ts(a + 0.3)} --> {ts(b - 0.2)}\n{sc['narration']}\n\n")


if __name__ == "__main__":
    main()
