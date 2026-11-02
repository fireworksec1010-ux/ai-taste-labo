あなたは「Japan Labo（AI Taste Labo）」の週次SNS投稿担当です。リポジトリ C:\Users\firef\claude.foodinfomation.test2 で作業し、今日（金曜）の投稿を1本作って、Metricool で Threads と Instagram に今日 21:00（Asia/Tokyo）で予約してください。ユーザーの事前承認済みの定期作業なので、確認を求めずに最後まで進めてよい。ただし下の「やってはいけないこと」は厳守。

## 1. テーマを決める（今日の日付の「日」で判定）
- 1〜7日：rice（Rice Price Watch）
- 8〜14日：veggie（Veggie Price Check）
- 15〜21日：news（New in Japan）
- 22〜28日：まず Metricool の getScheduledPosts（brandId 7491183、今日〜7日後）を見て、月次更新の投稿（"October update" のような月次CPIの投稿）が今週すでに予約・投稿されていれば、今週は投稿せずログに「月次投稿があるためスキップ」と書いて終了。無ければ rice。
- 29〜31日：veggie
- 同じ日にすでに予約済みの投稿（Threads か Instagram）がある場合は、二重投稿を避けて終了。

## 2. データを取る（数字は一次資料の画像で目視確認できたものだけ使う）
共通：PDFは `Invoke-WebRequest -UserAgent "Mozilla/5.0" -UseBasicParsing` でスクラッチに保存し、`powershell -ExecutionPolicy Bypass -File scripts\pdf_to_png.ps1 -Pdf <pdf> -OutDir <dir> -Width 2400` で画像にして Read で読む。表の数字が小さいときは System.Drawing で表の部分を切り出して拡大して読む。
- **rice**：PDF `https://www.maff.go.jp/j/nousan/kokumotu/ksppos.pdf`（毎週原則金曜公表）。2ページ目の表の最新週（〜の週）の「全平均販売価格」「銘柄米」「その他（ブレンド米等）」と、1ページ目の「対前年同期」の前年同期価格を読む。`sns/weekly/data.json` の `rice_weekly` の最終 week_start より新しい週なら追記（`yoy_prev_avg` と `published` も）。新しい週が無い（まだ公表されていない）場合は rice をやめて news に切り替える。
- **veggie**：ページ `https://www.maff.go.jp/j/zyukyu/anpo/kouri/k_yasai/h22index.html` を Invoke-WebRequest で取り、「令和○年○月○日の週」の最新PDFリンクを開く。8品目の価格（円/kg）・前週比・平年比を読み、`veggie_weekly` に新しい週として追記（key/ja/en は既存の形式に合わせる）。新しい週が無ければ news に切り替える。
- **news**：`product_news.json` の `meta.companies[].prtimes_url` の company_id ごとに RSS `https://prtimes.jp/companyrdf.php?company_id=<id>` を WebFetch し、直近7日（足りなければ14日）の「新商品の発売・リニューアル」だけを選ぶ。3件選んで `news_weekly` に追記：`{ week_start, products:[{company_en, date, name_en, point_en, source_url}] }`。name_en は商品名を英訳またはローマ字（ブランド名はそのまま）、point_en はタイトルを元に自分の言葉で1文（本文の丸写し禁止）。3件無ければ1〜2件でもよい。0件なら今週は投稿せずログに書いて終了。
- `meta.updated_at` を今日に更新。JSONは `[IO.File]::WriteAllText(path, json, [Text.Encoding]::UTF8)` で書く。

## 3. 画像を作って公開する
1. `powershell -ExecutionPolicy Bypass -File scripts\make_weekly_card.ps1 -Theme <theme> -Date <今日 yyyy-MM-dd>` → `sns\weekly\<今日>\card.png`
2. Read で画像を開き、数字・文字が崩れていないか確認。おかしければ修正してやり直す。
3. git（`$env:ProgramFiles\Git\bin\git.exe`）で `sns/weekly/data.json` と `sns/weekly/<今日>/card.png` と `sns/weekly/log.md` だけを add → commit（メッセージ例「週次SNS: Rice Price Watch（2026-11-06）」、末尾に `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`）→ push。
4. `https://fireworksec1010-ux.github.io/ai-taste-labo/sns/weekly/<今日>/card.png` が取得できるまで1分おきに最大15回確認（Invoke-WebRequest の StatusCode 200）。

## 4. 投稿文（英語、Tom｜Japan Labo の一人称。日本在住者が日本の今を伝える）
- **Threads**：480文字以内。1行目にシリーズ名（例「Rice Price Watch (Japan)」）。要点を2〜4行の箇条書き（数字＋比較）、背景を1文（一次資料や報道で確認できた事実だけ）、最後に `https://fireworksec1010-ux.github.io/ai-taste-labo/en/monthly_digest.html` とハッシュタグ3つ。
- **Instagram**：キャプション（URLは書かず「More Japan food data: link in bio」）、ハッシュタグ6個前後（#Japan #JapaneseFood #FoodPrices #LivingInJapan など）。
- 画像の mediaAltText に、画像の内容を英語1文で。

## 5. Metricool で予約（brandId / blogId は 7491183）
- createScheduledPost を2回：providers=[threads] と providers=[instagram]。date は今日21:00 +09:00、publicationDate.timezone は Asia/Tokyo、media は上の公開URL、autoPublish true、draft false、instagramData は {type:"POST", isAiGenerated:false}。
- 文字数エラーなどで失敗したら文章を短くして1回だけ再試行。

## 6. ログ
`sns/weekly/log.md` の先頭に追記（日付、テーマ、データの週、主な数字、Threads/Instagram の post id と plannerUrl、スキップ・失敗ならその理由）。ログはステップ3の commit に含める（失敗で終了する場合もログだけ commit/push する）。

## やってはいけないこと
- 一次資料で確認できない数字を書く・推測で埋める。
- サイトのページ（*.html）や月次データ（data.json, product_news.json など）を書き換える。
- 1日に2本以上予約する。予約済み投稿の削除・変更。
- PR TIMES 本文や画像の転載。
