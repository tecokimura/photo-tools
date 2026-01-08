# LensLog (Shell版)

指定ディレクトリ内の JPG/JPEG を再帰的に走査し、撮影日時やレンズ情報などのEXIFを TSV/CSV で出力するシェルスクリプトです。

## 必要環境
- bash 4 以降
- exiftool
- coreutils の `find` / `realpath`

## 使い方
- 実行権限を付与: `chmod +x ./lens-log.sh`
- 基本: `./lens-log.sh --dir ./photos`
- TSV出力（デフォルト）: `./lens-log.sh --dir ./photos`
- CSV出力: `./lens-log.sh --dir ./photos --format csv`
- デバッグ（実行コマンド表示）: `./lens-log.sh --dir ./photos --debug`

### オプション
- `--dir, -d` (必須): 解析対象ディレクトリ
- `--format, -f` (任意): `csv` または `tsv`。既定は `tsv`
- `--debug` (任意): 実行する exiftool コマンドを標準エラーにそのまま表示（例: `exiftool -api MissingTagValue=none -d '%Y/%m/%d' -T ...`）。実際にどのファイル・オプションで実行されているか確認するときに使用
- `--help, -h`: ヘルプ表示

## 出力仕様
- 対象拡張子: `.jpg` / `.jpeg`（大文字小文字を区別しません）
- 走査方法: 再帰的にサブディレクトリを含めて探索
- 欠損値: `none`
- 日付形式: `YYYY/MM/DD`（`Create Date` を変換）
- 列順: `Create Date, Focal Length, F Number, Shutter Speed Value, ISO, Lens Model, Camera Model Name, File Name`

### 出力例 (CSV)
```csv
Create Date,Focal Length,F Number,Shutter Speed Value,ISO,Lens Model,Camera Model Name,File Name
2025/04/16,70.0 mm,2.8,1/125,100,EF70-200mm f/2.8L IS II USM,Canon EOS R5,a.jpg
```

## 補足
- 事前に `exiftool` をインストールしてください。Homebrew が使えない環境では公式サイトから配布パッケージを取得できます。
  - 公式サイト: https://exiftool.org/ （Windows / macOS / Linux 用の配布物あり）
  - Debian/Ubuntu 系: `sudo apt-get install libimage-exiftool-perl`
  - macOS: Homebrew が使えれば `brew install exiftool`、使えない場合は公式サイトの `.dmg` を利用
  - Windows: 公式サイトの ZIP を展開し、`exiftool(-k).exe` を `exiftool.exe` にリネームして PATH に置く
