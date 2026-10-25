"""Write editable caption files for Premiere Pro, one per screen position.

Each file goes on its own caption track so the top / center / bottom
layout of the PNG telops can be reproduced with a per-track style.
"""
import sys

FPS = 60
OUT = sys.argv[1]

# (start_frame, end_frame, text)
TRACKS = {
    "1_top": [
        (0, 691, "豆柴パピーの日常"),
        (691, 810, "寝床づくりの結果"),
    ],
    "2_center": [
        (691, 810, "放置ｗ"),
    ],
    "3_bottom": [
        (0, 150, "新しいベッドが\n届いたよ！"),
        (150, 300, "さっそく\nホリホリ開始"),
        (300, 450, "前足でせっせと\n寝床づくり"),
        (450, 576, "真ん中もふかふかに…\n※寝る前の穴掘りは犬の本能なんです"),
        (576, 636, "お？\nついに完成…？"),
        (636, 691, "…と思ったら"),
        (691, 810, "掘るだけ掘って去っていきました\n▶ チャンネル登録してね"),
    ],
}

def tc(f):
    ms = round(f * 1000 / FPS)
    return f"{ms // 3600000:02}:{ms // 60000 % 60:02}:{ms // 1000 % 60:02},{ms % 1000:03}"

for name, cues in TRACKS.items():
    body = "\n".join(f"{i}\n{tc(s)} --> {tc(e)}\n{t}\n" for i, (s, e, t) in enumerate(cues, 1))
    with open(f"{OUT}/telop_{name}.srt", "w", encoding="utf-8-sig") as f:
        f.write(body)
