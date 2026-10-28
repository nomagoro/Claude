# 歯医者さん紹介ショート「ひだまり歯科クリニック」

縦型ショート動画（1080×1920 / 30fps / **45秒**）の完成見本と編集素材一式です。
YouTubeショート・Instagramリール・TikTokにそのまま使えます。

> 「ひだまり歯科クリニック」「〇〇駅 徒歩3分」「9:00〜18:30」などは**仮の内容**です。
> `tools/scenes.json` を書き換えて再生成するか、編集ソフトでテロップを差し替えてください。

## ファイル

| ファイル | 内容 |
|---|---|
| `dental_intro_preview.mp4` | **完成見本**（テロップ・BGM・効果音入り） |
| `media/scenes/*.mp4` | シーンごとの背景動画（テロップなし）。編集ソフトで組み直す用 |
| `media/telop/*.png` | シーンごとのテロップ（透過PNG・1080×1920） |
| `media/audio/bgm.wav` | BGM（45秒・オリジナル曲。著作権フリー） |
| `media/audio/pop.wav` | テロップが出るときの「ポン」効果音 |
| `captions/narration.srt` | ナレーション原稿（字幕ファイル） |
| `fonts/MPLUSRounded1c-ExtraBold.ttf` | 使用フォント（M PLUS Rounded 1c / SIL OFL・商用可） |
| `media/stock/` | **ダウンロードしたフリー素材を入れるフォルダ**（下記） |
| `tools/` | 動画を再生成するスクリプト |

イラスト・BGM・効果音はすべてこのプロジェクト内で作成したものです。外部素材は使っていないため、このままでも権利面の問題なく使えます。

## 構成（45秒）

| 時間 | シーンID | テロップ | ナレーション（任意） |
|---|---|---|---|
| 0〜4秒 | `s1_hook` | 歯医者さん、ちょっと苦手…？ | 歯医者さん、ちょっと苦手…と感じていませんか？ |
| 4〜9秒 | `s2_clinic` | 〇〇駅から徒歩3分／ひだまり歯科クリニック | 〇〇駅から徒歩3分、ひだまり歯科クリニックです。 |
| 9〜16秒 | `s3_gentle` | POINT 1 痛みに配慮したやさしい治療 | 表面麻酔や細い針を使い、できるだけ痛みの少ない治療を心がけています。 |
| 16〜23秒 | `s4_counseling` | POINT 2 しっかり話を聞くカウンセリング | 治療の前には、お悩みやご希望をじっくりお聞きします。 |
| 23〜30秒 | `s5_kids` | POINT 3 キッズスペースでお子さまも安心 | キッズスペースがあるので、お子さま連れでも安心です。 |
| 30〜37秒 | `s6_prevent` | POINT 4 予防歯科・クリーニング | 定期的なクリーニングで、むし歯や歯周病を予防しましょう。 |
| 37〜45秒 | `s7_info` | 診療時間・アクセス・Web予約 24時間受付中 | ご予約はWebから24時間受付中。お気軽にご来院ください。 |

テロップは画面下20%（ショートのボタン・説明文で隠れる部分）より上に収めています。

---

## ダウンロードが必要なもの（まとめ）

### 必須：なし
完成見本 `dental_intro_preview.mp4` はそのまま使えます。

### 任意1：実写のフリー素材（イラストを実写に差し替えたい場合）

下のファイル名で `media/stock/` に入れて再生成すると、そのシーンの背景がイラストから実写に切り替わります。
動画（mp4/mov/webm）でも写真（jpg/png/webp）でも可。横長素材でも自動で縦9:16に切り抜きます（写真はゆっくりズーム）。

| 保存ファイル名 | シーン | 検索キーワード（Pexels / Pixabay） |
|---|---|---|
| `s2_clinic.mp4` | 医院紹介 | `dental clinic` / `dentist office` / `歯科医院` |
| `s3_gentle.mp4` | やさしい治療 | `dentist patient` / `dental treatment` |
| `s4_counseling.mp4` | カウンセリング | `dentist consultation` / `doctor talking patient` |
| `s5_kids.mp4` | キッズ | `child dentist` / `kids dental` |
| `s6_prevent.mp4` | 予防・クリーニング | `teeth cleaning` / `toothbrush` / `dental hygiene` |

`s1_hook` と `s7_info` はイラストのままがおすすめです。

**ダウンロード先（どれも商用利用可・クレジット表記不要）**
- Pexels 動画: https://www.pexels.com/ja-jp/videos/
- Pixabay 動画: https://pixabay.com/ja/videos/
- Mixkit: https://mixkit.co/free-stock-video/

縦型の素材を選ぶと切り抜きが少なく済みます（Pexelsは「向き：縦」で絞り込めます）。

> ⚠️ **医療広告ガイドラインの注意**：他院の院内や他人の治療風景を、自院のように見せる使い方は誤認を招くおそれがあります。
> 医院の外観・院内・スタッフは、**実際の医院で撮った写真・動画**を使うのが安全です（スマホ撮影で十分です）。
> フリー素材は歯ブラシやイメージカットなど、「イメージ」とわかるシーンに使ってください。

### 任意2：ナレーション（声を入れたい場合）
- **VOICEVOX**（無料の読み上げソフト）: https://voicevox.hiroshiba.jp/
  - `captions/narration.srt` の文章を読み上げさせて、wavで書き出します
  - 商用利用可。ただしキャラクターごとの規約に従い、概要欄などに「VOICEVOX:四国めたん」のようにクレジット表記が必要です
- 院長先生やスタッフの方の声を録音するのも効果的です（スマホのボイスメモで十分）

ナレーションを入れる場合、BGMの音量は 20〜30% 程度に下げてください。

### 任意3：編集ソフト（自分で編集したい場合）
- **CapCut**（無料・スマホ/PC）: https://www.capcut.com/ja-jp/
- Premiere Pro などの編集ソフトでも同じ手順で組めます

### 任意4：BGMを差し替えたい場合（商用可のフリーBGM）
- DOVA-SYNDROME: https://dova-s.jp/ （「明るい」「ポップ」で検索）
- 甘茶の音楽工房: https://amachamusic.chagasi.com/

---

## 編集ソフトで組み直す（CapCut / Premiere など）

1. 新規プロジェクトを **9:16（1080×1920）** で作成
2. `media/scenes/` の7本を、`s1`〜`s7` の順にメイントラックに並べる
3. `media/telop/` の同じ名前のPNGを、上のトラックの同じ位置に重ねる
4. `media/audio/bgm.wav` をオーディオトラックに置く
5. 実写素材を使うシーンは、背景動画をダウンロードした素材に置き換える

テロップの文字を直したい場合は、PNGの代わりに編集ソフトのテキスト機能で打ち直してください。
フォント `fonts/MPLUSRounded1c-ExtraBold.ttf` をPCにインストールすると同じ見た目になります。

| 項目 | 設定 |
|---|---|
| フォント | M PLUS Rounded 1c ExtraBold |
| 文字色 | 白 `#FFFFFF`（強調行は黄色 `#FFE066`） |
| 縁取り | 紺 `#2C4A5C`・太さ 14px |
| 位置 | 1行目の中心が上から約1300px、2行目は約1420px |
| 「POINT」ラベル | 緑 `#34B8A8` の角丸、白文字、上から約270px |

## 再生成する（文字の変更・実写素材の差し替え後）

必要なもの: Python 3 / Pillow / numpy / ffmpeg

```bash
pip install pillow numpy
```

```bash
cd dental-intro && python3 tools/render.py
```

- 医院名・テロップ・ナレーション・各シーンの秒数・背景色: `tools/scenes.json`
- 診療時間などの最後のカード: `scenes.json` の `s7_info` → `info`
- 約1分で `dental_intro_preview.mp4` ほか全素材が作り直されます
