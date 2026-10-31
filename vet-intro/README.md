# 動物病院紹介ショート「さくら小径どうぶつ病院」

架空の動物病院「さくら小径どうぶつ病院」を紹介する縦型ショート動画（1080×1920 / 30fps / 30秒）の編集素材一式です。
雰囲気は「明るくやさしい」。桜並木・日本の住宅街・柴犬・三毛猫・秋田犬など、日本らしい映像で構成しています。映像・BGMはすべてフリー素材（Pexels / Pixabay）です。

> 病院名「さくら小径どうぶつ病院」は架空の名前です。2026年10月31日時点で、同名（「さくらこみち動物病院」「さくら小径動物病院」「桜小径動物病院」の表記も含む）の動物病院がウェブ検索で見つからないことを確認しています。
> 診療時間・休診日・電話番号（000-0000-0000）も**ダミー**です。実際に使うときはテロップを差し替えてください。

## ファイル

| ファイル | 内容 |
|---|---|
| `さくら小径どうぶつ病院_紹介ショート.prproj` | **Premiere Pro プロジェクト**（プロジェクトマネージャーで収集したもの。色調整・聴診器カットの位置調整入り） |
| `さくら小径どうぶつ病院_紹介ショート.mp4` | 書き出した完成動画（H.264 / 1080×1920 / 30fps / 30秒） |
| `vet_intro_premiere.xml` | Premiere Pro 用 XML（FCP7 xmeml v4）。ビン構成・カット・テロップ・BGMまで入っています |
| `media/` | 使用素材すべて（映像6本・BGM・テロップ画像6枚） |
| `fonts/MPLUSRounded1c-ExtraBold.ttf` | テロップのフォント（M PLUS Rounded 1c / SIL OFL） |
| `tools/make_telops.ps1` | テロップ画像（透過PNG）を作り直すスクリプト |
| `tools/build_xml.ps1` | XML を作り直すスクリプト |
| `tools/credits.json` | 素材クレジット（下の表と同じ内容） |

## Premiere Pro のビン構成

| ビン | 中身 |
|---|---|
| `01_シーケンス` | シーケンス「さくら小径どうぶつ病院_紹介ショート」 |
| `02_背景映像` | 桜並木・東京の住宅街・柴犬・三毛猫・秋田犬の映像、色調整用の調整レイヤー（.prproj のみ） |
| `03_テロップ` | テロップ画像 `telop_00`〜`telop_05` |
| `04_音声` | BGM |
| `05_実写素材_差し替え用` | 聴診器の診察シーン。**実際の病院で撮った映像に差し替える前提**の仮素材 |

## タイムライン

| トラック | 内容 |
|---|---|
| V3 | テロップ（下表） |
| V2 | 調整レイヤー（Lumetri カラー：色温度 +12・彩度 110・露光量 +0.4・コントラスト −10・シャドウ +15・白レベル +10）※.prproj のみ |
| V1 | 映像6カット（カット間に12フレームのクロスディゾルブ） |
| A1 | BGM（−4.4dB、最後の2秒でフェードアウト） |

| 時間 | 映像 | テロップ |
|---|---|---|
| 0:00〜0:05 | 桜並木の散歩道と小型犬（愛知・豊川） | やさしく、あたたかく。／さくら小径どうぶつ病院 |
| 0:05〜0:09 | 東京の住宅街 | 街の、かかりつけ動物病院／お散歩のついでに、気軽にどうぞ |
| 0:09〜0:12 | 聴診器で診察（犬のアップ） | からだの声に耳をすませて／ていねいな診察を心がけています |
| 0:12〜0:18 | 日本家屋の柴犬 | おうちでの様子も／気になることは何でもご相談ください |
| 0:18〜0:24 | 窓辺の三毛猫 | ねこちゃんもおまかせ／猫にやさしい診察で、ストレス少なく |
| 0:24〜0:30 | 桜の下の秋田犬 | エンドカード（病院名・診療時間・休診日・TEL・お気軽にご相談ください） |

- テロップは**画面下20%（y>1536）と右端180px**に入らないよう、x=60〜900・y≦1480 に収めています（ショートのボタンやタイトルで隠れないため）
- エンドカードは秋田犬が画面下側にいるので、パネルを上側（y=380〜1040、桜の部分）に置いています
- 聴診器カット（1440×2560）は獣医師の顔が映らないよう、**スケール 160%・位置Y −112** にして下側（犬と聴診器）だけを見せています。素材の後半は犬を持ち上げて顔が入るので、前半の3秒だけ使っています（XML から読み込んだ場合は、この位置調整を手で入れてください）

## 開き方

### A. .prproj を開く（おすすめ）
1. `vet-intro` フォルダごとPCにダウンロードする（フォルダ構成は変えない）
2. `さくら小径どうぶつ病院_紹介ショート.prproj` をダブルクリック
3. 「メディアをリンク」画面が出たら `media/` 内のどれか1つを指定 → 残りは自動でリンクされます

### B. XML から読み込む
1. Premiere Pro →「ファイル」→「読み込み」（または「プロジェクトを開く」）→ `vet_intro_premiere.xml`
2. 「メディアをリンク」画面が出たら `media/` 内のファイルを1つ指定
3. XML には色調整（調整レイヤー）と聴診器カットの位置調整が入っていないので、必要なら次を設定します
   - 「ファイル → 新規 → 調整レイヤー」を V2 に置き、上の数値で Lumetri カラーを設定
   - 聴診器カットのスケール 160%・位置Y −112

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
| `media/01_sakura_stroll_31295367.mp4` | Cherry Blossom Stroll in Toyokawa, Japan | [Tien Nguyen](https://www.pexels.com/@tiennguyen) | https://www.pexels.com/video/cherry-blossom-stroll-in-toyokawa-japan-31295367/ | Pexels License |
| `media/02_tokyo_street_35306935.mp4` | Peaceful Suburban Street in Tokyo | [Miltan Monjib](https://www.pexels.com/@miltan-monjib-204165102) | https://www.pexels.com/video/peaceful-suburban-street-in-tokyo-35306935/ | Pexels License |
| `media/03_stethoscope_6235191_uhd.mp4` | Veterinarian Listening Heart Of Small Dog With Stethoscope | [Tima Miroshnichenko](https://www.pexels.com/@tima-miroshnichenko) | https://www.pexels.com/video/veterinarian-listening-heart-of-small-dog-with-stethoscope-6235191/ | Pexels License |
| `media/04_shiba_29243898.mp4` | Cute Shiba Inu Relaxing by a Sunlit Doorway | [Rin Gakusho](https://www.pexels.com/@rin-gakusho-280714394) | https://www.pexels.com/video/cute-shiba-inu-relaxing-by-a-sunlit-doorway-29243898/ | Pexels License |
| `media/05_calico_cat_35486843.mp4` | Playful Calico Cat Basking in Sunlight | [Fara Pardasi](https://www.pexels.com/@FaraPardasi) | https://www.pexels.com/video/playful-calico-cat-basking-in-sunlight-35486843/ | Pexels License |
| `media/06_akita_sakura_31643071.mp4` | Akita Inu Dog Resting Under Spring Blossoms | [Efrem Efre](https://www.pexels.com/@efrem-efre-2786187) | https://www.pexels.com/video/akita-inu-dog-resting-under-spring-blossoms-31643071/ | Pexels License |
| `media/bgm_happy_ukulele_512480.mp3` | Happy Ukulele | [BombinSound](https://pixabay.com/users/bombinsound-54782632/) | https://pixabay.com/music/happy-childrens-tunes-happy-ukulele-512480/ | Pixabay Content License |
| `fonts/MPLUSRounded1c-ExtraBold.ttf` | M PLUS Rounded 1c | M+ FONTS PROJECT | https://fonts.google.com/specimen/M+PLUS+Rounded+1c | SIL Open Font License 1.1 |

- Pexels License・Pixabay Content License とも、商用利用可・クレジット表記は任意です（素材そのものの再配布・販売は不可）
- BGM は Pixabay で「Content ID 登録なし」の曲を選んでいます（YouTube で著作権の申し立てが付きにくいもの）
- 素材メモ
  - 日本人スタッフが映った動物病院の映像は Pexels / Pixabay に見つからなかったため、病院の場面は聴診器のアップ1カットのみ（顔が映らないよう切り出し）にしています。実際に使う際は自院で撮影した映像への差し替えをおすすめします
  - 秋田犬の映像は撮影地が日本ではありません（桜と秋田犬で日本らしい雰囲気のため採用）
  - `05_calico_cat` は元素材が81秒・約80MBあります（使っているのは中盤の6秒）
  - 素材のフレームレートは 25 / 30 / 59.94fps が混在しています（シーケンスは 30fps）
