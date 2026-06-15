# CLAUDE.md エントリポイントの扱い

AGENTS.mdは実体ファイルとして生成する。CLAUDE.md symlinkの扱いを定める。

## 原則

- **AGENTS.mdは実体ファイル**として生成する。
- **CLAUDE.md symlinkは常時生成しない**。
- 実行中のエージェントが**自身をClaudeと認識している場合のみ**、CLAUDE.md → AGENTS.md のsymlink作成をユーザーに**提案**する。作成するかはユーザーの判断。
- 非Claudeエージェントが実行している場合は**提案しない**（ユーザーが明示依頼すれば従う）。

## なぜsymlinkか

Claude系エージェントは `CLAUDE.md` を読む。
AGENTS.mdの内容をClaudeにも適用させたい場合、`CLAUDE.md` を `AGENTS.md` へのsymlinkにすると、内容を二重管理せず一本化できる。実体コピーは更新漏れでドリフトするため避ける。

## 判定フロー

1. 実行中のエージェントが自身をClaude（Claude Code / Claude 系）と認識しているか確認する。
2. **Claudeと認識している場合のみ**: ユーザーに「CLAUDE.md を AGENTS.md へのsymlinkとして作成しますか」と提案する。
3. ユーザーが承諾したら作成する。承諾しなければ作成しない。
4. 非Claudeエージェントの場合は提案しない。ただしユーザーが明示的にsymlink作成を依頼した場合は従う。

## 作成手順

リポジトリルートで以下を実行する（`CLAUDE.md` が既に存在する場合は上書き可否をユーザーに確認する）。

```sh
ln -s AGENTS.md CLAUDE.md
```

相対パスのsymlinkにすること（リポジトリを移動・clone してもリンクが保たれる）。

## 改善ユースケースでの確認

既存リポジトリの監査時:

- `CLAUDE.md` が `AGENTS.md` の**実体コピー**になっている場合 → symlink化を提案（二重管理の解消、Claudeと認識している場合）。
- `CLAUDE.md` が壊れたsymlink・誤った対象を指している場合 → 修正を提案。
- `CLAUDE.md` が存在しない場合 → 上記判定フローに従う（Claudeと認識している場合のみ提案）。
