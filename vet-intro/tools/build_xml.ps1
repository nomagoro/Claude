# Premiere Pro用 FCP7 XML（xmeml v4）を書き出す
# 使い方: powershell -ExecutionPolicy Bypass -File tools\build_xml.ps1
# ビン: 01_シーケンス / 02_背景映像 / 03_テロップ / 04_音声 / 05_実写素材_差し替え用
# トラック: V1 映像 / V2 メッセージテロップ / V3 病院名・架空表記 / A1 BGM
# ※色調整（Lumetri）は .prproj 側でカットごとに設定している（XMLには入らない）
param(
    [string]$Root = (Split-Path $PSScriptRoot -Parent)
)
$FPS = 30; $W = 1080; $H = 1920
$END = 900            # 30秒
$STILL = 108000       # 静止画の公称尺
$SEQ_NAME = 'ごろう動物病院_紹介ショート'
$OUT_NAME = 'goro_intro_premiere.xml'

function Esc([string]$s) { [System.Security.SecurityElement]::Escape($s) }
function Rate { "<rate><timebase>$FPS</timebase><ntsc>FALSE</ntsc></rate>" }
function VFmt([int]$fw = $W, [int]$fh = $H) {
    "<samplecharacteristics>$(Rate)<width>$fw</width><height>$fh</height>" +
    "<anamorphic>FALSE</anamorphic><pixelaspectratio>square</pixelaspectratio>" +
    "<fielddominance>none</fielddominance></samplecharacteristics>"
}
$AFmt = "<samplecharacteristics><depth>16</depth><samplerate>48000</samplerate></samplecharacteristics>"

# 素材（durは素材の長さ・フレーム、w/hは実際の解像度）
$videos = @(
    @{ id = 'catexam'; bin = '05'; path = 'media/07_cat_exam_6816882.mp4';          dur = 270;  w = 3840; h = 2160 }
    @{ id = 'sakura';  bin = '02'; path = 'media/01_sakura_stroll_31295367.mp4';    dur = 270;  w = 1080; h = 1920 }
    @{ id = 'steth';   bin = '05'; path = 'media/08_exam_stethoscope_6235747.mp4';  dur = 600;  w = 1080; h = 1920 }
    @{ id = 'shep';    bin = '05'; path = 'media/09_exam_shepherd_6235182.mp4';     dur = 510;  w = 1440; h = 2560 }
    @{ id = 'shiba1';  bin = '02'; path = 'media/04_shiba_29243898.mp4';            dur = 690;  w = 1080; h = 1920 }
    @{ id = 'shiba2';  bin = '02'; path = 'media/10_shiba_29243903.mp4';            dur = 600;  w = 1080; h = 1920 }
    @{ id = 'calico';  bin = '02'; path = 'media/05_calico_cat_35486843.mp4';       dur = 2430; w = 1080; h = 1920 }
    @{ id = 'akita';   bin = '02'; path = 'media/06_akita_sakura_31643071.mp4';     dur = 360;  w = 1080; h = 1920 }
)
$bgm = @{ id = 'bgm'; path = 'media/bgm_happy_ukulele_512480.mp3'; dur = 54 * $FPS }

# V1: 本編（s/e=シーケンス上の位置、in=素材の開始フレーム、scale=%、xfade=このカットの頭に入れるディゾルブのフレーム数）
# 位置（構図）の微調整は .prproj 側で行う
# 猫の診察（3840x2160）は88.9%で縦に切り出し、.prproj側で位置Xを1000にして猫の顔と聴診器を入れる
# ディゾルブは桜への切り替えとエンドカードへの入りだけ（他はカット切り替え）
$cuts = @(
    @{ v = 'catexam'; s = 0;   e = 90;  in = 40;   scale = 88.9 }   # 猫の表情と聴診器
    @{ v = 'sakura';  s = 90;  e = 210; in = 30;   scale = 100; xfade = 8 }
    @{ v = 'steth';   s = 210; e = 300; in = 75;   scale = 100 }    # 犬・手・聴診器（素材2.5〜5.5秒）
    @{ v = 'shep';    s = 300; e = 390; in = 90;   scale = 75 }     # 犬に触れる手元
    @{ v = 'shiba1';  s = 390; e = 465; in = 60;   scale = 108 }    # .prproj側で位置Y 883（顔を少し上へ。テロップに口元がかからないように）
    @{ v = 'shiba2';  s = 465; e = 540; in = 120;  scale = 100 }
    @{ v = 'calico';  s = 540; e = 615; in = 0;    scale = 100 }    # 顔を上げて伸び
    @{ v = 'calico';  s = 615; e = 690; in = 1275; scale = 100 }    # 寝そべって顔をこちらへ（素材42.5秒〜）
    @{ v = 'akita';   s = 690; e = 900; in = 30;   scale = 100; xfade = 12 }
)
# V2: メッセージテロップ / V3: 病院名・架空表記（0〜7秒は出し続ける）・エンドカード
$telopV2 = @(
    @{ t = 'goro_t01_open'; s = 0;   e = 90 }
    @{ t = 'goro_t02_exam'; s = 216; e = 384 }
    @{ t = 'goro_t03_dog';  s = 396; e = 534 }
    @{ t = 'goro_t04_cat';  s = 546; e = 684 }
)
$telopV3 = @(
    @{ t = 'goro_t00_name'; s = 0;   e = 210 }
    @{ t = 'goro_t05_end';  s = 700; e = 900 }
)

function FileFull($fid, $name, $path, $dur, [switch]$Audio, [switch]$NoVideo, [int]$fw = $W, [int]$fh = $H) {
    $media = ''
    if (-not $NoVideo) { $media += "<video>$(VFmt $fw $fh)</video>" }
    if ($Audio) { $media += "<audio>$AFmt<channelcount>2</channelcount></audio>" }
    "<file id=`"$fid`"><name>$(Esc $name)</name><pathurl>$(Esc $path)</pathurl>$(Rate)<duration>$dur</duration><media>$media</media></file>"
}

# ビンに入れるマスタークリップ（ファイル定義はここで1回だけ書く）
function MasterClip($cid, $name, $fileXml, $dur, $kind, [switch]$Still) {
    $st = if ($Still) { '<stillframe>TRUE</stillframe>' } else { '' }
    "<clip id=`"$cid`"><name>$(Esc $name)</name><duration>$dur</duration>$(Rate)$st" +
    "<media><$kind><track><clipitem id=`"$cid-item`"><name>$(Esc $name)</name><duration>$dur</duration>$(Rate)" +
    "<start>0</start><end>$dur</end><in>0</in><out>$dur</out>$fileXml</clipitem></track></$kind></media></clip>"
}

function SeqClip($cid, $name, $fid, $dur, $start, $end, $in, [switch]$Still, [string]$kind = 'video', [string]$extra = '') {
    $st = if ($Still) { '<stillframe>TRUE</stillframe>' } else { '' }
    "<clipitem id=`"$cid`"><name>$(Esc $name)</name><enabled>TRUE</enabled><duration>$dur</duration>$(Rate)" +
    "<start>$start</start><end>$end</end><in>$in</in><out>$($in + $end - $start)</out>$st<file id=`"$fid`"/>" +
    "<sourcetrack><mediatype>$kind</mediatype>$(if ($kind -eq 'audio') { '<trackindex>1</trackindex>' })</sourcetrack>$extra</clipitem>"
}

function Dissolve($at, $len) {
    $h = [int]($len / 2)
    "<transitionitem><start>$($at - $h)</start><end>$($at + $len - $h)</end><alignment>center</alignment>$(Rate)" +
    "<effect><name>Cross Dissolve</name><effectid>Cross Dissolve</effectid><effectcategory>Dissolve</effectcategory>" +
    "<effecttype>transition</effecttype><mediatype>video</mediatype></effect></transitionitem>"
}

function Motion($scale) {
    if ($scale -eq 100) { return '' }
    "<filter><effect><name>Basic Motion</name><effectid>basic</effectid><effectcategory>motion</effectcategory>" +
    "<effecttype>motion</effecttype><mediatype>video</mediatype><parameter><parameterid>scale</parameterid><name>Scale</name>" +
    "<valuemin>0</valuemin><valuemax>1000</valuemax><value>$scale</value></parameter></effect></filter>"
}

function Bin($name, $children) { "<bin><name>$(Esc $name)</name><children>$children</children></bin>" }

# --- ビンの中身 ---
$bin02 = ''; $bin05 = ''
foreach ($v in $videos) {
    $name = Split-Path $v.path -Leaf
    $mc = MasterClip "mc-$($v.id)" $name (FileFull "f-$($v.id)" $name $v.path $v.dur -fw $v.w -fh $v.h) $v.dur 'video'
    if ($v.bin -eq '02') { $bin02 += $mc } else { $bin05 += $mc }
}
$bin03 = ''
foreach ($t in (@($telopV2) + @($telopV3) | ForEach-Object { $_.t } | Select-Object -Unique)) {
    $bin03 += MasterClip "mc-$t" "$t.png" (FileFull "f-$t" "$t.png" "media/$t.png" $STILL) $STILL 'video' -Still
}
$bgmName = Split-Path $bgm.path -Leaf
$bin04 = MasterClip 'mc-bgm' $bgmName (FileFull 'f-bgm' $bgmName $bgm.path $bgm.dur -Audio -NoVideo) $bgm.dur 'audio'

# --- シーケンス ---
$v1 = ''
for ($i = 0; $i -lt $cuts.Count; $i++) {
    $c = $cuts[$i]
    $v = $videos | Where-Object { $_.id -eq $c.v }
    if ($c.xfade) { $v1 += Dissolve $c.s $c.xfade }
    $v1 += SeqClip "v1-$i" (Split-Path $v.path -Leaf) "f-$($c.v)" $v.dur $c.s $c.e $c.in -extra (Motion $c.scale)
}
function TelopTrack($list, $prefix) {
    $s = ''; $i = 0
    foreach ($t in $list) { $s += SeqClip "$prefix-$i" "$($t.t).png" "f-$($t.t)" $STILL $t.s $t.e 0 -Still; $i++ }
    $s
}
$v2 = TelopTrack $telopV2 'v2'
$v3 = TelopTrack $telopV3 'v3'

# BGM: 頭0.5秒でフェードイン、最後の2秒でフェードアウト（Audio Levels は線形ゲイン）
$lv = 0.6
$levels = "<filter><effect><name>Audio Levels</name><effectid>audiolevels</effectid><effectcategory>audiolevels</effectcategory>" +
    "<effecttype>audiolevels</effecttype><mediatype>audio</mediatype><parameter><parameterid>level</parameterid><name>Level</name>" +
    "<valuemin>0</valuemin><valuemax>3.98109</valuemax><value>$lv</value>" +
    "<keyframe><when>0</when><value>0</value></keyframe><keyframe><when>15</when><value>$lv</value></keyframe>" +
    "<keyframe><when>$($END - 2 * $FPS)</when><value>$lv</value></keyframe><keyframe><when>$END</when><value>0</value></keyframe>" +
    "</parameter></effect></filter>"
$a1 = SeqClip 'a1-bgm' $bgmName 'f-bgm' $bgm.dur 0 $END 0 -kind 'audio' -extra $levels

function Track($items) { "<track>$items<enabled>TRUE</enabled><locked>FALSE</locked></track>" }

$sequence = "<sequence id=`"seq-1`"><name>$(Esc $SEQ_NAME)</name><duration>$END</duration>$(Rate)" +
    "<timecode>$(Rate)<string>00:00:00:00</string><frame>0</frame><displayformat>NDF</displayformat></timecode>" +
    "<media><video><format>$(VFmt)</format>$(Track $v1)$(Track $v2)$(Track $v3)</video>" +
    "<audio><numOutputChannels>2</numOutputChannels><format>$AFmt</format>" +
    "<track>$a1<enabled>TRUE</enabled><locked>FALSE</locked></track></audio></media></sequence>"

$xml = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<!DOCTYPE xmeml>`n<xmeml version=`"4`"><project><name>$(Esc $SEQ_NAME)</name><children>" +
    (Bin '02_背景映像' $bin02) + (Bin '03_テロップ' $bin03) + (Bin '04_音声' $bin04) +
    (Bin '05_実写素材_差し替え用' $bin05) + (Bin '01_シーケンス' $sequence) +
    "</children></project></xmeml>`n"

$out = Join-Path $Root $OUT_NAME
[IO.File]::WriteAllText($out, $xml, (New-Object Text.UTF8Encoding $false))
([xml](Get-Content $out -Raw -Encoding utf8)) | Out-Null   # 整形式チェック
"wrote $out"
