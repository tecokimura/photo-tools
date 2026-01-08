#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
使い方:
  lens-log.sh --dir <PATH> [--format csv|tsv] [--debug]

必須:
  --dir, -d      解析する画像ディレクトリ

任意:
  --format, -f   出力形式 (csv または tsv。既定: csv)
  --debug        実行コマンドを表示
  --help, -h     このヘルプを表示
EOF
}

DIR=""
FORMAT="tsv"
DEBUG=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir|-d)
      DIR="${2-}"
      shift 2
      ;;
    --format|-f)
      FORMAT="${2-}"
      shift 2
      ;;
    --debug)
      DEBUG=true
      shift
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      printf '不明なオプションです: %s\n\n' "$1" >&2
      show_help >&2
      exit 1
      ;;
  esac
done

if [[ -z "$DIR" ]]; then
  printf '--dir オプションで対象ディレクトリを指定してください。\n' >&2
  exit 1
fi

if [[ "$FORMAT" != "csv" && "$FORMAT" != "tsv" ]]; then
  printf 'format は csv か tsv を指定してください (指定値: %s)\n' "$FORMAT" >&2
  exit 1
fi

if ! command -v exiftool >/dev/null 2>&1; then
  printf 'exiftool が見つかりません。インストールしてください。\n' >&2
  exit 1
fi

if ! command -v realpath >/dev/null 2>&1; then
  printf 'realpath が必要です。\n' >&2
  exit 1
fi

TARGET_DIR="$(realpath "$DIR")"

if [[ ! -d "$TARGET_DIR" ]]; then
  printf '指定したパスはディレクトリではありません: %s\n' "$TARGET_DIR" >&2
  exit 1
fi

jpg_files=()
while IFS= read -r -d '' file; do
  jpg_files+=("$file")
done < <(find "$TARGET_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0 | sort -z)

if [[ ${#jpg_files[@]} -eq 0 ]]; then
  printf '指定されたディレクトリに JPG/JPEG ファイルが見つかりませんでした。\n' >&2
  exit 0
fi

fields=(-CreateDate -FocalLength -FNumber -ShutterSpeedValue -ISO -LensModel -Model -FileName)
header=$'Create Date\tFocal Length\tF Number\tShutter Speed Value\tISO\tLens Model\tCamera Model Name\tFile Name'

exif_cmd=(exiftool -api MissingTagValue=none -d '%Y/%m/%d' -T "${fields[@]}" "${jpg_files[@]}")
if $DEBUG; then
  printf '実行コマンド: %q\n' "${exif_cmd[@]}" >&2
fi

if ! exif_output="$("${exif_cmd[@]}")"; then
  printf 'exiftool の実行に失敗しました。\n' >&2
  exit 1
fi

delimiter=$'\t'
if [[ "$FORMAT" == "csv" ]]; then
  delimiter=','
  header="${header//$'\t'/,}"
  exif_output="$(printf '%s\n' "$exif_output" | sed 's/\t/,/g')"
fi

printf '%s\n' "$header"
printf '%s\n' "$exif_output"
