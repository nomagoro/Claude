# テロップ画像（1080x1920・透過PNG）を作る
# 使い方: powershell -ExecutionPolicy Bypass -File tools\make_telops.ps1
# 安全領域: 下20%（y>1536）と右端180px、上端160px（SNSの操作表示）には何も置かない
# 1画面につき主メッセージ1つ＋必要なら短い補足1行。犬猫の顔・診察の手元に重ならない位置に置く
param(
    [string]$Root = (Split-Path $PSScriptRoot -Parent)
)
Add-Type -AssemblyName System.Drawing

$W = 1080; $H = 1920
$SAFE_TOP = 160; $SAFE_BOTTOM = [int]($H * 0.8)   # 1536
$LEFT = 60; $RIGHT = 900                           # 右端180pxは空ける
$CX = ($LEFT + $RIGHT) / 2

$fonts = New-Object System.Drawing.Text.PrivateFontCollection
$fonts.AddFontFile((Join-Path $Root 'fonts\MPLUSRounded1c-ExtraBold.ttf'))
$family = $fonts.Families[0]

# 配色: クリーム / こげ茶 / 淡いコーラル
$BROWN = [System.Drawing.Color]::FromArgb(255, 92, 58, 33)
$SUB   = [System.Drawing.Color]::FromArgb(255, 140, 98, 64)
$CREAM = [System.Drawing.Color]::FromArgb(238, 255, 249, 238)
$CORAL = [System.Drawing.Color]::FromArgb(255, 244, 162, 140)
$OUT = Join-Path $Root 'media'
New-Item -ItemType Directory -Force $OUT | Out-Null

function New-Canvas {
    $bmp = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.TextRenderingHint = 'AntiAliasGridFit'
    $g.Clear([System.Drawing.Color]::Transparent)
    return @($bmp, $g)
}

function Get-TextPath([string]$text, [float]$size, [float]$cx, [float]$cy) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = 'Center'; $fmt.LineAlignment = 'Center'
    $path.AddString($text, $family, 0, $size, (New-Object System.Drawing.PointF $cx, $cy), $fmt)
    return $path
}

function Get-RoundRect([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

function Draw-Panel($g, [float]$top, [float]$bottom) {
    $rect = Get-RoundRect $LEFT $top ($RIGHT - $LEFT) ($bottom - $top) 44
    $shadow = Get-RoundRect ($LEFT + 6) ($top + 10) ($RIGHT - $LEFT) ($bottom - $top) 44
    $g.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(60, 60, 40, 20))), $shadow)
    $g.FillPath((New-Object System.Drawing.SolidBrush $CREAM), $rect)
    $g.DrawPath((New-Object System.Drawing.Pen $CORAL, 8), $rect)
}

# パネル内（左右40pxの余白）に収まるまで文字を小さくする
function Draw-Text($g, [string]$text, [float]$size, [float]$cy, $color) {
    do {
        $path = Get-TextPath $text $size $CX $cy
        $b = $path.GetBounds()
        $size -= 2
    } while ($b.Right -gt $RIGHT - 40 -or $b.Left -lt $LEFT + 40)
    $g.FillPath((New-Object System.Drawing.SolidBrush $color), $path)
}

# 行の配列からパネルを作る。行 = @(文字, サイズ, 色) / 'line' は区切り線
# -Top か -Bottom のどちらかで位置を決める
function Make-Panel([string]$name, $rows, [int]$Top = -1, [int]$Bottom = -1) {
    $pad = 34
    $heights = foreach ($r in $rows) { if ($r -eq 'line') { 28 } else { [int]($r[1] * 1.32) } }
    # ※PowerShellは大文字小文字を区別しないので、画面の高さ$Hと別の名前にする
    $panelH = ($heights | Measure-Object -Sum).Sum + $pad * 2
    if ($Top -lt 0) { $Top = $Bottom - $panelH }
    $Bottom = $Top + $panelH
    if ($Top -lt $SAFE_TOP -or $Bottom -gt $SAFE_BOTTOM) { throw "$name は安全領域の外です（$Top-$Bottom）" }
    $c = New-Canvas; $bmp = $c[0]; $g = $c[1]
    Draw-Panel $g $Top $Bottom
    $y = $Top + $pad
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $r = $rows[$i]
        if ($r -eq 'line') {
            $g.DrawLine((New-Object System.Drawing.Pen $CORAL, 4), $LEFT + 110, $y + 14, $RIGHT - 110, $y + 14)
        } else {
            Draw-Text $g $r[0] $r[1] ($y + $heights[$i] / 2) $r[2]
        }
        $y += $heights[$i]
    }
    $bmp.Save((Join-Path $OUT "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    "{0}: y={1}-{2}" -f $name, $Top, $Bottom
}

$NOTE = '架空の動物病院／紹介動画サンプル'

# 0〜7秒: 病院名（上側に出し続ける）
Make-Panel 'goro_t00_name' @(
    @('ごろう動物病院', 104, $BROWN),
    @($NOTE, 46, $SUB)
) -Top 180
# 0〜3秒: 冒頭メッセージ（病院名パネルの下。猫の顔は画面の中〜下）
Make-Panel 'goro_t01_open' @(
    @('大切な家族の、', 88, $BROWN),
    @('いつもの相談先。', 88, $BROWN)
) -Top 480
# 7〜13秒: 診察（下側。犬・手・聴診器は画面中央。補足行を入れるとシェパードの口元にかかるので主メッセージのみ）
Make-Panel 'goro_t02_exam' @(
    @('小さな変化も、', 88, $BROWN),
    @('ていねいに。', 88, $BROWN)
) -Bottom 1515
# 13〜18秒: 犬（下側。柴犬の顔は画面上〜中央）
Make-Panel 'goro_t03_dog' @(
    @('おうちでの様子も、', 84, $BROWN),
    @('お聞かせください。', 84, $BROWN)
) -Bottom 1515
# 18〜23秒: 猫（下側。三毛猫の顔は画面上〜中央）
Make-Panel 'goro_t04_cat' @(
    @('ねこちゃんのことも、', 84, $BROWN),
    @('ご相談ください。', 84, $BROWN)
) -Bottom 1515
# 23〜30秒: エンドカード（上側。秋田犬は画面下側）
Make-Panel 'goro_t05_end' @(
    @('ごろう動物病院', 112, $BROWN),
    'line',
    @('犬と猫の、', 72, $BROWN),
    @('身近な相談先に。', 72, $BROWN),
    @($NOTE, 46, $SUB)
) -Top 300
