# テロップ画像（1080x1920・透過PNG）を作る
# 使い方: powershell -ExecutionPolicy Bypass -File tools\make_telops.ps1
# 安全領域: 下20%（y>1536）と右端180pxには何も置かない
param(
    [string]$Root = (Split-Path $PSScriptRoot -Parent)
)
Add-Type -AssemblyName System.Drawing

$W = 1080; $H = 1920
$SAFE_BOTTOM = [int]($H * 0.8)   # 1536
$LEFT = 60; $RIGHT = 900         # 右端180pxは空ける
$CX = ($LEFT + $RIGHT) / 2

$fonts = New-Object System.Drawing.Text.PrivateFontCollection
$fonts.AddFontFile((Join-Path $Root 'fonts\MPLUSRounded1c-ExtraBold.ttf'))
$family = $fonts.Families[0]

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
    $rect = Get-RoundRect $LEFT $top ($RIGHT - $LEFT) ($bottom - $top) 48
    $shadow = Get-RoundRect ($LEFT + 6) ($top + 10) ($RIGHT - $LEFT) ($bottom - $top) 48
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

# 本編テロップ: パネル下端を1480に揃える（安全領域1536より上）
function Make-Caption([string]$name, [string]$mainText, [string]$subText) {
    $c = New-Canvas; $bmp = $c[0]; $g = $c[1]
    $bottom = 1480; $top = $bottom - 230
    Draw-Panel $g $top $bottom
    Draw-Text $g $mainText 78 ($top + 85) $BROWN
    Draw-Text $g $subText 42 ($top + 170) $SUB
    $bmp.Save((Join-Path $OUT "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

function Make-Title([string]$name) {
    $c = New-Canvas; $bmp = $c[0]; $g = $c[1]
    $top = 1150; $bottom = 1480
    Draw-Panel $g $top $bottom
    Draw-Text $g 'やさしく、あたたかく。' 44 ($top + 75) $SUB
    Draw-Text $g 'ひだまり' 104 ($top + 170) $BROWN
    Draw-Text $g '動物病院' 72 ($top + 270) $BROWN
    $bmp.Save((Join-Path $OUT "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

function Make-EndCard([string]$name) {
    $c = New-Canvas; $bmp = $c[0]; $g = $c[1]
    $top = 820; $bottom = 1480
    Draw-Panel $g $top $bottom
    Draw-Text $g 'ひだまり動物病院' 76 ($top + 90) $BROWN
    $line = New-Object System.Drawing.Pen $CORAL, 4
    $g.DrawLine($line, $LEFT + 90, $top + 160, $RIGHT - 90, $top + 160)
    Draw-Text $g '診療時間' 38 ($top + 215) $SUB
    Draw-Text $g '9:00〜12:00 ／ 16:00〜19:00' 44 ($top + 275) $BROWN
    Draw-Text $g '休診日　水曜・日曜・祝日' 40 ($top + 350) $BROWN
    Draw-Text $g 'TEL 000-0000-0000' 58 ($top + 440) $BROWN
    Draw-Text $g 'お気軽にご相談ください' 46 ($top + 560) $SUB
    $bmp.Save((Join-Path $OUT "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

Make-Title   'telop_00_title'
Make-Caption 'telop_01_exam'   'ていねいな診察'           '気になることは何でもご相談ください'
Make-Caption 'telop_02_listen' 'からだの声に耳をすませて' '小さな変化も見逃しません'
Make-Caption 'telop_03_owner'  '飼い主さまと一緒に'       '納得できる治療を考えます'
Make-Caption 'telop_04_cat'    'ねこちゃんのケアも'       'トリミング・爪切りもおまかせ'
Make-EndCard 'telop_05_endcard'
Get-ChildItem $OUT | ForEach-Object { $_.Name }
