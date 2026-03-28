#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'USAGE'
使い方:
  exif-rename.sh [--dry-run] [--fallback-create-date] [--suffix TEXT] <DIRECTORY>

説明:
  指定ディレクトリ直下の *.jpg / *.JPG を、撮影日時ベースの
  YYMMDD_HHMMSS 形式へリネームします。

オプション:
  --dry-run                 実際には変更せず、変更予定のみ表示
  --fallback-create-date    DateTimeOriginal が無い場合に CreateDate を使用
  --suffix TEXT             拡張子の前に任意文字列を追加
  --help, -h                このヘルプを表示
USAGE
}

DRY_RUN=false
USE_CREATE_DATE_FALLBACK=false
SUFFIX=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --fallback-create-date)
      USE_CREATE_DATE_FALLBACK=true
      shift
      ;;
    --suffix)
      if [[ $# -lt 2 ]]; then
        printf 'Error: --suffix には値が必要です。\n' >&2
        exit 1
      fi
      SUFFIX="$2"
      shift 2
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    --*)
      printf 'Error: 不明なオプションです: %s\n\n' "$1" >&2
      show_help >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -ne 1 ]]; then
  show_help >&2
  exit 1
fi

TARGET_DIR="$1"

if [[ ! -d "$TARGET_DIR" ]]; then
  printf 'Error: Directory not found: %s\n' "$TARGET_DIR" >&2
  exit 1
fi

if ! command -v exiftool >/dev/null 2>&1; then
  printf 'Error: exiftool が見つかりません。\n' >&2
  exit 1
fi

files=()
while IFS= read -r -d '' file; do
  files+=("$file")
done < <(find "$TARGET_DIR" -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.JPG' \) -print0 | sort -z)

if [[ ${#files[@]} -eq 0 ]]; then
  printf 'No jpg/JPG files found in: %s\n' "$TARGET_DIR"
  exit 0
fi

declare -A existing_names=()
declare -A planned_names=()

total_count=${#files[@]}
rename_count=0
skip_count=0
unchanged_count=0

sources=()
targets=()

for file in "${files[@]}"; do
  src_name="$(basename "$file")"
  existing_names["$src_name"]=1
done

for file in "${files[@]}"; do
  src_name="$(basename "$file")"
  extension="${src_name##*.}"

  timestamp="$(exiftool -s3 -d '%y%m%d_%H%M%S' -DateTimeOriginal "$file" 2>/dev/null || true)"
  source_tag="DateTimeOriginal"

  if [[ -z "$timestamp" && "$USE_CREATE_DATE_FALLBACK" == true ]]; then
    timestamp="$(exiftool -s3 -d '%y%m%d_%H%M%S' -CreateDate "$file" 2>/dev/null || true)"
    source_tag="CreateDate"
  fi

  if [[ -z "$timestamp" ]]; then
    printf 'Skip: %s (DateTimeOriginal が見つかりません)%s\n' \
      "$src_name" \
      "$( [[ "$USE_CREATE_DATE_FALLBACK" == true ]] && printf ' / CreateDate も未設定' )"
    ((skip_count+=1))
    continue
  fi

  base_name="${timestamp}${SUFFIX}"
  candidate="${base_name}.${extension}"
  seq=1

  while :; do
    in_existing=false
    if [[ -n "${existing_names[$candidate]+x}" && "$candidate" != "$src_name" ]]; then
      in_existing=true
    fi

    in_planned=false
    if [[ -n "${planned_names[$candidate]+x}" ]]; then
      in_planned=true
    fi

    if [[ "$in_existing" == false && "$in_planned" == false ]]; then
      break
    fi

    candidate="${base_name}-$(printf '%02d' "$seq").${extension}"
    ((seq+=1))
  done

  if [[ "$candidate" == "$src_name" ]]; then
    printf 'Keep: %s (already matches %s)\n' "$src_name" "$source_tag"
    ((unchanged_count+=1))
    planned_names["$candidate"]=1
    continue
  fi

  sources+=("$file")
  targets+=("$(dirname "$file")/$candidate")
  planned_names["$candidate"]=1
  ((rename_count+=1))

done

for i in "${!sources[@]}"; do
  src="${sources[$i]}"
  dst="${targets[$i]}"

  if [[ "$DRY_RUN" == true ]]; then
    printf '[Dry-run] %s -> %s\n' "$(basename "$src")" "$(basename "$dst")"
  else
    mv "$src" "$dst"
    printf 'Renamed: %s -> %s\n' "$(basename "$src")" "$(basename "$dst")"
  fi
done

printf '\nSummary:\n'
printf '  Total files: %d\n' "$total_count"
printf '  Renamed: %d\n' "$rename_count"
printf '  Unchanged: %d\n' "$unchanged_count"
printf '  Skipped: %d\n' "$skip_count"
