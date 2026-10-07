---
name: food-site-update
description: 食品価格サイト「食卓の物価」（AI Taste Labo。食品価格・野菜価格・輸入統計・新製品情報・市場規模・業界マップ・月次トピックス・お問い合わせの8ページ＋英語版、GitHub Pagesで公開中）のデータ更新・公開手順。「更新して」「データを最新にして」「新製品を追加して」などの依頼、または月次更新チェック（毎月25日のルーティン）の結果を受けて実際に更新するときに使う。
---

# 食品価格サイト 更新手順

対象リポジトリ：`C:\Users\firef\claude.foodinfomation.test2`（GitHub: fireworksec1010-ux/ai-taste-labo ※2026-09に旧名 claude.foodinfomation.test2 から改名。手元のフォルダ名は旧名のまま）
公開サイト（GitHub Pages）：https://fireworksec1010-ux.github.io/ai-taste-labo/
公開Artifact：https://claude.ai/artifact/SoNaobKEA1qt98Ej1aPu3w（同じURLに再公開して更新する）
月次チェック用ルーティン：https://claude.ai/code/routines/trig_01J5CLqZRTjJPig8LZvPXYBB（毎月25日9:00 JST。確認と報告のみで、編集・pushはしない）

## 基本方針
- ページ本体（HTML）とデータ（JSON）は分離済み。更新は原則JSONだけ差し替える。
- 作業はリポジトリ内のファイルを直接編集する（作業用コピーを別に作らない）。
- 各HTMLの先頭にある `<!doctype html>`・`<meta charset>`・`<meta name="viewport">`・`[hidden]{display:none!important}` はGitHub Pagesでの表示（特にスマホ）に必須なので消さない。新しいページを作るときも同じ4行を先頭に入れる。
- 検索・SNS対策：各ページの `<title>`・`meta description`・`canonical`・OGP（`og:*`、`twitter:card`、共通画像 `ogp.png`）を維持する。ページを追加したら同じ一式を入れ、`sitemap.xml` にもURLを追加する。内容を更新したら `sitemap.xml` の該当ページの `lastmod` を更新日に書き換える。
- アクセス解析：全ページの `<head>` 内にCloudflare Web Analyticsのコード（token `01b322e4ae7a468da9de43a282ff93f7`）が入っている。消さない。新しいページにも同じコードを入れる。閲覧数はCloudflareのダッシュボード（Analytics → Web 分析）で確認。Google Search Console（URLプレフィックス https://fireworksec1010-ux.github.io/ai-taste-labo/ 、所有権はトップページのmetaタグで確認済み。消さない）にsitemap.xmlを登録済み。
- 全ページ共通：ライト配色固定、上部ナビ9タブ（ホーム／食品価格／野菜価格／輸入統計／新製品情報／市場規模／業界マップ／月次トピックス／お問い合わせ）＋右端に「English」リンク、出典・取得日・注記を必ず明記。
- 英語版（海外の食品マーケター・日本市場参入検討者向け）：`en/` 以下に置く。現在は `en/monthly_digest.html`・`en/market_size.html` の2ページ。データは日本語版と同じJSON（`../*.json`）を読み、項目名の末尾に `_en` が付いた英語フィールドを表示（無ければ日本語にフォールバック）。
  - **月次トピックス・市場規模を更新したら、追加・変更した項目の `_en` フィールドも必ず書く**（例：`label_en`・`detail_en`・`title_en`・`summary_en`・`trend_note_en`・`text_en`・`outlook_en` など）。英文は直訳ではなく海外読者向けに補足（FY＝4月〜3月、JPY、日本語固有の商品名は英訳＋原語）。
  - 日英ペアのページには `hreflang`（ja / en / x-default=日本語版）を入れる。英語版ナビで未翻訳のページは日本語版にリンクし「JA」マークを付ける。英語版ページを追加したら、日本語側のEnglishリンク先・英語版ナビ・`sitemap.xml` も更新する。
  - 英語化の優先順位（ユーザー合意）：月次トピックス＞市場規模（済）＞新製品情報＞輸入統計＞価格ページ。
- 中国語版（繁体字、台湾・香港向け）：`zh/` 以下に `zh/monthly_digest.html`・`zh/industry_map.html` の2ページ。英語版と同じ仕組みで `_zh` フィールドを表示（無ければ日本語）。
  - **月次トピックス・業界マップを更新したら `_zh` フィールドも書く**（月次トピックス：`label_zh`・`detail_zh`・`title_zh`・`needs_zh`・`market_zh`・`takeaway_zh`・`company_zh`・`point_zh`・`summary_zh`・`outlook_zh` など。業界マップ：`name_zh`・`note_zh`・`growth_note_zh`・分野の `label_zh`）。商品名・ブランド名は日本語の原名のまま。社名は各社の中国語表記（例：味之素、龜甲萬、丘比、可果美、江崎固力果、卡樂比）。
  - 日本語版の各ページのナビには「English」「中文」リンクがある。中国語版のない日本語ページの「中文」は `zh/monthly_digest.html` へ。hreflang は `zh-Hant`。
- 数値は推測で埋めない。取得できない年・品目は空欄のままにし、注記する。
- ユーザーが「更新して」と言った場合のみ更新する。月次チェックは報告だけ。

## 各ページの更新

### 0. TOPページ（index.html）
- 2026-10-07 開設。サイト紹介（AI Taste Labo について・名前の由来・方針）、サイトメニュー、更新スケジュール、これまでの歩みを掲載。食品価格ページは `food_prices.html` に移動済み（旧 index.html）。
- サイトメニューの「最新データ」は各JSONから自動表示されるので、月次更新では編集不要。
- ページ追加・言語追加・大きな出来事があったら「これまでの歩み」とサイトメニューのカード、上部の数字（データページ数・対応言語数）を更新する。更新日（毎月25日ごろ）を変えるときはTOPの「更新」表示と更新スケジュールも直す。
- Search Consoleの所有権確認metaタグはこの index.html にある。消さない。

### 1. 食品価格（food_prices.html / data.json）・2. 野菜価格（vegetables.html / vegetables_data.json）
**月次の数値更新はスクリプトで行う**（手作業でCSVを解析しない）：
```
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\update_cpi.ps1 -DryRun   # まず確認
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\update_cpi.ps1           # 反映
```
- e-Statから月次・年平均CSVを取得 → 品目コードで16品目を抽出 → 検証（最終月の一致・空値・データが古くないか）→ data.json / vegetables_data.json / sitemap.xml を更新。検証に失敗したら何も書き換えずに止まる。新しい月がなければ「更新不要」で終了。
- statInfIdが変わった場合は `-MonthlyId` / `-AnnualId` で指定（探し方はスクリプト冒頭のコメントと下記）。
- 実行後は、表示される「次に確認すること」（トレンドメモの整合・月次トピックス・commit/push）を行う。ページ側の米・食用油のタイルと米の「ピーク比」は自動計算なので編集不要。
- 以下は仕組みの説明（スクリプトが動かない場合の手作業の参考）。

- データ源：総務省統計局 CPI 品目別価格指数（**2025年基準＝2025年=100**、全国）。2026年8月分から基準改定（2020年基準→2025年基準）。2024年以前は統計局が2025年=100に換算した接続指数。旧2020年基準の表（statInfId 000032103844 / 000032103938）はもう使わない。
  - 月次CSV（1970年1月～最新月）：`https://www.e-stat.go.jp/stat-search/file-download?statInfId=000040482945&fileKind=1`
  - 年平均CSV（1970年～最新年）：`https://www.e-stat.go.jp/stat-search/file-download?statInfId=000040482831&fileKind=1`
  - statInfIdが変わった場合の一覧ページ：月次 `https://www.e-stat.go.jp/stat-search/files?page=1&toukei=00200573&tstat=000001243876&cycle=0&tclass1=000001243880&tclass2=000001243881&tclass3=000001243883&tclass4=000001243886&layout=datalist&tclass5val=0`（年平均は tclass4=000001243890）。表題「品目別価格指数（1970年1月～最新月）」を選ぶ。
  - 年平均CSVの年の列は `1970  ` のように末尾に空白が入るので Trim() する。
  - 指数は2025年=100なので、「2020年比」は `値÷2020年の値−1` で計算する（`値−100` は2025年比になる点に注意）。ページ側の米・食用油のタイルとヒーロー統計はこの計算済み。
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

### 6. 業界マップ（industry_map.html / industry_map_data.json）
- 主要食品メーカー20社の最新通期決算（連結の売上高・営業利益と前期値、億円未満切り捨て）を6分野で表示。**更新は年1回、6月ごろ**（3月期決算の有価証券報告書が出たあと。11月期・12月期の会社はその時点の最新期）。
- 取得：`https://irbank.net/{証券コード}/results` をWebFetchで読むと直近期の売上高・営業利益が取れる（決算短信・EDINETの集計）。前期比が±15%を超える会社は、決算短信や報道で理由（買収など）を確認し、必要なら `growth_note` に書く。
- 資本関係（`parent`・`relations`）は、子会社側の「株式情報（大株主の状況）」や有価証券報告書で確認できたものだけ。
- 分野分け・紹介文（`note`）・ブランドは当サイト独自。市販の業界地図の文言・配置は真似しない（著作権配慮）。
- 会社を追加するときも同じ項目で `companies` に追記する。

### 7. お問い合わせ（contact.html）
- 宛先はmailtoのみ（fireworks.fd.2020@gmail.com）。変更依頼があるときだけ編集。

## JSON編集の注意（Windows / PowerShell）
- JSONの書き出しは `[System.IO.File]::WriteAllText(path, json, [System.Text.Encoding]::UTF8)`（BOM付き）。読み込みは `[System.IO.File]::ReadAllText(path, [System.Text.Encoding]::UTF8)`。BOMなしUTF-8（他エージェントやWriteツールが作ったファイル）を `Get-Content -Raw` で読むと文字化けする。
- 大量の数値を手で打ち直さず、PowerShellのConvertFrom-Json／ConvertTo-Jsonで加工する。

## 公開・保存の手順
1. **編集はリポジトリ（`C:\Users\firef\claude.foodinfomation.test2`）のファイルだけを直接行う**。スクラッチパッド等に作業コピーを作ってからコピーし直す運用はしない（食い違いの原因になるため。2026-09に一本化）。ダウンロードした生データなど一時ファイルだけはスクラッチパッドに置いてよい。
2. （大きな変更のとき）Artifactでプレビュー：`Artifact`ツールで `file_path` にリポジトリの `index.html`（TOP）、`url=https://claude.ai/artifact/SoNaobKEA1qt98Ej1aPu3w`、`files` に他のHTML・JSONをリポジトリのパスで指定して公開。以前の版と違うと判定されたら `overwrite_unread` に列挙。Artifactは非公開の確認用で、一般公開はGitHub Pages。
3. Git（`%ProgramFiles%\Git\bin\git.exe`、認証済み）：`git status` → `git add` → commit → push。pushすると数分でGitHub Pages（公開サイト）に反映される。コミットメッセージは日本語で要点を書き、末尾にその時点のClaude Code既定のCo-Authored-By行を付ける。
4. 完了報告は「何を更新したか・データ取得日・公開URL」を簡潔に。

## 既知の制約
- Artifactのプレビュー内では、ExcelダウンロードやページのNav遷移（別HTMLへのリンク）が動かない場合がある。公開サイト（GitHub Pages）では動作する。
- 食品価格・野菜価格・輸入統計・新製品情報の月次確認は、上記ルーティンが毎月25日に報告する。
