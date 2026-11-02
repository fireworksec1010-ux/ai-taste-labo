<#
Weekly SNS card (1080x1350, English) from sns\weekly\data.json.
Usage (repo root):
  powershell -ExecutionPolicy Bypass -File scripts\make_weekly_card.ps1 -Theme rice   [-Date 2026-11-06]
  powershell -ExecutionPolicy Bypass -File scripts\make_weekly_card.ps1 -Theme veggie [-Date 2026-11-13]
  powershell -ExecutionPolicy Bypass -File scripts\make_weekly_card.ps1 -Theme news   [-Date 2026-11-20]
Output: sns\weekly\<Date>\card.png  (Date = posting date, default today)
#>
param(
  [Parameter(Mandatory=$true)][ValidateSet('rice','veggie','news')][string]$Theme,
  [string]$Date = (Get-Date).ToString('yyyy-MM-dd')
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repo = Split-Path -Parent $PSScriptRoot
$data = [IO.File]::ReadAllText((Join-Path $repo 'sns\weekly\data.json'), [Text.Encoding]::UTF8) | ConvertFrom-Json
$outDir = Join-Path $repo ("sns\weekly\" + $Date)
New-Item -ItemType Directory -Force $outDir | Out-Null
$inv = [Globalization.CultureInfo]::InvariantCulture

$W = 1080; $H = 1350
function C($hex){ [Drawing.ColorTranslator]::FromHtml($hex) }
$cBg = C '#F9F9F7'; $cInk = C '#0B0B0B'; $cSub = C '#52514E'; $cMuted = C '#898781'; $cGrid = C '#E1E0D9'
$cBlue = C '#2A78D6'; $cRed = C '#D03B3B'; $cGreen = C '#1BAF7A'; $cPurple = C '#8A5CD1'
$FB = [Drawing.FontStyle]::Bold; $FR = [Drawing.FontStyle]::Regular
function F($size, $style){ New-Object Drawing.Font('Segoe UI', $size, $style, [Drawing.GraphicsUnit]::Pixel) }
function T($g, $text, $font, $color, $x, $y){ $br = New-Object Drawing.SolidBrush($color); $g.DrawString([string]$text, $font, $br, [float]$x, [float]$y); $br.Dispose() }
function TBox($g, $text, $font, $color, $x, $y, $w, $h){ $br = New-Object Drawing.SolidBrush($color); $g.DrawString([string]$text, $font, $br, (New-Object Drawing.RectangleF([float]$x, [float]$y, [float]$w, [float]$h))); $br.Dispose() }
function TW($g, $text, $font){ $g.MeasureString([string]$text, $font).Width }
function Fill($g, $color, $x, $y, $w, $h){ $br = New-Object Drawing.SolidBrush($color); $g.FillRectangle($br, [float]$x, [float]$y, [float]$w, [float]$h); $br.Dispose() }
function Fmt($p){ ('{0}{1:0.0}%' -f ($(if($p -ge 0){'+'}else{''}), $p)) }
function Yen($v){ 'JPY ' + ([int]$v).ToString('N0', $inv) }
function DateEn($d){ ([datetime]$d).ToString('MMM d', $inv) }

$bmp = New-Object Drawing.Bitmap($W, $H)
$g = [Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
$g.Clear($cBg)

function Frame($series, $accent, $source){
  Fill $g $accent 0 0 $W 14
  T $g ('JAPAN LABO  |  ' + $series) (F 26 $FB) $accent 72 60
  $wk = 'Posted ' + (([datetime]$Date).ToString('MMM d, yyyy', $inv))
  T $g $wk (F 26 $FB) $cMuted ($W - 72 - (TW $g $wk (F 26 $FB))) 60
  $pen = New-Object Drawing.Pen($cGrid, 2); $g.DrawLine($pen, 72, $H - 130, $W - 72, $H - 130); $pen.Dispose()
  T $g ('Source: ' + $source) (F 24 $FR) $cMuted 72 ($H - 112)
  T $g 'More Japan food data: link in bio' (F 24 $FB) $cSub 72 ($H - 76)
}

switch($Theme){
'rice' {
  $s = @($data.rice_weekly)
  $last = $s[-1]; $prev = $s[-2]
  $wow = ($last.avg / $prev.avg - 1) * 100
  $yoy = $(if($last.yoy_prev_avg){ ($last.avg / $last.yoy_prev_avg - 1) * 100 } else { $null })
  $peak = $data.rice_peak
  $fromPeak = ($last.avg / $peak.avg - 1) * 100
  Frame 'RICE PRICE WATCH' $cBlue 'MAFF, supermarket POS data (approx. 1,000 stores), 5 kg incl. tax'
  T $g 'Rice in Japan, 5 kg bag' (F 40 $FB) $cBlue 72 150
  T $g (Yen $last.avg) (F 120 $FB) $cInk 60 200
  $wkTxt = 'Average supermarket price, week of ' + (DateEn $last.week_start)
  T $g $wkTxt (F 30 $FR) $cSub 72 360
  # three stat chips
  $chips = @(@('vs. last week', (Fmt $wow)), @('vs. a year ago', $(if($null -ne $yoy){ Fmt $yoy } else { 'n/a' })), @(('vs. peak (' + (([datetime]$peak.week_start).ToString('MMM yyyy', $inv)) + ')'), (Fmt $fromPeak)))
  $x = 72; $cw = 300
  foreach($c in $chips){
    Fill $g ([Drawing.Color]::White) $x 430 $cw 140
    $pen = New-Object Drawing.Pen($cGrid, 2); $g.DrawRectangle($pen, $x, 430, $cw, 140); $pen.Dispose()
    T $g $c[0] (F 24 $FR) $cMuted ($x + 20) 446
    $col = $(if($c[1].StartsWith('+')){ $cRed } else { $cBlue })
    T $g $c[1] (F 52 $FB) $col ($x + 16) 486
    $x += $cw + 18
  }
  # line chart: last 16 weeks
  $pts = @($s | Select-Object -Last 16)
  $vals = $pts | ForEach-Object { [double]$_.avg }
  $mn = ($vals | Measure-Object -Minimum).Minimum; $mx = ($vals | Measure-Object -Maximum).Maximum
  $lo = [Math]::Floor(($mn - 150) / 250) * 250; $hi = [Math]::Ceiling(($mx + 150) / 250) * 250
  $x0 = 150; $y0 = 650; $cw2 = 840; $ch = 430; $n = $pts.Count
  $penG = New-Object Drawing.Pen($cGrid, 2)
  for($v = $lo; $v -le $hi; $v += 250){
    $yy = $y0 + $ch - $ch * ($v - $lo) / ($hi - $lo)
    $g.DrawLine($penG, $x0, $yy, $x0 + $cw2, $yy)
    $lb = ([int]$v).ToString('N0', $inv); T $g $lb (F 22 $FR) $cMuted ($x0 - 14 - (TW $g $lb (F 22 $FR))) ($yy - 14)
  }
  $penG.Dispose()
  $ptsF = New-Object 'System.Collections.Generic.List[Drawing.PointF]'
  for($i = 0; $i -lt $n; $i++){ $ptsF.Add((New-Object Drawing.PointF(($x0 + $cw2 * $i / ($n - 1)), ($y0 + $ch - $ch * ($vals[$i] - $lo) / ($hi - $lo))))) }
  $area = New-Object 'System.Collections.Generic.List[Drawing.PointF]'
  $area.Add((New-Object Drawing.PointF($x0, ($y0 + $ch)))); $area.AddRange($ptsF); $area.Add((New-Object Drawing.PointF(($x0 + $cw2), ($y0 + $ch))))
  $fill = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(40, $cBlue)); $g.FillPolygon($fill, $area.ToArray()); $fill.Dispose()
  $line = New-Object Drawing.Pen($cBlue, 6); $line.LineJoin = 'Round'; $g.DrawLines($line, $ptsF.ToArray()); $line.Dispose()
  foreach($i in @(0, [int](($n - 1) / 2), ($n - 1))){
    $lb = DateEn $pts[$i].week_start; $px = $ptsF[$i].X
    T $g $lb (F 22 $FR) $cMuted ($px - (TW $g $lb (F 22 $FR)) / 2) ($y0 + $ch + 12)
  }
  $lp = $ptsF[$n - 1]
  $br = New-Object Drawing.SolidBrush($cBg); $g.FillEllipse($br, $lp.X - 11, $lp.Y - 11, 22, 22); $br.Dispose()
  $pen = New-Object Drawing.Pen($cBlue, 6); $g.DrawEllipse($pen, $lp.X - 11, $lp.Y - 11, 22, 22); $pen.Dispose()
  T $g 'Weekly average price, last 16 weeks (JPY per 5 kg)' (F 24 $FR) $cMuted 72 1140
}
'veggie' {
  $wk = @($data.veggie_weekly)[-1]
  Frame 'VEGGIE PRICE CHECK' $cGreen 'MAFF, retail price survey (470 stores), vs. 5-year average'
  T $g 'Vegetable prices in Japan' (F 40 $FB) $cGreen 72 150
  T $g 'vs. a normal year' (F 84 $FB) $cInk 64 200
  T $g ('Week of ' + (DateEn $wk.week_start) + '. 100% = 5-year average price') (F 30 $FR) $cSub 72 320
  $items = @($wk.items | Sort-Object { [int]$_.vs_normal } -Descending)
  $maxV = ($items | ForEach-Object { [int]$_.vs_normal } | Measure-Object -Maximum).Maximum
  $scaleMax = [Math]::Max(200, [Math]::Ceiling($maxV / 50) * 50)
  $x0 = 330; $bw = 600; $y = 410
  $base = $x0 + $bw * 100 / $scaleMax
  foreach($it in $items){
    $len = $bw * [int]$it.vs_normal / $scaleMax
    $col = $(if([int]$it.vs_normal -gt 110){ $cRed } elseif([int]$it.vs_normal -lt 90){ $cBlue } else { C '#B8B6AE' })
    Fill $g $col $x0 $y $len 62
    T $g $it.en (F 30 $FB) $cInk ($x0 - 20 - (TW $g $it.en (F 30 $FB))) ($y - 2)
    $lb = ([string]$it.vs_normal + '%')
    T $g $lb (F 30 $FB) $col ($x0 + $len + 12) ($y + 12)
    T $g ('JPY ' + ([int]$it.price).ToString('N0', $inv) + '/kg') (F 20 $FR) $cMuted ($x0 - 20 - (TW $g ('JPY ' + ([int]$it.price).ToString('N0', $inv) + '/kg') (F 20 $FR))) ($y + 40)
    $y += 88
  }
  $pen = New-Object Drawing.Pen($cInk, 3); $pen.DashStyle = 'Dash'; $g.DrawLine($pen, $base, 395, $base, ($y + 4)); $pen.Dispose()
  T $g '100% = normal' (F 22 $FB) $cSub ($base - 70) ($y + 10)
  T $g 'Red: over 110% (pricier than normal)   Blue: under 90%   Gray: normal range' (F 24 $FR) $cMuted 72 1160
}
'news' {
  $wk = @($data.news_weekly)[-1]
  if(-not $wk){ throw 'news_weekly is empty' }
  Frame 'NEW IN JAPAN' $cPurple 'Company press releases (PR TIMES)'
  T $g 'New food products in Japan' (F 40 $FB) $cPurple 72 150
  T $g 'this week' (F 96 $FB) $cInk 62 196
  $y = 360
  $k = 1
  foreach($p in @($wk.products | Select-Object -First 3)){
    Fill $g ([Drawing.Color]::White) 72 $y ($W - 144) 240
    $pen = New-Object Drawing.Pen($cGrid, 2); $g.DrawRectangle($pen, 72, $y, ($W - 144), 240); $pen.Dispose()
    Fill $g $cPurple 72 $y 12 240
    T $g ([string]$k) (F 64 $FB) $cPurple 104 ($y + 20)
    T $g ($p.company_en + '  |  ' + (DateEn $p.date)) (F 26 $FB) $cMuted 180 ($y + 26)
    TBox $g $p.name_en (F 38 $FB) $cInk 180 ($y + 62) 800 100
    TBox $g $p.point_en (F 26 $FR) $cSub 180 ($y + 160) 800 76
    $y += 262; $k++
  }
}
}

$out = Join-Path $outDir 'card.png'
$bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
$out
