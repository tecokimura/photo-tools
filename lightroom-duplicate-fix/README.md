# lightroom-duplicate-fix

Lightroom 書き出し時に発生しやすい `-2.jpg` 付きファイルを対象に、連番を整理するための簡易スクリプトです。

## 何をするツールか
同一フォルダ内に `AAA.jpg` と `AAA-2.jpg` がある場合に、`AAA.jpg` を `AAA-1.jpg` へリネームします。

- 目的: `-2` が付いた重複ファイルがあるときに、元ファイル名を `-1` に寄せる
- 対象: `*.jpg`（小文字のみ）
- 探索: 指定ディレクトリ配下を `find` で走査（サブディレクトリ含む）

## 使い方
```bash
# 変更予定だけ確認
./lightroom-duplicate-fix.sh --dry-run /path/to/photos

# 実際にリネーム
./lightroom-duplicate-fix.sh /path/to/photos

# バックアップを作ってから実行
./lightroom-duplicate-fix.sh --backup /path/to/photos
```

## オプション
- `--dry-run`: 実際には変更せず、予定のみ表示
- `--backup`: `AAA-2.jpg` のコピーを `AAA.jpg.backup` として作成してから処理

## 実際の判定ロジック
1. `-2` で終わる `*.jpg` を見つける（例: `AAA-2.jpg`）
2. 同じ場所に `AAA.jpg` が存在するか確認
3. `AAA-1.jpg` が未存在なら、`AAA.jpg -> AAA-1.jpg` にリネーム

## 挙動例
初期状態:
- `AAA.jpg`
- `AAA-2.jpg`
- `BBB-2.jpg`（`BBB.jpg` は存在しない）

`--dry-run` 実行時の例:
- `Dry run: Renaming AAA.jpg to AAA-1.jpg`
- `Error: File 'BBB.jpg' does not exists. Skipping renaming BBB-2.jpg.`

本実行後の状態:
- `AAA-1.jpg`
- `AAA-2.jpg`
- `BBB-2.jpg`（スキップのためそのまま）

## 注意点
- 対象拡張子は `*.jpg` のみで、`*.JPG` は対象外です。
- リネーム対象は `AAA-2.jpg` 側ではなく `AAA.jpg` 側です。
- `AAA.jpg` が存在しない場合や `AAA-1.jpg` が既にある場合はスキップします。
- このスクリプトは処理件数サマリを表示しません。
