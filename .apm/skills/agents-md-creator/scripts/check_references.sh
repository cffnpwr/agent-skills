#!/bin/sh
# AGENTS.md の検証スクリプト（任意）。
#
# 決定的・冪等な検証処理なので切り出している。手動確認でも代替可能。
# Python 不要。POSIX sh と標準ツール（grep/sed/test 等）のみで動作する。
#
# チェック内容:
#   1. 本体から `.agents/docs/*.md` へのプレーン参照の参照切れ（問題として報告）。
#   2. 本体の `@`参照の検出（禁止ではなく、意図的な常時読み込みか確認を促す警告）。
#      `@`参照は「常時コンテキストに読み込ませたい」設計意図がある場合は許容される。
#      検出しても、それ単独では終了コードを 1 にしない。
#
# 使い方:
#   ./check_references.sh [AGENTS.mdのパス]
#   （省略時はカレントディレクトリの AGENTS.md）
#
# 終了コード: 参照切れがあれば 1、なければ 0（`@`参照の検出だけでは 1 にしない）。

set -euo pipefail

target="${1:-AGENTS.md}"

if [ ! -f "$target" ]; then
    echo "error: $target が見つからない" >&2
    exit 1
fi

# AGENTS.md の親ディレクトリを参照解決の基準にする
root=$(dirname "$target")

problems=0
notices=0

# 1. .agents/docs/*.md への参照を抽出して実在を確認（参照切れは問題）
#    重複除去のうえ各パスを root 基準で test -f する。
refs=$(grep -oE '\.agents/docs/[A-Za-z0-9._/-]+\.md' "$target" | sort -u || true)

if [ -n "$refs" ]; then
    # IFS を改行のみにして 1 行ずつ処理する
    OLDIFS=$IFS
    IFS='
'
    for ref in $refs; do
        if [ ! -f "$root/$ref" ]; then
            echo "参照切れ: $ref が存在しない"
            problems=$((problems + 1))
        fi
    done
    IFS=$OLDIFS
fi

# 2. @参照の検出（行頭または空白後の @path）。
#    禁止ではなく、意図的な常時読み込みかの確認を促す警告。
#    バッククォートで囲われたパッケージ名（`@types/node` 等）は直前が
#    バッククォートのためマッチしない。
notice_lines=$(grep -nE '(^|[[:space:]])@[A-Za-z0-9._/-]+' "$target" || true)

if [ -n "$notice_lines" ]; then
    OLDIFS=$IFS
    IFS='
'
    for entry in $notice_lines; do
        # 行番号と本文を分離する
        lineno=${entry%%:*}
        line=${entry#*:}
        # 行中の各 @参照を抽出して個別に報告する
        matches=$(printf '%s\n' "$line" | grep -oE '(^|[[:space:]])@[A-Za-z0-9._/-]+' || true)
        innerIFS=$IFS
        IFS='
'
        for m in $matches; do
            # 先頭の空白を除去し @参照のみを取り出す
            ref=$(printf '%s' "$m" | sed -E 's/^[[:space:]]*//')
            echo "${lineno}行目: @参照を検出 (${ref}) — 意図的な常時読み込み参照か確認すること"
            notices=$((notices + 1))
        done
        IFS=$innerIFS
    done
    IFS=$OLDIFS
fi

if [ "$problems" -gt 0 ]; then
    exit 1
fi

if [ "$notices" -gt 0 ]; then
    echo "OK: 参照切れなし（上記 @参照は意図を確認すること）"
else
    echo "OK: 参照切れ・@参照なし"
fi
exit 0
