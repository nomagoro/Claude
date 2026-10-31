# 動物病院紹介ショート「ごろう動物病院」（架空の動物病院／紹介動画サンプル）

架空の動物病院「ごろう動物病院」の紹介サンプル動画（縦型 1080×1920 / 30fps / 30秒）の編集素材一式です。
「やさしさ」と「犬猫について気軽に相談できる病院」という印象が30秒で伝わることを目的にしています。
映像・BGMはすべてフリー素材（Pexels / Pixabay）です。

> 「ごろう動物病院」は架空の名前です（2026年10月31日のウェブ検索で同名の動物病院は見つかりませんでした）。
> 動画内にも「架空の動物病院／紹介動画サンプル」と明記しています。電話番号・診療時間・休診日は載せていません。
> 素材や設定で確認できない専門性・設備・診療実績・効果は書いていません。

## テロップ再設計版（最新）

修正版のテロップをデザインから作り直した版です。映像・色調整・BGM・尺は修正版と同じで、変えたのはテロップとシェパードの構図だけです。

| ファイル | 内容 |
|---|---|
| `ごろう動物病院_紹介ショート_テロップ再設計.prproj` | テロップ再設計版の Premiere Pro プロジェクト（修正版を別名保存して差し替え） |
| `ごろう動物病院_紹介ショート_テロップ再設計.mp4` | 書き出した動画（H.264 / 1080×1920 / 30fps / 30秒） |
| `ごろう動物病院_紹介ショート_テロップ再設計_LoudnessReport.xml` | ラウドネス測定結果（−16.0 LUFS／トゥルーピーク −4.0 dBTP。修正版と同じ） |
| `ごろう動物病院_テロップ再設計_5場面.png` | 冒頭・診察・犬・猫・エンドの静止画を並べた確認用画像（書き出した MP4 から抜き出し） |
| `media/goro_r0*.png` | テロップ画像（`tools/make_telops_redesign.ps1` で作成） |
| `fonts/NotoSansJP-VF.ttf` | テロップの書体 Noto Sans JP（SIL OFL）。スクリプトを動かすときは Windows にインストールしておく |

### デザイン
- クリーム色の角丸パネル・コーラルの枠・強い影はやめ、**白文字・左揃え**に変更
- 書体は Noto Sans JP（丸みの少ないゴシック）。メッセージは SemiBold、病院名は Bold、一言と注記は Medium
- 強調は文字の大きさと太さだけで行う（囲み枠・線・アイコンなし）。文字の周りにはごく薄いにじみだけ入れて読みやすくしています
- 明るい場面だけ、画面の端に薄い黒のグラデーションを敷く（診察・猫の場面は下側、冒頭は上側）。エンドカードは映像全体を少し暗くする

### 配置のルール
| 種類 | 場面 | 位置・文字組み |
|---|---|---|
| メッセージ | 診察・犬・猫 | 左端 x=90、文字の下端 y=1420、SemiBold 72px、行送り1.6倍、2行（y=1241〜1420）。3場面とも同じ位置 |
| タイトル | 冒頭・エンドカード | 左端 x=90、上側（y=270〜518）。注記 36px → 病院名 Bold 104px → 一言 52px |

- 右側は x=900 より内側（右180pxは空ける）。下20%と上160pxにも入れない
- 冒頭の猫とエンドの秋田犬は顔が画面の下側にあり、下の位置だと顔に重なるため、タイトルだけ上に置いています
- 冒頭は病院名を先に出し、一言「大切な家族の、いつもの相談先。」を0.5秒かけてフェードインで後から出す
- シェパードのカットは手元がメッセージに重なっていたため、テロップを動かさず映像側を調整しました（スケール 75% → **90%**、位置Y 960 → **768**。元素材 1440×2560 なので拡大にはなりません）

### 確認したこと
- 書き出した MP4 から約1〜2秒おき＋切り替わりの前後を静止画にして確認：文字切れなし、犬猫の目・顔、診察の手元とメッセージの重なりなし
- メッセージの位置は診察→犬→猫で変わらず、文字の位置が上下に動くのは冒頭とエンドカードのタイトルだけ
- スマホ相当（幅390px）に縮めた画像で、注記（36px）まで拡大せずに読めることを確認

## ファイル

| ファイル | 内容 |
|---|---|
| `ごろう動物病院_紹介ショート.prproj` | **Premiere Pro プロジェクト（修正版）**。プロジェクトマネージャーで収集→素材を `media/` にまとめて再リンク。カットごとの色調整・構図調整入り |
| `ごろう動物病院_紹介ショート_修正版.mp4` | 書き出した修正版（H.264 / 1080×1920 / 30fps / 30秒 / AAC 48kHz） |
| `ごろう動物病院_紹介ショート_修正版_LoudnessReport.xml` | 書き出し時のラウドネス測定結果（Premiere 出力） |
| `goro_intro_premiere.xml` | 修正版の Premiere Pro 用 XML（FCP7 xmeml v4）。ビン・カット・テロップ・BGM・ディゾルブ入り |
| `さくら小径どうぶつ病院_紹介ショート.prproj` / `.mp4` / `vet_intro_premiere.xml` | **前の版（そのまま残しています）** |
| `media/` | 使用素材（両方の版の映像・BGM・テロップ画像） |
| `fonts/MPLUSRounded1c-ExtraBold.ttf` | テロップのフォント（M PLUS Rounded 1c / SIL OFL） |
| `tools/make_telops.ps1` | 修正版のテロップ画像（`media/goro_t*.png`）を作り直すスクリプト |
| `tools/build_xml.ps1` | 修正版の XML を作り直すスクリプト |
| `tools/credits.json` | 素材クレジット（下の表と同じ内容。どの版で使っているかも記載） |

前の版のスクリプト（`telop_*.png` を作るもの）は Git の履歴にあります。

## 構成（修正版）

| 時間 | 映像 | テロップ |
|---|---|---|
| 0:00〜0:03 | 猫の診察（猫の表情と聴診器・手元） | 病院名パネル＋「大切な家族の、／いつもの相談先。」 |
| 0:03〜0:07 | 桜並木の散歩道（愛知・豊川） | 病院名パネル（冒頭から出し続ける） |
| 0:07〜0:10 | 聴診器でポメラニアンを診察（犬・手・聴診器が1画面に入る区間） | 「小さな変化も、／ていねいに。」 |
| 0:10〜0:13 | シェパードに触れて診る手元 | （同上） |
| 0:13〜0:15.5 | 柴犬（窓辺） | 「おうちでの様子も、／お聞かせください。」 |
| 0:15.5〜0:18 | 柴犬（別カット・顔のアップ） | （同上） |
| 0:18〜0:20.5 | 三毛猫（顔を上げて伸び） | 「ねこちゃんのことも、／ご相談ください。」 |
| 0:20.5〜0:23 | 三毛猫（寝そべって顔をこちらへ） | （同上） |
| 0:23〜0:30 | 桜の下の秋田犬 | エンドカード「ごろう動物病院／犬と猫の、身近な相談先に。」 |

- 病院名パネルとエンドカードに「架空の動物病院／紹介動画サンプル」（46px）を入れています
- ディゾルブは「猫の診察→桜」と「三毛猫→エンドカード」の2か所だけ（各6フレーム）。他はカット切り替え

### テロップのルール
- 主メッセージ・病院名は 84〜112px（スマホ表示でおよそ30〜40px相当）、1画面に主メッセージ1つ
- 安全領域：上160px・下20%（y>1536）・右端180px には置かない（パネルは x=60〜900）
- 犬猫の目・顔や診察の手元に重ならない位置：0〜7秒とエンドカードは上側、7〜23秒は下側（y=1215〜1515）
- 配色：クリーム `#FFF9EE`（不透明度93%）／こげ茶 `#5C3A21`（補足 `#8C6240`）／淡いコーラル `#F4A28C`（枠）

### 構図（.prproj で設定）
| カット | 設定 | 理由 |
|---|---|---|
| 猫の診察（3840×2160） | スケール 88.9%・位置X 1000 | 横長素材から縦に切り出し（等倍以下）。猫の顔と聴診器が入る位置 |
| シェパード（1440×2560） | スケール 75% | 素材全体を表示（拡大なし） |
| 柴犬1 | スケール 115%・位置Y 816 | 口元がテロップにかからないよう少しだけ上へ |
| その他 | 100% | — |

### 色調整（.prproj で Lumetri カラーをカットごとに設定）
白い毛や窓際の明部の階調を残し、病院内のくすんだカットを日向のカットに近づけています。

| カット | 色温度 | 彩度 | 露光量 | コントラスト | ハイライト | シャドウ | 白レベル |
|---|---|---|---|---|---|---|---|
| 猫の診察 | +6 | 100 | 0 | 0 | −15 | +5 | −10 |
| 桜並木 | 0 | 95 | 0 | 0 | −10 | +5 | −5 |
| 聴診器の診察 | +10 | 105 | +0.3 | −5 | −10 | +10 | 0 |
| シェパード | +10 | 105 | +0.2 | 0 | −15 | +10 | −5 |
| 柴犬1 | 0 | 100 | +0.1 | 0 | −25 | +15 | −10 |
| 柴犬2 | 0 | 100 | 0 | 0 | −20 | +10 | −10 |
| 三毛猫A・B | −3 | 100 | −0.1 | 0 | −30 | +10 | −15 |
| 秋田犬 | 0 | 100 | 0 | 0 | −15 | +5 | −5 |

XML には色調整と構図の位置調整は入りません（スケールのみ入ります）。XML から作り直す場合は上の表の値を設定してください。

### 音声
- BGM（Happy Ukulele / BombinSound）を頭0.5秒でフェードイン、最後の2秒でフェードアウト
- 書き出し時に「ラウドネスの正規化」（ITU BS.1770-3、目標 −16 LUFS、最大トゥルーピーク −1 dBTP、リミッターあり）
- 測定結果：元 −18.3 LUFS → **−16.0 LUFS**、トゥルーピーク **−4.0 dBTP**（`ごろう動物病院_紹介ショート_修正版_LoudnessReport.xml`）
- ナレーションなし（テロップだけで内容が分かる構成）

## 開き方

### A. .prproj を開く（おすすめ）
1. `vet-intro` フォルダごとPCにダウンロードする（フォルダ構成は変えない）
2. `ごろう動物病院_紹介ショート.prproj` をダブルクリック
3. 「メディアをリンク」画面が出たら `media/` 内のどれか1つを指定 → 残りは自動でリンクされます

### B. XML から読み込む
1. Premiere Pro →「ファイル」→「読み込み」（または「プロジェクトを開く」）→ `goro_intro_premiere.xml`
2. 「メディアをリンク」画面が出たら `media/` 内のファイルを1つ指定
3. 上の「構図」「色調整」の値を設定

### XML から .prproj にまとめ直す（プロジェクトマネージャー）
1. XML を読み込んだら「ファイル → プロジェクトマネージャー」
2. 「ファイルをコピーして収集」を選ぶ／**「未使用のクリップを除外」はオフ**
3. 保存先を指定して OK → `コピー_〇〇` フォルダに .prproj と素材が集まります
4. このリポジトリと同じ形にする場合は、素材を `media/` に移してから .prproj を開き、「メディアをリンク」で `media/` を指定して保存します

## テロップを差し替える
- テロップ再設計版は `tools/make_telops_redesign.ps1`（`media/goro_r0*.png` を作成。Noto Sans JP のインストールが必要）
- 修正版は `tools/make_telops.ps1` の文言を書き換えて実行すると `media/goro_t*.png` が作り直されます
  ```
  powershell -ExecutionPolicy Bypass -File tools\make_telops.ps1
  ```
  （Premiere でプロジェクトを開いている間は PNG がロックされて上書きできないので、閉じてから実行してください）
- パネルが安全領域からはみ出すとエラーで止まります。長い文字は自動で縮小されます

## 素材クレジット

| ファイル | 内容 | 作者 | URL | ライセンス | 使用 |
|---|---|---|---|---|---|
| `media/07_cat_exam_6816882.mp4` | Cat in the Veterinarian | [Gustavo Fring](https://www.pexels.com/@gustavo-fring) | https://www.pexels.com/video/cat-in-the-veterinarian-6816882/ | Pexels License | 修正版 |
| `media/01_sakura_stroll_31295367.mp4` | Cherry Blossom Stroll in Toyokawa, Japan | [Tien Nguyen](https://www.pexels.com/@tiennguyen) | https://www.pexels.com/video/cherry-blossom-stroll-in-toyokawa-japan-31295367/ | Pexels License | 両方 |
| `media/08_exam_stethoscope_6235747.mp4` | Doctor Checking the Dog | [Tima Miroshnichenko](https://www.pexels.com/@tima-miroshnichenko) | https://www.pexels.com/video/doctor-checking-the-dog-6235747/ | Pexels License | 修正版 |
| `media/09_exam_shepherd_6235182.mp4` | Doctor Checking the Dog | [Tima Miroshnichenko](https://www.pexels.com/@tima-miroshnichenko) | https://www.pexels.com/video/doctor-checking-the-dog-6235182/ | Pexels License | 修正版 |
| `media/04_shiba_29243898.mp4` | Cute Shiba Inu Relaxing by a Sunlit Doorway | [Rin Gakusho](https://www.pexels.com/@rin-gakusho-280714394) | https://www.pexels.com/video/cute-shiba-inu-relaxing-by-a-sunlit-doorway-29243898/ | Pexels License | 両方 |
| `media/10_shiba_29243903.mp4` | Playful Shiba Inu Resting on a Wooden Surface | [Rin Gakusho](https://www.pexels.com/@rin-gakusho-280714394) | https://www.pexels.com/video/playful-shiba-inu-resting-on-a-wooden-surface-29243903/ | Pexels License | 修正版 |
| `media/05_calico_cat_35486843.mp4` | Playful Calico Cat Basking in Sunlight | [Fara Pardasi](https://www.pexels.com/@FaraPardasi) | https://www.pexels.com/video/playful-calico-cat-basking-in-sunlight-35486843/ | Pexels License | 両方 |
| `media/06_akita_sakura_31643071.mp4` | Akita Inu Dog Resting Under Spring Blossoms | [Efrem Efre](https://www.pexels.com/@efrem-efre-2786187) | https://www.pexels.com/video/akita-inu-dog-resting-under-spring-blossoms-31643071/ | Pexels License | 両方 |
| `media/bgm_happy_ukulele_512480.mp3` | Happy Ukulele | [BombinSound](https://pixabay.com/users/bombinsound-54782632/) | https://pixabay.com/music/happy-childrens-tunes-happy-ukulele-512480/ | Pixabay Content License | 両方 |
| `media/02_tokyo_street_35306935.mp4` | Peaceful Suburban Street in Tokyo | [Miltan Monjib](https://www.pexels.com/@miltan-monjib-204165102) | https://www.pexels.com/video/peaceful-suburban-street-in-tokyo-35306935/ | Pexels License | 前の版のみ |
| `media/03_stethoscope_6235191_uhd.mp4` | Veterinarian Listening Heart Of Small Dog With Stethoscope | [Tima Miroshnichenko](https://www.pexels.com/@tima-miroshnichenko) | https://www.pexels.com/video/veterinarian-listening-heart-of-small-dog-with-stethoscope-6235191/ | Pexels License | 前の版のみ |
| `fonts/MPLUSRounded1c-ExtraBold.ttf` | M PLUS Rounded 1c | M+ FONTS PROJECT | https://fonts.google.com/specimen/M+PLUS+Rounded+1c | SIL Open Font License 1.1 | 修正版・前の版 |
| `fonts/NotoSansJP-VF.ttf` | Noto Sans JP | Google | https://fonts.google.com/noto/specimen/Noto+Sans+JP | SIL Open Font License 1.1 | テロップ再設計版 |

- Pexels License・Pixabay Content License とも商用利用可・クレジット表記は任意です（素材そのものの再配布・販売は不可）
- BGM は Pixabay で「Content ID 登録なし」の曲です
- 素材メモ
  - 病院内の映像（猫の診察・聴診器・シェパード）は海外で撮影されたもので、日本人スタッフの映像は Pexels / Pixabay に見つかりませんでした
  - 秋田犬の映像は撮影地が日本ではありません
  - `05_calico_cat` は元素材が81秒・約80MB（使っているのは0〜2.5秒と42.5〜45秒）
  - 素材のフレームレートは 25 / 29.97 / 30 / 59.94fps が混在（シーケンスは30fps）

---

## 前の版：さくら小径どうぶつ病院（`さくら小径どうぶつ病院_紹介ショート.prproj`）

修正前の版です。比較用にそのまま残しています（同じ `media/` を参照します）。
構成：桜並木 → 東京の住宅街 → 聴診器のアップ → 柴犬 → 三毛猫 → 秋田犬のエンドカード（診療時間・ダミー電話番号入り）。
XML は `vet_intro_premiere.xml`（テロップ画像 `media/telop_*.png`）です。
