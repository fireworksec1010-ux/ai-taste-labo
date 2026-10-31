<#
Instagram carousel images (1080x1350) for the monthly update.
Usage (repo root):
  powershell -ExecutionPolicy Bypass -File scripts\make_instagram.ps1 -Month 2026-09 -Label "October 2026"
Output: sns\<Month>\ig_1.png ... ig_4.png
#>
param(
  [string]$Month = '2026-09',
  [string]$Label = 'October 2026'
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repo = Split-Path -Parent $PSScriptRoot
$utf8 = [Text.Encoding]::UTF8
$food = [IO.File]::ReadAllText((Join-Path $repo 'data.json'), $utf8) | ConvertFrom-Json
$veg  = [IO.File]::ReadAllText((Join-Path $repo 'vegetables_data.json'), $utf8) | ConvertFrom-Json
$outDir = Join-Path $repo ("sns\" + $Month)
New-Item -ItemType Directory -Force $outDir | Out-Null

$W = 1080; $H = 1350
function C($hex){ [Drawing.ColorTranslator]::FromHtml($hex) }
$cBg = C '#F9F9F7'; $cInk = C '#0B0B0B'; $cSub = C '#52514E'; $cMuted = C '#898781'; $cGrid = C '#E1E0D9'
$cBlue = C '#2A78D6'; $cRed = C '#D03B3B'; $cGreen = C '#1BAF7A'; $cOil = C '#E8A100'
$fontName = 'Segoe UI'
function F($size, $style){ New-Object Drawing.Font($fontName, $size, $style, [Drawing.GraphicsUnit]::Pixel) }
$FB = [Drawing.FontStyle]::Bold; $FR = [Drawing.FontStyle]::Regular

function New-Slide(){
  $bmp = New-Object Drawing.Bitmap($W, $H)
  $g = [Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
  $g.Clear($cBg)
  return @($bmp, $g)
}
function T($g, $text, $font, $color, $x, $y){
  $br = New-Object Drawing.SolidBrush($color); $g.DrawString($text, $font, $br, [float]$x, [float]$y); $br.Dispose()
}
function TW($g, $text, $font){ $g.MeasureString($text, $font).Width }
function Frame($g, $page, $accent){
  $br = New-Object Drawing.SolidBrush($accent); $g.FillRectangle($br, 0, 0, $W, 14); $br.Dispose()
  T $g 'JAPAN LABO  |  FOOD PRICES' (F 26 $FB) $accent 72 60
  $pg = "$page / 4"; T $g $pg (F 26 $FB) $cMuted ($W - 72 - (TW $g $pg (F 26 $FB))) 60
  $pen = New-Object Drawing.Pen($cGrid, 2); $g.DrawLine($pen, 72, $H - 130, $W - 72, $H - 130); $pen.Dispose()
  T $g 'Source: Statistics Bureau of Japan, Consumer Price Index (2025 = 100)' (F 24 $FR) $cMuted 72 ($H - 112)
  T $g 'Monthly digest: link in bio' (F 24 $FB) $cSub 72 ($H - 76)
}
function Save($bmp, $g, $name){ $p = Join-Path $outDir $name; $bmp.Save($p, [Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose(); $p }

function Line-Chart($g, $pts, $x0, $y0, $cw, $ch, $color, $tickEvery, $labelFmt){
  $vals = $pts | ForEach-Object { [double]$_.value }
  $mn = ($vals | Measure-Object -Minimum).Minimum; $mx = ($vals | Measure-Object -Maximum).Maximum
  $pad = ($mx - $mn) * 0.15; $lo = [Math]::Floor(($mn - $pad) / 10) * 10; $hi = [Math]::Ceiling(($mx + $pad) / 10) * 10
  $n = $pts.Count
  $sx = { param($i) $x0 + 70 + ($cw - 90) * $i / ($n - 1) }.GetNewClosure()
  $sy = { param($v) $y0 + $ch - $ch * ($v - $lo) / ($hi - $lo) }.GetNewClosure()
  $penG = New-Object Drawing.Pen($cGrid, 2)
  for($v = $lo; $v -le $hi; $v += 20){
    $yy = & $sy $v; $g.DrawLine($penG, $x0 + 70, $yy, $x0 + $cw - 20, $yy)
    T $g ([string]$v) (F 22 $FR) $cMuted $x0 ($yy - 14)
  }
  $penG.Dispose()
  for($i = 0; $i -lt $n; $i++){
    if(($i % $tickEvery) -eq 0){ $lb = & $labelFmt $pts[$i].ym; T $g $lb (F 22 $FR) $cMuted ((& $sx $i) - (TW $g $lb (F 22 $FR)) / 2) ($y0 + $ch + 12) }
  }
  # area + line
  $poly = New-Object 'System.Collections.Generic.List[Drawing.PointF]'
  $poly.Add((New-Object Drawing.PointF((& $sx 0), ($y0 + $ch))))
  for($i = 0; $i -lt $n; $i++){ $poly.Add((New-Object Drawing.PointF((& $sx $i), (& $sy ([double]$pts[$i].value))))) }
  $poly.Add((New-Object Drawing.PointF((& $sx ($n - 1)), ($y0 + $ch))))
  $fill = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(40, $color)); $g.FillPolygon($fill, $poly.ToArray()); $fill.Dispose()
  $line = New-Object Drawing.Pen($color, 6); $line.LineJoin = 'Round'
  $g.DrawLines($line, $poly.GetRange(1, $n).ToArray()); $line.Dispose()
  return @{ sx = $sx; sy = $sy }
}
function Dot($g, $x, $y, $color){
  $br = New-Object Drawing.SolidBrush($cBg); $g.FillEllipse($br, $x - 11, $y - 11, 22, 22); $br.Dispose()
  $pen = New-Object Drawing.Pen($color, 6); $g.DrawEllipse($pen, $x - 11, $y - 11, 22, 22); $pen.Dispose()
}
function Pct($a, $b){ ($a / $b - 1) * 100 }
function Fmt($p){ ('{0}{1:0.0}%' -f ($(if($p -ge 0){'+'}else{''}), $p)) }
function Series($items, $key){ ($items | Where-Object { $_.key -eq $key }).cpi_index_monthly }
function At($s, $ym){ ($s | Where-Object { $_.ym -eq $ym }).value }
$prevYm = ([datetime]($Month + '-01')).AddMonths(-1).ToString('yyyy-MM')
$yoyYm  = ([datetime]($Month + '-01')).AddYears(-1).ToString('yyyy-MM')
$monName = ([datetime]($Month + '-01')).ToString('MMMM', [Globalization.CultureInfo]::InvariantCulture)
$shortYm = { param($ym) $d = [datetime]($ym + '-01'); $d.ToString("MMM \'yy", [Globalization.CultureInfo]::InvariantCulture) }

$rice = Series $food.items 'rice'; $oil = Series $food.items 'cooking_oil'
$riceNow = At $rice $Month; $riceYoy = Pct $riceNow (At $rice $yoyYm)
$ricePeak = $rice | Sort-Object { [double]$_.value } -Descending | Select-Object -First 1
$oilNow = At $oil $Month; $oilYoy = Pct $oilNow (At $oil $yoyYm)
$lett = Series $veg.items 'lettuce'; $lettMom = Pct (At $lett $Month) (At $lett $prevYm)

# ---------- 1: cover
$s = New-Slide; $g = $s[1]
Frame $g 1 $cBlue
T $g $Label (F 40 $FB) $cBlue 72 200
T $g "What changed in" (F 92 $FB) $cInk 66 260
T $g "Japan's food prices" (F 92 $FB) $cInk 66 370
T $g "$monName consumer price data, item by item" (F 34 $FR) $cSub 72 500
$rows = @(
  @('Rice', (Fmt $riceYoy), 'vs. a year ago', $cBlue),
  @('Cooking oil', (Fmt $oilYoy), 'vs. a year ago', $cOil),
  @('Lettuce', (Fmt $lettMom), 'vs. last month', $cGreen)
)
$y = 640
foreach($r in $rows){
  $br = New-Object Drawing.SolidBrush([Drawing.Color]::White); $g.FillRectangle($br, 72, $y, $W - 144, 150); $br.Dispose()
  $pen = New-Object Drawing.Pen($cGrid, 2); $g.DrawRectangle($pen, 72, $y, $W - 144, 150); $pen.Dispose()
  $br = New-Object Drawing.SolidBrush($r[3]); $g.FillRectangle($br, 72, $y, 12, 150); $br.Dispose()
  T $g $r[0] (F 44 $FB) $cInk 116 ($y + 28)
  T $g $r[2] (F 28 $FR) $cMuted 116 ($y + 88)
  $numColor = $(if($r[1].StartsWith('+')){ $cRed } else { $cBlue })
  T $g $r[1] (F 76 $FB) $numColor ($W - 100 - (TW $g $r[1] (F 76 $FB))) ($y + 26)
  $y += 180
}
T $g 'Swipe for the charts  >' (F 30 $FB) $cSub 72 1180
Save $s[0] $g 'ig_1.png'

# ---------- 2: rice
$s = New-Slide; $g = $s[1]
Frame $g 2 $cBlue
T $g ('Rice: ' + (Fmt $riceYoy) + ' in a year') (F 66 $FB) $cInk 66 140
T $g ('Now ' + $riceNow + ', down from the ' + $ricePeak.value + ' peak (' + ([datetime]($ricePeak.ym + '-01')).ToString('MMMM yyyy', [Globalization.CultureInfo]::InvariantCulture) + ')') (F 32 $FR) $cSub 72 240
T $g 'as the new 2026 harvest reaches stores' (F 32 $FR) $cSub 72 284
$pts = @($rice | Where-Object { $_.ym -ge '2024-01' -and $_.ym -le $Month })
$m = Line-Chart $g $pts 60 400 ($W - 120) 640 $cBlue 6 $shortYm
$ip = [array]::IndexOf(($pts | ForEach-Object { $_.ym }), $ricePeak.ym)
$px = & $m.sx $ip; $py = & $m.sy ([double]$ricePeak.value); Dot $g $px $py $cRed
T $g ('Peak ' + $ricePeak.value) (F 30 $FB) $cRed ($px - 150) ($py - 56)
$lx = & $m.sx ($pts.Count - 1); $ly = & $m.sy ([double]$riceNow); Dot $g $lx $ly $cBlue
T $g ([string]$riceNow) (F 34 $FB) $cBlue ($lx - 80) ($ly + 20)
T $g 'Rice CPI index, monthly (2025 = 100)' (F 26 $FR) $cMuted 72 1110
Save $s[0] $g 'ig_2.png'

# ---------- 3: cooking oil
$s = New-Slide; $g = $s[1]
Frame $g 3 $cOil
T $g ('Cooking oil: ' + (Fmt $oilYoy)) (F 66 $FB) $cInk 66 140
T $g ('Index ' + $oilNow + ' in ' + $monName + ': the highest since 2015') (F 32 $FR) $cSub 72 240
T $g 'Makers raised oil prices again this year' (F 32 $FR) $cSub 72 284
$pts = @($oil | Where-Object { $_.ym -ge '2015-01' -and $_.ym -le $Month })
$m = Line-Chart $g $pts 60 400 ($W - 120) 640 $cOil 24 { param($ym) $ym.Substring(0,4) }
$lx = & $m.sx ($pts.Count - 1); $ly = & $m.sy ([double]$oilNow); Dot $g $lx $ly $cRed
T $g ([string]$oilNow) (F 34 $FB) $cRed ($lx - 100) ($ly - 60)
T $g 'Cooking oil CPI index, monthly (2025 = 100)' (F 26 $FR) $cMuted 72 1110
Save $s[0] $g 'ig_3.png'

# ---------- 4: vegetables
$s = New-Slide; $g = $s[1]
Frame $g 4 $cGreen
T $g 'Vegetables: big swings' (F 66 $FB) $cInk 66 140
T $g ("Price change from " + ([datetime]($prevYm + '-01')).ToString('MMMM', [Globalization.CultureInfo]::InvariantCulture) + " to " + $monName) (F 32 $FR) $cSub 72 240
$names = [ordered]@{ lettuce='Lettuce'; tomato='Tomato'; green_onion='Green onion'; carrot='Carrot'; cucumber='Cucumber'; cabbage='Cabbage'; onion='Onion'; potato='Potato' }
$bars = foreach($k in $names.Keys){ $sr = Series $veg.items $k; [pscustomobject]@{ name = $names[$k]; p = (Pct (At $sr $Month) (At $sr $prevYm)) } }
$bars = $bars | Sort-Object p -Descending
$maxAbs = ($bars | ForEach-Object { [Math]::Abs($_.p) } | Measure-Object -Maximum).Maximum
$zeroX = 520; $half = 380; $y = 360
$pen = New-Object Drawing.Pen($cMuted, 2); $g.DrawLine($pen, $zeroX, 340, $zeroX, 1080); $pen.Dispose()
foreach($b in $bars){
  $len = $half * [Math]::Abs($b.p) / $maxAbs
  $col = $(if($b.p -ge 0){ $cRed } else { $cBlue })
  $br = New-Object Drawing.SolidBrush($col)
  if($b.p -ge 0){ $g.FillRectangle($br, $zeroX, $y, [float]$len, 58) } else { $g.FillRectangle($br, [float]($zeroX - $len), $y, [float]$len, 58) }
  $br.Dispose()
  $txt = Fmt $b.p
  if($b.p -ge 0){
    T $g $b.name (F 34 $FB) $cInk ($zeroX - 24 - (TW $g $b.name (F 34 $FB))) ($y + 6)
    T $g $txt (F 32 $FB) $cRed ($zeroX + $len + 12) ($y + 8)
  } else {
    T $g $b.name (F 34 $FB) $cInk ($zeroX + 24) ($y + 6)
    T $g $txt (F 32 $FB) $cBlue ($zeroX - $len - 12 - (TW $g $txt (F 32 $FB))) ($y + 8)
  }
  $y += 88
}
T $g 'Vegetable CPI, month-on-month change' (F 26 $FR) $cMuted 72 1110
Save $s[0] $g 'ig_4.png'
