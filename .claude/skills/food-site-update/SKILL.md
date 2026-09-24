---
name: food-site-update
description: 食品価格サイト（食品価格・野菜価格・輸入統計・新製品情報・市場規模・お問い合わせの6ページ）のデータ更新・公開手順。「更新して」「データを最新にして」「新製品を追加して」などの依頼、または月次更新チェック（毎月25日のルーティン）の結果を受けて実際に更新するときに使う。
---

# 食品価格サイト 更新手順

対象リポジトリ：`C:\Users\firef\claude.foodinfomation.test2`（GitHub: fireworksec1010-ux/claude.foodinfomation.test2）
公開Artifact：https://claude.ai/artifact/SoNaobKEA1qt98Ej1aPu3w（同じURLに再公開して更新する）
月次チェック用ルーティン：https://claude.ai/code/routines/trig_01J5CLqZRTjJPig8LZvPXYBB（毎月25日9:00 JST。確認と報告のみで、編集・pushはしない）

## 基本方針
- ページ本体（HTML）とデータ（JSON）は分離済み。更新は原則JSONだけ差し替える。
- 作業はリポジトリ内のファイルを直接編集する（作業用コピーを別に作らない）。
- 全ページ共通：ライト配色固定、上部ナビ6タブ（食品価格／野菜価格／輸入統計／新製品情報／市場規模／お問い合わせ）、出典・取得日・注記を必ず明記。
- 数値は推測で埋めない。取得できない年・品目は空欄のままにし、注記する。
- ユーザーが「更新して」と言った場合のみ更新する。月次チェックは報告だけ。

## 各ページの更新

### 1. 食品価格（index.html / data.json）・2. 野菜価格（vegetables.html / vegetables_data.json）
- データ源：総務省統計局 CPI 品目別価格指数（2020年=100、全国）。
  - 月次CSV：`https://www.e-stat.go.jp/stat-search/file-download?statInfId=000032103844&fileKind=1`（Shift-JIS。公表のたびにstatInfIdが変わる場合は https://www.e-stat.go.jp/stat-search/files?tclass=000001138368&cycle=0 で最新を確認）
  - 年平均CSV：`statInfId=000032103938`（tclass=000001138366）
  - `Invoke-WebRequest -UserAgent "Mozilla/5.0"` でダウンロードし、`[Text.Encoding]::GetEncoding("shift_jis")` でデコード。
- CSV構造：行0=日本語品目名、行2=品目コード、行6以降=`YYYYMM,値...`（昇順、最新月が末尾）。列位置は基準改定でずれるので、**品目コードで列を特定**する。
  - 食品：米類=0004、食パン=1021、鶏卵=1341、牛乳=**1303**（同名の0018は上位分類なので使わない）、食用油=1601、カップ麺=1051、豚肉（国産品）=1211、しょう油=1621
  - 野菜：キャベツ=1401、ねぎ=1405、レタス=1406、じゃがいも=1412、たまねぎ=1417、きゅうり=1434、トマト=1436、にんじん=1415
- 更新内容：各itemの `cpi_index_monthly`（`{ym:"YYYY-MM", value}`）に新しい月を追記、`meta.generated_at` を更新。年が確定したら `cpi_index`（年平均、data.jsonのみ）にも追記。
- data.jsonにはこの他、エンゲル係数（`engel_coefficient`）、鶏卵の実勢価格、`recent_trend_notes`がある（年1回程度、家計調査の確定値が出たら更新）。エンゲル係数の二次情報年（2019〜2022）は要一次確認。

### 3. 輸入統計（trade.html / trade_data.json）
- データ源：農林水産省「品目別貿易実績」https://www.maff.go.jp/j/kokusai/kokusei/kaigai_nogyo/k_boeki_tokei/sina_betu.html （年1回更新、現状2023年まで。対象品目は小麦=sina_betu-183、大豆=-181、輸入牛肉=-176、とうもろこし=-173、コーヒー生豆=-186、各`.../attach/xls/sina_betu-XXX.xlsx`）。
- 2024年以降が掲載されたら、各Excel（実体はOLE2形式の場合あり。PowerShellのExcel COMでCSV化）の「世界（計）」行から数量（トンなら×1000でkg）・金額（千円なら×1000で円）を年ごとに取得して `yearly` に追記。
- 月次化の候補（未着手、ユーザーが見送り）：e-Stat「普通貿易統計 概況品別表 輸入 月次」https://www.e-stat.go.jp/stat-search/files?tclass=000001008809&cycle=1&layout=datalist （1ファイル=1か月・全品目、〜2026年7月）。
- 粗糖・カカオ豆は単年のみしか取れず未掲載。

### 4. 新製品情報（product_news.html / product_news.json）
- 情報源：PR TIMES各社公式アカウント（`meta.companies[].prtimes_url`）。対象は売上高上位の食品メーカー（食肉加工大手を除く）：明治、味の素、山崎製パン、マルハニチロ（2026年3月にUmios株式会社へ社名変更）、日清製粉ウェルナ／日清製粉グループ、ニッスイ、雪印メグミルク、森永乳業、ニチレイフーズ、キユーピー。
- `meta.generated_at` 以降の新商品プレスリリースを確認し、`products` に追記（`company_key, company_name, product_name, announced_date, summary, category, source_url`）。
- **著作権配慮**：要約は必ず自分の言葉で1〜2文にし、本文の丸写し・画像転載はしない。実在を確認した記事URLのみ載せる。IR・採用・CSR等、新商品以外は対象外。

### 5. 市場規模（market_size.html / market_size_data.json）
- 調理食品・調味料・菓子：農水省「食品産業動態調査」年報Excel（生産指数シート、令和2年度=100）。清涼飲料：全国清涼飲料連合会「清涼飲料水統計」ダイジェストPDF（数量kl・金額百万円）。
- 生産・出荷ベースであり、富士経済等の小売ベース市場調査とは算出方法が異なる旨のバナーを維持する。チャートの縦軸はズーム表示（0基準にしない）で、その注記も残す。

### 6. お問い合わせ（contact.html）
- 宛先はmailtoのみ（fireworks.fd.2020@gmail.com）。変更依頼があるときだけ編集。

## JSON編集の注意（Windows / PowerShell）
- JSONの書き出しは `[System.IO.File]::WriteAllText(path, json, [System.Text.Encoding]::UTF8)`（BOM付き）。読み込みは `[System.IO.File]::ReadAllText(path, [System.Text.Encoding]::UTF8)`。BOMなしUTF-8（他エージェントやWriteツールが作ったファイル）を `Get-Content -Raw` で読むと文字化けする。
- 大量の数値を手で打ち直さず、PowerShellのConvertFrom-Json／ConvertTo-Jsonで加工する。

## 公開・保存の手順
1. 更新したJSON/HTMLをリポジトリ内で編集。
2. Artifact再公開：`Artifact`ツールで `index.html` を `url=https://claude.ai/artifact/SoNaobKEA1qt98Ej1aPu3w` に公開。補助ファイル（`vegetables.html, trade.html, product_news.html, market_size.html, contact.html` と各 `*_data.json`）は `files` に指定。他ページが公開側で更新済みと判定された場合は `overwrite_unread` に列挙。`data.json` はindex.htmlの補助として同時に渡す。
3. Git（`%ProgramFiles%\Git\bin\git.exe`、認証済み）：`git status` → `git add` → commit → push。コミットメッセージは日本語で要点を書き、末尾に `Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>` を付ける。
4. 完了報告は「何を更新したか・データ取得日・URL」を簡潔に。

## 既知の制約
- Artifactのプレビュー内では、ExcelダウンロードやページのNav遷移（別HTMLへのリンク）が動かない場合がある。GitHub Pages等の通常ホスティング上では動作する（GitHub Pagesは未有効化）。
- 食品価格・野菜価格・輸入統計・新製品情報の月次確認は、上記ルーティンが毎月25日に報告する。
