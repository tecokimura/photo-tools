#!/bin/bash

# ヘルプメッセージの表示
usage() {
  echo "Usage: $0 [--dry-run] [--backup] DIRECTORY_PATH"
  exit 1
}

# コマンドライン引数の数が不足している場合はヘルプを表示
if [ $# -lt 1 ]; then
  usage
fi

dry_run=false
backup=false

# オプションの処理
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=true
      shift
      ;;
    --backup)
      backup=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

# コマンドライン引数が渡されなかった場合はヘルプを表示
if [ $# -ne 1 ]; then
  usage
fi

# 渡されたディレクトリパスを確認
directory="$1"

# 渡されたディレクトリが存在しない場合はエラーメッセージを表示して終了
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' not found."
  exit 1
fi

# 拡張子がjpgのファイルリストを取得
jpg_files=$(find "$directory" -name '*.jpg')

# 画像が存在しない場合は処理をスキップ
if [ -z "$jpg_files" ]; then
  echo "No images found in $directory. Exiting..."
  exit 0
fi

# 進捗を表示するための変数
total_files=$(echo "$jpg_files" | wc -l)

# ファイルごとに処理
while IFS= read -r file; do

    # ファイル名から拡張子を取り除く
    filename=$(basename -- "$file")
    filename_no_extension="${filename%.*}"
    
    # ファイル名が"-2"で終わる場合の処理
    if [[ $filename_no_extension == *"-2" ]]; then
        # AAA-2.jpgのような形式からAAAを抽出
        original_name=$(echo "$filename_no_extension" | sed 's/-2$//')
        
        # 元ファイル名と新しいファイル名を生成
        old_filename="${original_name}.jpg"
        new_filename="${original_name}-1.jpg"

        # 元ファイルの存在チェック
        if [ ! -f "$(dirname "$file")/$old_filename" ]; then
          echo "Error: File '$old_filename' does not exists. Skipping renaming $filename."
          continue
        fi

        # 新ファイル名の重複チェック
        if [ -e "$(dirname "$file")/$new_filename" ]; then
          echo "Error: File '$new_filename' already exists. Skipping renaming $filename."
          continue
        fi
        
        # バックアップの作成
        if [ "$backup" = true ]; then
          cp "$file" "$(dirname "$file")/${old_filename}.backup"
        fi
        
        # --dry-runオプションが渡された場合はリネームせずにログだけを出力
        if [ "$dry_run" = true ]; then
          echo "Dry run: Renaming $old_filename to $new_filename"
        else
          # ファイルをリネーム
          mv "$(dirname "$file")/$old_filename" "$(dirname "$file")/$new_filename"
        
          # ログを出力
          echo "Renamed $old_filename to $new_filename"
        fi
    fi
    
done <<< "$jpg_files"
