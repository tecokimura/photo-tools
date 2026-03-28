# photo-tools

写真整理向けの小さなCLIツール集です。各ツールはディレクトリ単位で実行します。

## ツール一覧
- [exif-rename](./exif-rename/README.md): EXIF日時ベースで `jpg/JPG` を `YYMMDD_HHMMSS` 形式にリネーム
- [exif-update](./exif-update/README.md): ファイル名の日時をもとに EXIF 日付を更新
- [lens-log](./lens-log/README.md): EXIF情報を TSV/CSV で一覧出力
- [lightroom-duplicate-fix](./lightroom-duplicate-fix/README.md): Lightroom由来の重複名調整用スクリプト

## exif-rename のクイックガイド
詳細は [exif-rename README](./exif-rename/README.md) を参照。

### 目的
指定フォルダ直下の `*.jpg` / `*.JPG` を、撮影日時ベースのファイル名に変更します。

### 命名ルール
- 基本: `YYMMDD_HHMMSS.jpg`（拡張子は元ファイルを維持）
- 重複時: `-01`, `-02` を付与
- 任意文字列: `--suffix` で拡張子前に追加

例:
- `IMG_1001.jpg` -> `240315_142530.jpg`
- 重複時 -> `240315_142530-01.jpg`
- `--suffix _tokyo` -> `240315_142530_tokyo.jpg`

### 基本的な使い方
```bash
# まずは変更予定を確認
./exif-rename/exif-rename.sh --dry-run /path/to/photos

# 問題なければ実行
./exif-rename/exif-rename.sh /path/to/photos
```

### よく使うオプション
```bash
# DateTimeOriginal が無い場合に CreateDate を使う
./exif-rename/exif-rename.sh --fallback-create-date /path/to/photos

# 拡張子の前に任意の文字列を追加
./exif-rename/exif-rename.sh --suffix _tokyo /path/to/photos
```

### 挙動の要点
- 対象は「指定ディレクトリ直下のみ」（再帰しない）
- デフォルトでは `DateTimeOriginal` が無いファイルはスキップ
- 最後に `Summary`（Total/Renamed/Unchanged/Skipped）を表示

## 必要環境
- bash
- exiftool（`exif-rename` / `exif-update` / `lens-log` で使用）
