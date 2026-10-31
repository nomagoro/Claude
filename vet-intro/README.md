# 動物病院紹介ショート「ひだまり動物病院」

架空の動物病院「ひだまり動物病院」を紹介する縦型ショート動画（1080×1920 / 25fps / 30秒）の編集素材一式です。
雰囲気は「明るくやさしい」。映像・BGMはすべてフリー素材（Pexels / Pixabay）です。

> 病院名・診療時間・電話番号（000-0000-0000）はすべて**ダミー**です。実際に使うときはテロップを差し替えてください。

## ファイル

| ファイル | 内容 |
|---|---|
| `ひだまり動物病院_紹介ショート.prproj` | **Premiere Pro プロジェクト**（プロジェクトマネージャーで収集したもの。色調整入り） |
| `ひだまり動物病院_紹介ショート.mp4` | 書き出した完成動画（H.264 / 1080×1920 / 25fps / 30秒） |
| `vet_intro_premiere.xml` | Premiere Pro 用 XML（FCP7 xmeml v4）。ビン構成・カット・テロップ・BGMまで入っています |
| `media/` | 使用素材すべて（映像6本・BGM・テロップ画像6枚） |
| `fonts/MPLUSRounded1c-ExtraBold.ttf` | テロップのフォント（M PLUS Rounded 1c / SIL OFL） |
| `tools/make_telops.ps1` | テロップ画像（透過PNG）を作り直すスクリプト |
| `tools/build_xml.ps1` | XML を作り直すスクリプト |
| `tools/credits.json` | 素材クレジット（下の表と同じ内容） |

## Premiere Pro のビン構成

| ビン | 中身 |
|---|---|
| `01_シーケンス` | シーケンス「ひだまり動物病院_紹介ショート」 |
| `02_背景映像` | 冒頭の子犬の映像、色調整用の調整レイヤー（.prproj のみ） |
| `03_テロップ` | テロップ画像 `telop_00`〜`telop_05` |
| `04_音声` | BGM |
| `05_実写素材_差し替え用` | 診察・スタッフのシーン。**実際の病院で撮った映像に差し替える前提**の仮素材 |

## タイムライン

| トラック | 内容 |
|---|---|
| V3 | テロップ（下表） |
| V2 | 調整レイヤー（Lumetri カラー：色温度 +12・彩度 110・露光量 +0.4・コントラスト −10・シャドウ +15・白レベル +10）※.prproj のみ |
| V1 | 映像6カット（カット間に10フレームのクロスディゾルブ） |
| A1 | BGM（−4.4dB、最後の2秒でフェードアウト） |

| 時間 | 映像 | テロップ |
|---|---|---|
| 0:00〜0:04 | 子犬を抱っこ | やさしく、あたたかく。／ひだまり動物病院 |
| 0:04〜0:09 | ポメラニアンの診察 | ていねいな診察／気になることは何でもご相談ください |
| 0:09〜0:14 | 聴診器のアップ | からだの声に耳をすませて／小さな変化も見逃しません |
| 0:14〜0:19 | 飼い主さんと一緒に | 飼い主さまと一緒に／納得できる治療を考えます |
| 0:19〜0:24 | 猫のケア | ねこちゃんのケアも／トリミング・爪切りもおまかせ |
| 0:24〜0:30 | 獣医師とポメラニアン | エンドカード（病院名・診療時間・休診日・TEL・お気軽にご相談ください） |

テロップは**画面下20%（y>1536）と右端180px**に入らないよう、x=60〜900・y≦1480 に収めています（ショートのボタンやタイトルで隠れないため）。

## 開き方

### A. .prproj を開く（おすすめ）
1. `vet-intro` フォルダごとPCにダウンロードする（フォルダ構成は変えない）
2. `ひだまり動物病院_紹介ショート.prproj` をダブルクリック
3. 「メディアをリンク」画面が出たら `media/` 内のどれか1つを指定 → 残りは自動でリンクされます

### B. XML から読み込む
1. Premiere Pro →「ファイル」→「読み込み」（または「プロジェクトを開く」）→ `vet_intro_premiere.xml`
2. 「メディアをリンク」画面が出たら `media/` 内のファイルを1つ指定
3. XML には色調整（調整レイヤー）が入っていないので、必要なら「ファイル → 新規 → 調整レイヤー」を V2 に置き、上の数値で Lumetri カラーを設定します

### XML から .prproj にまとめ直す（プロジェクトマネージャー）
1. XML を読み込んだら「ファイル → プロジェクトマネージャー」
2. 「ファイルをコピーして収集」を選ぶ／**「未使用のクリップを除外」はオフ**
3. 保存先を指定して OK → `コピー_〇〇` フォルダに .prproj と素材が集まります
4. このリポジトリと同じ形にする場合は、素材を `media/` に移してから .prproj を開き、「メディアをリンク」で `media/` を指定して保存します

## テロップを差し替える

- 文字を変えるだけなら：`tools/make_telops.ps1` の文言を書き換えて実行 → `media/telop_*.png` が上書きされ、Premiere 側も自動で更新されます
  ```
  powershell -ExecutionPolicy Bypass -File tools\make_telops.ps1
  ```
  （フォント `fonts/MPLUSRounded1c-ExtraBold.ttf` を使います。はみ出す長さの文字は自動で縮小されます）
- Premiere 上で直接編集したい場合：V3 のテロップ画像を、エッセンシャルグラフィックスのテキストに置き換えてください
  - フォント：M PLUS Rounded 1c ExtraBold（`fonts/` からインストール）
  - 文字色：こげ茶 `#5C3A21`（サブは `#8C6240`）／パネル：クリーム `#FFF9EE`（不透明度93%）・枠コーラル `#F4A28C`・角丸

## 素材クレジット

| ファイル | 内容 | 作者 | URL | ライセンス |
|---|---|---|---|---|
| `media/01_puppies_12768731.mp4` | Close up of a Woman Holding Toy Poodle Puppies | [Anna Bondarenko](https://www.pexels.com/@aaa333) | https://www.pexels.com/video/close-up-of-a-woman-holding-toy-poodle-puppies-12768731/ | Pexels License |
| `media/02_exam_6235179.mp4` | Vet Examining Little Dog's Face | [Tima Miroshnichenko](https://www.pexels.com/@tima-miroshnichenko) | https://www.pexels.com/video/vet-examining-little-dog-s-face-6235179/ | Pexels License |
| `media/03_stethoscope_6235191_uhd.mp4` | Veterinarian Listening Heart Of Small Dog With Stethoscope | [Tima Miroshnichenko](https://www.pexels.com/@tima-miroshnichenko) | https://www.pexels.com/video/veterinarian-listening-heart-of-small-dog-with-stethoscope-6235191/ | Pexels License |
| `media/04_with_owner_6235744.mp4` | Doctor Checking the Dog | [Tima Miroshnichenko](https://www.pexels.com/@tima-miroshnichenko) | https://www.pexels.com/video/doctor-checking-the-dog-6235744/ | Pexels License |
| `media/05_cat_care_6131039.mp4` | Woman Wearing Face Mask Grooming a Cat | [Tima Miroshnichenko](https://www.pexels.com/@tima-miroshnichenko) | https://www.pexels.com/video/woman-wearing-face-mask-grooming-a-cat-6131039/ | Pexels License |
| `media/06_vet_with_dog_6234589.mp4` | Woman holding a Cute Dog | [Tima Miroshnichenko](https://www.pexels.com/@tima-miroshnichenko) | https://www.pexels.com/video/woman-holding-a-cute-dog-6234589/ | Pexels License |
| `media/bgm_happy_ukulele_512480.mp3` | Happy Ukulele | [BombinSound](https://pixabay.com/users/bombinsound-54782632/) | https://pixabay.com/music/happy-childrens-tunes-happy-ukulele-512480/ | Pixabay Content License |
| `fonts/MPLUSRounded1c-ExtraBold.ttf` | M PLUS Rounded 1c | M+ FONTS PROJECT | https://fonts.google.com/specimen/M+PLUS+Rounded+1c | SIL Open Font License 1.1 |

- Pexels License・Pixabay Content License とも、商用利用可・クレジット表記は任意です（素材そのものの再配布・販売は不可）
- BGM は Pixabay で「Content ID 登録なし」の曲を選んでいます（YouTube で著作権の申し立てが付きにくいもの）
- 素材メモ
  - `01_puppies` は元データが 720×1280 のため、150% に拡大しています（少しやわらかい画質）
  - `03_stethoscope` は 1440×2560 版を 75% に縮小しています
  - `05_実写素材_差し替え用` の映像は海外の病院の様子です。実際に使う際は自院で撮影した映像への差し替えをおすすめします
