<#
食品価格（data.json）・野菜価格（vegetables_data.json）の CPI データを最新化するスクリプト。

使い方（リポジトリ直下で実行）:
  powershell -ExecutionPolicy Bypass -File scripts\update_cpi.ps1            # 更新する
  powershell -ExecutionPolicy Bypass -File scripts\update_cpi.ps1 -DryRun    # 確認だけ（ファイルは書き換えない）

e-Stat の統計表ID（statInfId）が変わった場合は -MonthlyId / -AnnualId で指定する。
一覧ページ: https://www.e-stat.go.jp/stat-search/files?page=1&toukei=00200573&tstat=000001243876
（長期時系列データ → 品目別価格指数 → 全国 → 月次／年平均 の「品目別価格指数（1970年～最新）」）
#>
param(
  [string]$MonthlyId = '000040482945',
  [string]$AnnualId  = '000040482831',
  [switch]$DryRun,
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$today = (Get-Date).ToString('yyyy-MM-dd')
$sjis = [System.Text.Encoding]::GetEncoding('shift_jis')
$utf8 = [System.Text.Encoding]::UTF8

$foodCodes = [ordered]@{ rice='0004'; bread='1021'; egg='1341'; milk='1303'; cooking_oil='1601'; instant_noodles='1051'; pork='1211'; soy_sauce='1621' }
$vegCodes  = [ordered]@{ cabbage='1401'; green_onion='1405'; lettuce='1406'; potato='1412'; onion='1417'; cucumber='1434'; tomato='1436'; carrot='1415' }

function Fail($msg){ Write-Host "中止: $msg" -ForegroundColor Red; exit 1 }

function Get-Cpi($id){
  $tmp = Join-Path $env:TEMP "cpi_$id.csv"
  $url = "https://www.e-stat.go.jp/stat-search/file-download?statInfId=$id&fileKind=1"
  Invoke-WebRequest -Uri $url -OutFile $tmp -UserAgent 'Mozilla/5.0' -TimeoutSec 120 -UseBasicParsing
  $lines = $sjis.GetString([IO.File]::ReadAllBytes($tmp)) -split "`r?`n"
  if($lines.Count -lt 10 -or $lines[0] -notmatch '類・品目'){ Fail "統計表 $id の形式が想定と違います（先頭行: $($lines[0].Substring(0,[Math]::Min(40,$lines[0].Length)))）" }
  $codes = $lines[2] -split ','
  $rows = @($lines | Where-Object { $_ -match '^\s*\d{4}' })
  return @{ codes=$codes; rows=$rows; url=$url }
}

function Get-Series($cpi, $code, $monthly){
  $idx = [array]::IndexOf($cpi.codes, $code)
  if($idx -lt 0){ Fail "品目コード $code が統計表に見つかりません（品目の改廃の可能性）" }
  $out = New-Object System.Collections.Generic.List[object]
  foreach($r in $cpi.rows){
    $f = $r -split ','
    $key = $f[0].Trim()
    $v = $f[$idx].Trim(); $val = $null; if($v -ne ''){ $val = [double]$v }
    if($monthly){ $out.Add([pscustomobject][ordered]@{ ym = $key.Substring(0,4)+'-'+$key.Substring(4,2); value = $val }) }
    else { $out.Add([pscustomobject][ordered]@{ year = [int]$key; value = $val }) }
  }
  return ,$out
}

Write-Host "e-Stat から最新の CPI を取得しています..."
$m = Get-Cpi $MonthlyId
$a = Get-Cpi $AnnualId

$foodPath = Join-Path $repo 'data.json'
$vegPath  = Join-Path $repo 'vegetables_data.json'
$food = [IO.File]::ReadAllText($foodPath, $utf8) | ConvertFrom-Json
$veg  = [IO.File]::ReadAllText($vegPath,  $utf8) | ConvertFrom-Json

$oldLast = $food.items[0].cpi_index_monthly[-1].ym
$newRows = @{}
foreach($k in $foodCodes.Keys){ $newRows[$k] = Get-Series $m $foodCodes[$k] $true }
$newLast = $newRows['rice'][$newRows['rice'].Count-1].ym

# ---- 検証
foreach($k in $foodCodes.Keys){
  $last = $newRows[$k][$newRows[$k].Count-1]
  if($last.ym -ne $newLast){ Fail "$k の最終月（$($last.ym)）が他の品目（$newLast）と違います" }
  if($null -eq $last.value){ Fail "$k の最新月 $newLast の値が空です" }
}
if($newLast -lt $oldLast){ Fail "取得データの最終月（$newLast）が現在のデータ（$oldLast）より古いです。統計表IDを確認してください" }

Write-Host ""
Write-Host "現在のデータ: $oldLast まで ／ 取得したデータ: $newLast まで"
if($newLast -eq $oldLast -and -not $Force){
  Write-Host "新しい月はありません。更新は不要です（強制的に書き直す場合は -Force）。" -ForegroundColor Yellow
  exit 0
}

# ---- 反映
foreach($it in $food.items){
  $code = $foodCodes[$it.key]
  if(-not $code){ Fail "data.json の品目 $($it.key) の品目コードが未定義です" }
  $it.cpi_index = (Get-Series $a $code $false).ToArray()
  $it.cpi_index_monthly = @(($newRows[$it.key] | Where-Object { $_.ym -ge '2015-01' }))
}
foreach($it in $veg.items){
  $code = $vegCodes[$it.key]
  if(-not $code){ Fail "vegetables_data.json の品目 $($it.key) の品目コードが未定義です" }
  $it.cpi_index_monthly = (Get-Series $m $code $true).ToArray()
}
foreach($s in @($food.meta.sources) + @($veg.meta.sources)){
  if($s.id -in 'cpi_item_index','cpi_item_index_monthly'){ $s.retrieved = $today }
}
$food.meta.generated_at = $today
$veg.meta.generated_at = $today

# ---- 結果の表示
Write-Host ""
Write-Host "品目ごとの最新値（$newLast、2025年=100）:"
foreach($it in $food.items){ Write-Host ("  {0,-16} {1}" -f $it.label_ja, $it.cpi_index_monthly[-1].value) }
foreach($it in $veg.items){ Write-Host ("  {0,-16} {1}" -f $it.label_ja, $it.cpi_index_monthly[-1].value) }

if($DryRun){ Write-Host ""; Write-Host "DryRun のためファイルは書き換えていません。" -ForegroundColor Yellow; exit 0 }

[IO.File]::WriteAllText($foodPath, ($food | ConvertTo-Json -Depth 12), $utf8)
[IO.File]::WriteAllText($vegPath,  ($veg  | ConvertTo-Json -Depth 10), $utf8)

$smPath = Join-Path $repo 'sitemap.xml'
$sm = [IO.File]::ReadAllText($smPath, $utf8)
$sm = $sm -replace '(ai-taste-labo/</loc><lastmod>)[0-9-]+', ('${1}' + $today)
$sm = $sm -replace '(vegetables\.html</loc><lastmod>)[0-9-]+', ('${1}' + $today)
[IO.File]::WriteAllText($smPath, $sm, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ""
Write-Host "更新しました: data.json / vegetables_data.json / sitemap.xml" -ForegroundColor Green
Write-Host "次に確認すること:"
Write-Host "  1. data.json の recent_trend_notes（米・鶏卵・食用油のメモ）が最新の動きと矛盾していないか"
Write-Host "  2. 月次トピックス（monthly_digest_data.json）に今月分を追加するか"
Write-Host "  3. git add / commit / push（push 後、数分で公開サイトに反映）"
