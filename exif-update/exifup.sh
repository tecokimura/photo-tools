#!/bin/bash

# ヘルプメッセージの表示
usage() {
  echo "Usage: $0 [--dry-run] DIRECTORY_PATH"
  echo "This script updates the Exif DateTimeOriginal, ModifyDate, and CreateDate of JPG files based on their filenames."
  echo "Options:"
  echo "  --dry-run  Show what changes would be made without applying them."
  exit 1
}

# オプション設定
dry_run=false

# 引数チェックとオプション解析
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  usage
fi

if [ "$1" == "--dry-run" ]; then
  dry_run=true
  shift
fi

# 引数で渡されたディレクトリパス
directory="$1"

# ディレクトリが存在するか確認
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' not found."
  exit 1
fi

# 処理結果のカウンタ
processed_count=0
skipped_count=0

# jpgファイルを処理
find "$directory" -type f -iname '*.jpg' | sort | while IFS= read -r file; do
  # ファイル名のみを取得
  filename=$(basename "$file")
  
  # 拡張子を除いた部分を取得
  name_without_extension="${filename%.*}"

  # ファイル名から日付・時間を抽出
  if [[ "$name_without_extension" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})[\ _]([0-9]{2})\.([0-9]{2})\.([0-9]{2})$ ]]; then
    year="${BASH_REMATCH[1]}"
    month="${BASH_REMATCH[2]}"
    day="${BASH_REMATCH[3]}"
    hour="${BASH_REMATCH[4]}"
    minute="${BASH_REMATCH[5]}"
    second="${BASH_REMATCH[6]}"
  elif [[ "$name_without_extension" =~ ^([0-9]{2})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})(.*)$ ]]; then
    # 先頭 YYMMDD_HHMMSS を日時として扱い、以降の文字列は無視する
    year="20${BASH_REMATCH[1]}"
    month="${BASH_REMATCH[2]}"
    day="${BASH_REMATCH[3]}"
    hour="${BASH_REMATCH[4]}"
    minute="${BASH_REMATCH[5]}"
    second="${BASH_REMATCH[6]}"
  else
    echo "Skipping file: $file (Invalid filename format)"
    ((skipped_count++))
    continue
  fi

  # フォーマットされた日時を作成
  datetime="${year}:${month}:${day} ${hour}:${minute}:${second}"
  
  echo "Processing file: $file"
  echo "Updating Exif dates to: $datetime"

  if [ "$dry_run" = true ]; then
    # ドライラン時は更新せずにログのみ出力
    echo "[Dry-run] Would update: $file -> $datetime"
  else
    # 実際にExifデータを更新
    exiftool -overwrite_original \
      "-DateTimeOriginal=$datetime" \
      "-ModifyDate=$datetime" \
      "-CreateDate=$datetime" \
      "-FileModifyDate=$datetime" \
      "-FileCreateDate=$datetime" \
      "$file"
  fi
  
  # 処理カウントを増加
  ((processed_count++))
done

# 処理結果を出力
echo "Processing completed."
echo "Total files processed: $processed_count"
echo "Total files skipped: $skipped_count"
