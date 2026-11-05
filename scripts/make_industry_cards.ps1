<#
SNS images (1080x1350, English) for the food industry map, from industry_map_data.json.
Usage (repo root): powershell -ExecutionPolicy Bypass -File scripts\make_industry_cards.ps1 -OutName 2026-11-industry
Output: sns\<OutName>\ig_1.png ... ig_4.png
#>
param([string]$OutName = '2026-11-industry')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repo = Split-Path -Parent $PSScriptRoot
$data = [IO.File]::ReadAllText((Join-Path $repo 'industry_map_data.json'), [Text.Encoding]::UTF8) | ConvertFrom-Json
$outDir = Join-Path $repo ("sns\" + $OutName)
New-Item -ItemType Directory -Force $outDir | Out-Null
$inv = [Globalization.CultureInfo]::InvariantCulture

$EN = @{ '2802'='Ajinomoto'; '2801'='Kikkoman'; '2809'='Kewpie'; '2810'='House Foods'; '2811'='Kagome';
  '1332'='Nissui'; '2871'='Nichirei'; '1333'='Umios'; '2897'='Nissin Foods'; '2875'='Toyo Suisan (Maruchan)';
  '2206'='Ezaki Glico'; '2201'='Morinaga & Co.'; '2229'='Calbee'; '2226'='Koikeya'; '2220'='Kameda Seika';
  '2269'='Meiji'; '2270'='Megmilk Snow Brand'; '2264'='Morinaga Milk'; '2212'='Yamazaki Baking'; '2002'='Nisshin Seifun' }
$cs = foreach($c in $data.companies){
  [pscustomobject]@{ en = $EN[[string]$c.code]; sales = [double]$c.sales; op = [double]$c.op;
    g = ([double]$c.sales / [double]$c.sales_prev - 1) * 100; opg = ([double]$c.op / [double]$c.op_prev - 1) * 100;
    m = [double]$c.op / [double]$c.sales * 100 }
}
$total = ($cs | Measure-Object sales -Sum).Sum
$up = @($cs | Where-Object { $_.g -gt 0 }).Count
$opUp = @($cs | Where-Object { $_.opg -gt 0 }).Count

$W = 1080; $H = 1350
function C($hex){ [Drawing.ColorTranslator]::FromHtml($hex) }
$cBg = C '#F9F9F7'; $cInk = C '#0B0B0B'; $cSub = C '#52514E'; $cMuted = C '#898781'; $cGrid = C '#E1E0D9'
$cPurple = C '#8A5CD1'; $cBlue = C '#2A78D6'; $cRed = C '#D03B3B'; $cGreen = C '#1BAF7A'; $cOrange = C '#EB6834'
$FB = [Drawing.FontStyle]::Bold; $FR = [Drawing.FontStyle]::Regular
function F($size, $style){ New-Object Drawing.Font('Segoe UI', $size, $style, [Drawing.GraphicsUnit]::Pixel) }
function T($g, $text, $font, $color, $x, $y){ $br = New-Object Drawing.SolidBrush($color); $g.DrawString([string]$text, $font, $br, [float]$x, [float]$y); $br.Dispose() }
function TW($g, $text, $font){ $g.MeasureString([string]$text, $font).Width }
function Fill($g, $color, $x, $y, $w, $h){ $br = New-Object Drawing.SolidBrush($color); $g.FillRectangle($br, [float]$x, [float]$y, [float]$w, [float]$h); $br.Dispose() }
function Bn($oku){ 'JPY ' + ($oku / 10).ToString('N0', $inv) + ' bn' }

function Slide($page, $accent, $draw){
  $bmp = New-Object Drawing.Bitmap($W, $H); $g = [Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'; $g.Clear($cBg)
  Fill $g $accent 0 0 $W 14
  T $g 'JAPAN LABO  |  FOOD INDUSTRY MAP' (F 26 $FB) $accent 72 60
  $pg = "$page / 4"; T $g $pg (F 26 $FB) $cMuted ($W - 72 - (TW $g $pg (F 26 $FB))) 60
  $pen = New-Object Drawing.Pen($cGrid, 2); $g.DrawLine($pen, 72, $H - 130, $W - 72, $H - 130); $pen.Dispose()
  T $g 'Source: company earnings reports, latest fiscal year (consolidated)' (F 24 $FR) $cMuted 72 ($H - 112)
  T $g 'Full map of 20 companies: link in bio' (F 24 $FB) $cSub 72 ($H - 76)
  & $draw $g
  $p = Join-Path $outDir ("ig_$page.png"); $bmp.Save($p, [Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose(); $p
}

function Bars($g, $rows, $valueOf, $labelOf, $color, $y0, $rowH){
  $max = ($rows | ForEach-Object { & $valueOf $_ } | Measure-Object -Maximum).Maximum
  $x0 = 420; $bw = 400; $y = $y0
  foreach($r in $rows){
    $len = $bw * (& $valueOf $r) / $max
    T $g $r.en (F 30 $FB) $cInk ($x0 - 20 - (TW $g $r.en (F 30 $FB))) ($y + 8)
    Fill $g $color $x0 $y $len ($rowH - 26)
    T $g (& $labelOf $r) (F 28 $FB) $color ($x0 + $len + 12) ($y + 8)
    $y += $rowH
  }
}

# 1: cover
Slide 1 $cPurple {
  param($g)
  T $g "Japan's 20 biggest" (F 92 $FB) $cInk 64 170
  T $g 'food makers' (F 92 $FB) $cInk 64 280
  T $g 'Who they are, how big, and who is growing' (F 34 $FR) $cSub 72 410
  $tiles = @(
    @(('JPY ' + ($total / 10000).ToString('0.0', $inv) + ' trillion'), 'combined annual sales', $cPurple),
    @("$up of 20", 'grew sales vs. the previous year', $cGreen),
    @("$opUp of 20", 'grew operating profit', $cBlue)
  )
  $y = 520
  foreach($t in $tiles){
    Fill $g ([Drawing.Color]::White) 72 $y ($W - 144) 170
    $pen = New-Object Drawing.Pen($cGrid, 2); $g.DrawRectangle($pen, 72, $y, ($W - 144), 170); $pen.Dispose()
    Fill $g $t[2] 72 $y 12 170
    T $g $t[0] (F 70 $FB) $t[2] 110 ($y + 20)
    T $g $t[1] (F 30 $FR) $cSub 116 ($y + 112)
    $y += 196
  }
} | Out-Null

# 2: top 10 by sales
Slide 2 $cPurple {
  param($g)
  T $g 'Top 10 by sales' (F 72 $FB) $cInk 64 140
  T $g 'Annual sales, latest fiscal year (JPY billion)' (F 32 $FR) $cSub 72 250
  $rows = @($cs | Sort-Object sales -Descending | Select-Object -First 10)
  Bars $g $rows { param($r) $r.sales } { param($r) ($r.sales / 10).ToString('N0', $inv) } $cPurple 340 76
} | Out-Null

# 3: fastest growth
Slide 3 $cGreen {
  param($g)
  T $g 'Fastest sales growth' (F 72 $FB) $cInk 64 140
  T $g 'Change in annual sales vs. the previous year' (F 32 $FR) $cSub 72 250
  $rows = @($cs | Sort-Object g -Descending | Select-Object -First 6)
  Bars $g $rows { param($r) $r.g } { param($r) ('+' + $r.g.ToString('0.0', $inv) + '%') } $cGreen 360 110
  T $g 'Kameda Seika: boosted by its June 2025 acquisition of US snack maker TH Foods' (F 24 $FR) $cMuted 72 1040
} | Out-Null

# 4: highest margin
Slide 4 $cOrange {
  param($g)
  T $g 'Most profitable' (F 72 $FB) $cInk 64 140
  T $g 'Operating margin (operating profit / sales)' (F 32 $FR) $cSub 72 250
  $rows = @($cs | Sort-Object m -Descending | Select-Object -First 6)
  Bars $g $rows { param($r) $r.m } { param($r) ($r.m.ToString('0.0', $inv) + '%') } $cOrange 360 110
  T $g 'Instant noodles lead: Maruchan sells strongly in the US and Mexico' (F 24 $FR) $cMuted 72 1040
  T $g "Ajinomoto's profit includes one-time gains such as asset sales" (F 24 $FR) $cMuted 72 1076
} | Out-Null
Get-ChildItem $outDir -Filter 'ig_*.png' | ForEach-Object { $_.FullName }
