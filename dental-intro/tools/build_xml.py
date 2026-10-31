"""Write a Final Cut Pro 7 XML (xmeml v4) project that Premiere Pro imports with bins and a sequence.

Run after render.py (reads media/timeline.json):
    python3 tools/build_xml.py
"""
import json, os
from xml.sax.saxutils import escape

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
TL = json.load(open("media/timeline.json"))
CFG = json.load(open("tools/scenes.json", encoding="utf-8"))
FPS, W, H = TL["fps"], 1080, 1920
END = int(round(TL["total"] * FPS))
STILL = 108000  # nominal duration for still images
POP = 3  # frames
SEQ_NAME = f"{CFG['clinic']}_紹介ショート_45秒"


def rate():
    return f"<rate><timebase>{FPS}</timebase><ntsc>FALSE</ntsc></rate>"


def vfmt():
    return (f"<samplecharacteristics>{rate()}<width>{W}</width><height>{H}</height>"
            "<anamorphic>FALSE</anamorphic><pixelaspectratio>square</pixelaspectratio>"
            "<fielddominance>none</fielddominance></samplecharacteristics>")


AFMT = ("<samplecharacteristics><depth>16</depth><samplerate>48000</samplerate></samplecharacteristics>")


def filedef(fid, path, dur, video=True, audio=False):
    media = f"<video>{vfmt()}</video>" if video else ""
    if audio:
        media += f"<audio>{AFMT}<channelcount>2</channelcount></audio>"
    return (f'<file id="{fid}"><name>{escape(os.path.basename(path))}</name><pathurl>{escape(path)}</pathurl>'
            f"{rate()}<duration>{dur}</duration><media>{media}</media></file>")


# ---- media files
files = {}
for sid, a, b in TL["scenes"]:
    n = int(round((b - a) * FPS))
    files[f"f-scene-{sid}"] = (f"media/scenes/{sid}.mp4", n, True, False)
    files[f"f-telop-{sid}"] = (f"media/telop/{sid}.png", STILL, True, False)
files["f-bgm"] = ("media/audio/bgm.wav", END, False, True)
files["f-pop"] = ("media/audio/pop.wav", POP, False, True)
first_use = set()


def fileref(fid):
    """Full definition on first use (inside the sequence), reference afterwards."""
    if fid in first_use:
        return f'<file id="{fid}"/>'
    first_use.add(fid)
    path, dur, v, a = files[fid]
    return filedef(fid, path, dur, v, a)


def vclip(cid, fid, start, end, src_in=0, still=False):
    path, dur, _, _ = files[fid]
    return (f'<clipitem id="{cid}"><name>{escape(os.path.basename(path))}</name><enabled>TRUE</enabled>'
            f"<duration>{dur}</duration>{rate()}<start>{start}</start><end>{end}</end>"
            f"<in>{src_in}</in><out>{src_in + end - start}</out>"
            + ("<stillframe>TRUE</stillframe>" if still else "")
            + fileref(fid) + "<sourcetrack><mediatype>video</mediatype></sourcetrack></clipitem>")


def aclip(cid, fid, start, end, ch):
    path, dur, _, _ = files[fid]
    return (f'<clipitem id="{cid}"><name>{escape(os.path.basename(path))}</name><enabled>TRUE</enabled>'
            f"<duration>{dur}</duration>{rate()}<start>{start}</start><end>{end}</end>"
            f"<in>0</in><out>{end - start}</out>{fileref(fid)}"
            f"<sourcetrack><mediatype>audio</mediatype><trackindex>{ch}</trackindex></sourcetrack></clipitem>")


def track(items, audio_ch=None):
    tail = f"<outputchannelindex>{audio_ch}</outputchannelindex>" if audio_ch else ""
    return f"<track>{items}<enabled>TRUE</enabled><locked>FALSE</locked>{tail}</track>"


v1 = v2 = ""
for sid, a, b in TL["scenes"]:
    s, e = int(round(a * FPS)), int(round(b * FPS))
    v1 += vclip(f"v-scene-{sid}", f"f-scene-{sid}", s, e)
    v2 += vclip(f"v-telop-{sid}", f"f-telop-{sid}", s, e, still=True)

a1 = aclip("a-bgm-1", "f-bgm", 0, END, 1)
a2 = aclip("a-bgm-2", "f-bgm", 0, END, 2)
pops = sorted({int(round(t * FPS)) for t in TL["pops"]})
pops = [p for i, p in enumerate(pops) if i == 0 or p - pops[i - 1] >= POP]  # no overlaps on one track
a3 = "".join(aclip(f"a-pop-{i}-1", "f-pop", p, p + POP, 1) for i, p in enumerate(pops))
a4 = "".join(aclip(f"a-pop-{i}-2", "f-pop", p, p + POP, 2) for i, p in enumerate(pops))

sequence = (f'<sequence id="seq-1"><name>{escape(SEQ_NAME)}</name><duration>{END}</duration>{rate()}'
            f"<timecode>{rate()}<string>00:00:00:00</string><frame>0</frame><displayformat>NDF</displayformat></timecode>"
            f"<media><video><format>{vfmt()}</format>{track(v1)}{track(v2)}</video>"
            f"<audio><numOutputChannels>2</numOutputChannels><format>{AFMT}</format>"
            f"{track(a1, 1)}{track(a2, 2)}{track(a3, 1)}{track(a4, 2)}</audio></media></sequence>")


def master(fid, name):
    """Bin entry for a media file (references the definition inside the sequence)."""
    path, dur, v, a = files[fid]
    kind = "video" if v else "audio"
    return (f'<clip id="m-{fid}"><name>{escape(name)}</name><duration>{dur}</duration>{rate()}'
            f'<media><{kind}><track><clipitem id="mi-{fid}"><name>{escape(name)}</name>'
            f'<file id="{fid}"/></clipitem></track></{kind}></media></clip>')


def binx(name, children):
    return f"<bin><name>{escape(name)}</name><children>{children}</children></bin>"


bins = (
    binx("01_シーケンス", sequence)
    + binx("02_背景映像", "".join(master(f"f-scene-{s}", f"{s}.mp4") for s, _, _ in TL["scenes"]))
    + binx("03_テロップ", "".join(master(f"f-telop-{s}", f"{s}.png") for s, _, _ in TL["scenes"]))
    + binx("04_音声", master("f-bgm", "bgm.wav") + master("f-pop", "pop.wav"))
    + binx("05_実写素材_差し替え用", "")
)
xml = ('<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE xmeml>\n<xmeml version="4">'
       f"<project><name>{escape(CFG['clinic'])}_紹介ショート</name><children>{bins}</children></project></xmeml>\n")
open("dental_intro_premiere.xml", "w", encoding="utf-8").write(xml)
print("wrote dental_intro_premiere.xml:", len(pops), "pops,", END, "frames")
