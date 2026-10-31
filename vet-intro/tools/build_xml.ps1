# Premiere Pro用 FCP7 XML（xmeml v4）を書き出す
# 使い方: powershell -ExecutionPolicy Bypass -File tools\build_xml.ps1
# ビン: 01_シーケンス / 02_背景映像 / 03_テロップ / 04_音声 / 05_実写素材_差し替え用
param(
    [string]$Root = (Split-Path $PSScriptRoot -Parent)
)
$FPS = 25; $W = 1080; $H = 1920
$END = 750            # 30秒
$STILL = 108000       # 静止画の公称尺
$XFADE = 10           # カット間ディゾルブ（フレーム）
$SEQ_NAME = 'ひだまり動物病院_紹介ショート'

function Esc([string]$s) { [System.Security.SecurityElement]::Escape($s) }
function Rate { "<rate><timebase>$FPS</timebase><ntsc>FALSE</ntsc></rate>" }
function VFmt([int]$fw = $W, [int]$fh = $H) {
    "<samplecharacteristics>$(Rate)<width>$fw</width><height>$fh</height>" +
    "<anamorphic>FALSE</anamorphic><pixelaspectratio>square</pixelaspectratio>" +
    "<fielddominance>none</fielddominance></samplecharacteristics>"
}
$AFmt = "<samplecharacteristics><depth>16</depth><samplerate>48000</samplerate></samplecharacteristics>"

# 素材（durは素材の長さ・フレーム、w/hは実際の解像度、scaleは1080x1920に合わせる拡大率%）
$videos = @(
    @{ id = 'puppies';  bin = '02'; path = 'media/01_puppies_12768731.mp4';     dur = 325; w = 720;  h = 1280; scale = 150 }
    @{ id = 'exam';     bin = '05'; path = 'media/02_exam_6235179.mp4';         dur = 425; w = 1080; h = 1920; scale = 100 }
    @{ id = 'listen';   bin = '05'; path = 'media/03_stethoscope_6235191_uhd.mp4'; dur = 200; w = 1440; h = 2560; scale = 75 }
    @{ id = 'owner';    bin = '05'; path = 'media/04_with_owner_6235744.mp4';   dur = 375; w = 1080; h = 1920; scale = 100 }
    @{ id = 'cat';      bin = '05'; path = 'media/05_cat_care_6131039.mp4';     dur = 450; w = 1080; h = 1920; scale = 100 }
    @{ id = 'vet';      bin = '05'; path = 'media/06_vet_with_dog_6234589.mp4'; dur = 325; w = 1080; h = 1920; scale = 100 }
)
$telops = @('telop_00_title', 'telop_01_exam', 'telop_02_listen', 'telop_03_owner', 'telop_04_cat', 'telop_05_endcard')
$bgm = @{ id = 'bgm'; path = 'media/bgm_happy_ukulele_512480.mp3'; dur = 54 * $FPS }

# V1: 本編（start, end, 素材in）
$cuts = @(
    @{ v = 'puppies'; s = 0;   e = 100; in = 25 }
    @{ v = 'exam';    s = 100; e = 225; in = 50 }
    @{ v = 'listen';  s = 225; e = 350; in = 25 }
    @{ v = 'owner';   s = 350; e = 475; in = 50 }
    @{ v = 'cat';     s = 475; e = 600; in = 100 }
    @{ v = 'vet';     s = 600; e = 750; in = 25 }
)
# V3: テロップ（V2は色調整用の調整レイヤーを置くために空けておく）
$telopTimes = @(
    @{ t = 'telop_00_title';   s = 10;  e = 95 }
    @{ t = 'telop_01_exam';    s = 110; e = 220 }
    @{ t = 'telop_02_listen';  s = 235; e = 345 }
    @{ t = 'telop_03_owner';   s = 360; e = 470 }
    @{ t = 'telop_04_cat';     s = 485; e = 595 }
    @{ t = 'telop_05_endcard'; s = 615; e = 750 }
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

function Dissolve($at) {
    $h = $XFADE / 2
    "<transitionitem><start>$($at - $h)</start><end>$($at + $h)</end><alignment>center</alignment>$(Rate)" +
    "<effect><name>Cross Dissolve</name><effectid>Cross Dissolve</effectid><effectcategory>Dissolve</effectcategory>" +
    "<effecttype>transition</effecttype><mediatype>video</mediatype></effect></transitionitem>"
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
foreach ($t in $telops) {
    $bin03 += MasterClip "mc-$t" "$t.png" (FileFull "f-$t" "$t.png" "media/$t.png" $STILL) $STILL 'video' -Still
}
$bgmName = Split-Path $bgm.path -Leaf
$bin04 = MasterClip 'mc-bgm' $bgmName (FileFull 'f-bgm' $bgmName $bgm.path $bgm.dur -Audio -NoVideo) $bgm.dur 'audio'

# --- シーケンス ---
# 素材の解像度が1080x1920でないときは Basic Motion のスケールで画面に合わせる
function Motion($scale) {
    if ($scale -eq 100) { return '' }
    "<filter><effect><name>Basic Motion</name><effectid>basic</effectid><effectcategory>motion</effectcategory>" +
    "<effecttype>motion</effecttype><mediatype>video</mediatype><parameter><parameterid>scale</parameterid><name>Scale</name>" +
    "<valuemin>0</valuemin><valuemax>1000</valuemax><value>$scale</value></parameter></effect></filter>"
}
$v1 = ''
for ($i = 0; $i -lt $cuts.Count; $i++) {
    $c = $cuts[$i]
    $v = $videos | Where-Object { $_.id -eq $c.v }
    if ($i -gt 0) { $v1 += Dissolve $c.s }
    $v1 += SeqClip "v1-$i" (Split-Path $v.path -Leaf) "f-$($c.v)" $v.dur $c.s $c.e $c.in -extra (Motion $v.scale)
}
$v2 = ''
$i = 0
foreach ($t in $telopTimes) { $v2 += SeqClip "v2-$i" "$($t.t).png" "f-$($t.t)" $STILL $t.s $t.e 0 -Still; $i++ }

# BGM: 0dB → 最後の2秒でフェードアウト（Audio Levels は線形ゲイン）
$fadeStart = $END - 50
$levels = "<filter><effect><name>Audio Levels</name><effectid>audiolevels</effectid><effectcategory>audiolevels</effectcategory>" +
    "<effecttype>audiolevels</effecttype><mediatype>audio</mediatype><parameter><parameterid>level</parameterid><name>Level</name>" +
    "<valuemin>0</valuemin><valuemax>3.98109</valuemax><value>0.6</value>" +
    "<keyframe><when>$fadeStart</when><value>0.6</value></keyframe><keyframe><when>$END</when><value>0</value></keyframe>" +
    "</parameter></effect></filter>"
$a1 = SeqClip 'a1-bgm' $bgmName 'f-bgm' $bgm.dur 0 $END 0 -kind 'audio' -extra $levels

function Track($items) { "<track>$items<enabled>TRUE</enabled><locked>FALSE</locked></track>" }

$sequence = "<sequence id=`"seq-1`"><name>$(Esc $SEQ_NAME)</name><duration>$END</duration>$(Rate)" +
    "<timecode>$(Rate)<string>00:00:00:00</string><frame>0</frame><displayformat>NDF</displayformat></timecode>" +
    "<media><video><format>$(VFmt)</format>$(Track $v1)$(Track '')$(Track $v2)</video>" +
    "<audio><numOutputChannels>2</numOutputChannels><format>$AFmt</format>" +
    "<track>$a1<enabled>TRUE</enabled><locked>FALSE</locked></track></audio></media></sequence>"

$xml = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<!DOCTYPE xmeml>`n<xmeml version=`"4`"><project><name>$(Esc $SEQ_NAME)</name><children>" +
    (Bin '02_背景映像' $bin02) + (Bin '03_テロップ' $bin03) + (Bin '04_音声' $bin04) +
    (Bin '05_実写素材_差し替え用' $bin05) + (Bin '01_シーケンス' $sequence) +
    "</children></project></xmeml>`n"

$out = Join-Path $Root 'vet_intro_premiere.xml'
[IO.File]::WriteAllText($out, $xml, (New-Object Text.UTF8Encoding $false))
([xml](Get-Content $out -Raw -Encoding utf8)) | Out-Null   # 整形式チェック
"wrote $out"
