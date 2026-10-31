# テロップ再設計版の画像（1080x1920・透過PNG）を作る
# 使い方: powershell -ExecutionPolicy Bypass -File tools\make_telops_redesign.ps1
# 書体: Noto Sans JP（fonts\NotoSansJP-VF.ttf を Windows にインストールしておく）
#
# 配置ルール
#  ・文字は白・左揃え。左端 x=90、右端は x=900 より内側（右側180pxは空ける）
#  ・メッセージ（診察・犬・猫）: SemiBold 72px、行送り1.6倍、最大2行、文字の下端を y=1420 にそろえる
#  ・タイトル（冒頭・エンドカード）: 注記 Medium 36px → 病院名 Bold 104px → 一言 Medium 52px を上側にまとめる
#    （冒頭の猫・最後の秋田犬は画面下側に顔があるため、タイトルだけ上に置く）
#  ・囲み枠・線・アイコンは使わない。明るい場面だけ画面の上か下に薄い黒のグラデーションを敷く
param(
    [string]$Root = (Split-Path $PSScriptRoot -Parent)
)
Add-Type -AssemblyName System.Drawing

$W = 1080; $H = 1920
$LEFT = 90; $RIGHT = 900
$MSG_BOTTOM = 1420
$TITLE_TOP = 270

$FAM_BOLD = New-Object System.Drawing.FontFamily 'Noto Sans JP'
$FAM_SEMI = New-Object System.Drawing.FontFamily 'Noto Sans JP SemiBold'
$FAM_MED  = New-Object System.Drawing.FontFamily 'Noto Sans JP Medium'
$WHITE = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
$SOFT  = [System.Drawing.Color]::FromArgb(230, 255, 255, 255)   # 注記用（少し控えめ）
$OUT = Join-Path $Root 'media'

# 'Noto Sans JP' は太字スタイルを指定すると Bold のインスタンスになる
function Get-Style($family) { if ($family.Name -eq 'Noto Sans JP') { 1 } else { 0 } }

function New-Canvas {
    $bmp = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.Clear([System.Drawing.Color]::Transparent)
    return @($bmp, $g)
}

# 縦方向のグラデーション（y0で透明 → y1で最大の濃さ、y1から先は同じ濃さ）
function Draw-Shade($g, [int]$y0, [int]$y1, [int]$alpha) {
    $top = [Math]::Min($y0, $y1); $bottom = [Math]::Max($y0, $y1)
    $rect = New-Object System.Drawing.Rectangle 0, $top, $W, ($bottom - $top)
    $c0 = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)
    $c1 = [System.Drawing.Color]::FromArgb($alpha, 0, 0, 0)
    if ($y0 -lt $y1) { $a = $c0; $b = $c1 } else { $a = $c1; $b = $c0 }
    # ブラシの範囲を少し広げて、端に線が出ないようにする
    $brushRect = New-Object System.Drawing.Rectangle 0, ($top - 2), $W, ($bottom - $top + 4)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $brushRect, $a, $b, 90
    $g.SmoothingMode = 'None'   # 境目のにじみを防ぐ
    $g.FillRectangle($brush, $rect)
    $solid = New-Object System.Drawing.SolidBrush $c1
    if ($y0 -lt $y1) { $g.FillRectangle($solid, 0, $y1, $W, $H - $y1) } else { $g.FillRectangle($solid, 0, 0, $W, $y1) }
    $g.SmoothingMode = 'AntiAlias'
}

# 1行の文字（左揃え）。glyphTop = 文字の上端。返り値は文字の下端
function Draw-Line($g, [string]$text, $family, [float]$size, [float]$glyphTop, $color) {
    $fmt = [System.Drawing.StringFormat]::GenericTypographic
    # 可変フォントは輪郭が重なるので Winding で塗る（Alternate だと重なりが抜ける）
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath ([System.Drawing.Drawing2D.FillMode]::Winding)
    $path.AddString($text, $family, (Get-Style $family), $size, (New-Object System.Drawing.PointF 0, 0), $fmt)
    $b = $path.GetBounds()
    $m = New-Object System.Drawing.Drawing2D.Matrix
    $m.Translate($LEFT - $b.Left, $glyphTop - $b.Top)
    $path.Transform($m)
    $b = $path.GetBounds()
    if ($b.Right -gt $RIGHT) { throw "「$text」が右側の余白に入ります（右端 $([int]$b.Right)）" }
    # ごく薄い影（読みやすさのためのにじみ程度）
    foreach ($s in @(@(9, 14), @(5, 20), @(2, 26))) {
        $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($s[1], 0, 0, 0)), $s[0]
        $pen.LineJoin = 'Round'
        $g.DrawPath($pen, $path)
    }
    $g.FillPath((New-Object System.Drawing.SolidBrush $color), $path)
    return $b.Bottom
}

# 文字の高さ（漢字の上端〜下端）を測る
function Get-GlyphHeight($family, [float]$size) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddString('国', $family, (Get-Style $family), $size, (New-Object System.Drawing.PointF 0, 0), [System.Drawing.StringFormat]::GenericTypographic)
    return $path.GetBounds().Height
}

function Save($bmp, $g, [string]$name) {
    $bmp.Save((Join-Path $OUT "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

# メッセージ（2行・下端 y=1420）。-Shade で画面下に薄い黒のグラデーション
function Make-Message([string]$name, [string]$line1, [string]$line2, [switch]$Shade) {
    $size = 72; $pitch = $size * 1.6
    $gh = Get-GlyphHeight $FAM_SEMI $size
    $top2 = $MSG_BOTTOM - $gh; $top1 = $top2 - $pitch
    $c = New-Canvas; $bmp = $c[0]; $g = $c[1]
    if ($Shade) { Draw-Shade $g 1000 1560 120 }
    [void](Draw-Line $g $line1 $FAM_SEMI $size $top1 $WHITE)
    [void](Draw-Line $g $line2 $FAM_SEMI $size $top2 $WHITE)
    Save $bmp $g $name
    "{0}: y={1:0}-{2:0}" -f $name, $top1, $MSG_BOTTOM
}

# タイトルの各行の位置（注記・病院名・一言）
$NOTE_SIZE = 36; $NAME_SIZE = 104; $SUB_SIZE = 52
$noteTop = $TITLE_TOP
$nameTop = $noteTop + (Get-GlyphHeight $FAM_MED $NOTE_SIZE) + 34
$subTop  = $nameTop + (Get-GlyphHeight $FAM_BOLD $NAME_SIZE) + 40
$NOTE = '架空の動物病院／紹介動画サンプル'

# 冒頭 0〜7秒: 注記＋病院名（上側に薄いグラデーション。猫の白い毛の上でも読めるように）
$c = New-Canvas; $bmp = $c[0]; $g = $c[1]
Draw-Shade $g 760 300 125
[void](Draw-Line $g $NOTE $FAM_MED $NOTE_SIZE $noteTop $SOFT)
$nameBottom = Draw-Line $g 'ごろう動物病院' $FAM_BOLD $NAME_SIZE $nameTop $WHITE
Save $bmp $g 'goro_r00_name'
"goro_r00_name: y={0}-{1:0}" -f $noteTop, $nameBottom

# 冒頭 0〜3秒: 一言（病院名の少しあとにフェードインで出す）
$c = New-Canvas; $bmp = $c[0]; $g = $c[1]
$subBottom = Draw-Line $g '大切な家族の、いつもの相談先。' $FAM_MED $SUB_SIZE $subTop $WHITE
Save $bmp $g 'goro_r01_catch'
"goro_r01_catch: y={0:0}-{1:0}" -f $subTop, $subBottom

# 中盤のメッセージ（同じ文字組み・同じ位置）
Make-Message 'goro_r02_exam' '小さな変化も、' 'ていねいに。' -Shade      # 白い診察台・壁
Make-Message 'goro_r03_dog'  'おうちでの様子も、' 'お聞かせください。'     # 木の床で暗め
Make-Message 'goro_r04_cat'  'ねこちゃんのことも、' 'ご相談ください。' -Shade  # 白いソファ

# エンドカード 23〜30秒: 映像全体を少し暗くし、上側（桜の部分）に冒頭と同じ組み方で置く
$c = New-Canvas; $bmp = $c[0]; $g = $c[1]
$g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(56, 0, 0, 0))), 0, 0, $W, $H)
Draw-Shade $g 820 300 110
[void](Draw-Line $g $NOTE $FAM_MED $NOTE_SIZE $noteTop $SOFT)
[void](Draw-Line $g 'ごろう動物病院' $FAM_BOLD $NAME_SIZE $nameTop $WHITE)
$endBottom = Draw-Line $g '犬と猫の、身近な相談先に。' $FAM_MED $SUB_SIZE $subTop $WHITE
Save $bmp $g 'goro_r05_end'
"goro_r05_end: y={0}-{1:0}" -f $noteTop, $endBottom
