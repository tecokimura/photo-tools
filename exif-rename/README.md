# exif-rename

指定ディレクトリ直下の `jpg` / `JPG` を、EXIF の撮影日時を使って `YYMMDD_HHMMSS` 形式にリネームする Bash スクリプトです。

## 必要環境
- bash 3.2 以降
- [exiftool](https://exiftool.org/)

## 使い方
```bash
# ドライラン（変更予定のみ表示）
./exif-rename.sh --dry-run /path/to/photos

# 実際にリネーム
./exif-rename.sh /path/to/photos

# DateTimeOriginal が無い場合に CreateDate を利用
./exif-rename.sh --fallback-create-date /path/to/photos

# 拡張子の前に文字列を追加
./exif-rename.sh --suffix _tokyo /path/to/photos
```

## オプション
- `--dry-run`: 実際には変更せず、変更予定のみ表示
- `--fallback-create-date`: `DateTimeOriginal` が無い場合に `CreateDate` を使用
- `--suffix TEXT`: 生成名の末尾（拡張子の前）に `TEXT` を追加
- `--help, -h`: ヘルプ表示

## 命名ルール
- 基本形式: `YYMMDD_HHMMSS`（例: `240315_142530.jpg`）
- `--suffix _tokyo` 指定時: `240315_142530_tokyo.jpg`
- 拡張子は元ファイルを維持（`.jpg` / `.JPG`）

## 重複時の挙動
同名が既に存在する、または同一実行内で競合する場合は `-01`, `-02` の連番を付けます。

例:
- `240315_142530.jpg`
- `240315_142530-01.jpg`
- `240315_142530-02.jpg`

## 対象範囲
- 指定ディレクトリ「直下のみ」を対象にします（再帰なし）。
- 対象拡張子は `*.jpg` と `*.JPG` のみです。

## スキップ条件
- `DateTimeOriginal` が無い場合はスキップします。
- `--fallback-create-date` 指定時は `CreateDate` も確認し、両方無い場合にスキップします。

## 出力ログ
- `Renamed`: 実際にリネームしたファイル
- `[Dry-run]`: 変更予定
- `Keep`: 既に期待名と一致していたファイル
- `Skip`: 必要な日時タグが無く処理対象外のファイル
- 最後に `Summary`（Total/Renamed/Unchanged/Skipped）を表示
