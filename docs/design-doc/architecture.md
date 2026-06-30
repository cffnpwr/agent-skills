# 全体アーキテクチャ

## リポジトリ構成

成果物はAPM（Agent Package Manager）パッケージとして配布する。
`apm.yml`がパッケージのメタ情報を持つ。
スキルは`.apm/skills/<スキル名>/`、hookは`.apm/hooks/`に置く。
設計ドキュメント・ライセンスなど配布対象外のファイルはリポジトリ直下・`docs/`に置く。

```text
.
├─ apm.yml              # APMパッケージのメタ情報
├─ docs/design-doc/     # 設計ドキュメント
└─ .apm/
   ├─ skills/           # スキル（<スキル名>/SKILL.md + 同梱リソース）
   └─ hooks/            # hook（<hook名>.json マニフェスト + scripts/<hook名>/）
```

スキルの内部構成は[スキル機構](./skills.md)、hookの配置規約は[Hook機構](./hooks.md)で定める。

## 配布の仕組み

APMは[microsoft/apm](https://github.com/microsoft/apm)を指す。
`apm install`が`.apm/`配下の各primitive（スキル・hook等）を、検出した各ターゲット（Harness）のランタイムディレクトリへコピー（hoist）する（[package-types](https://github.com/microsoft/apm/blob/main/docs/src/content/docs/reference/package-types.md)）。
hookの対応はターゲットごとに分かれ、Claude・Codex・Gemini・GitHub Copilot等の多くが対応する一方、
OpenCodeはhook概念を持たずskipされる（[targets matrix](https://github.com/microsoft/apm/blob/main/docs/src/content/docs/reference/targets-matrix.md)）。

APMはprimitiveファイルをコピーするが、primitiveが実行時に必要とする言語パッケージ・システムバイナリは導入しない。
このため各成果物は依存を明示宣言してホスト充足を前提に動く（[設計原則](./principles.md)）。

hookマニフェストは`.apm/hooks/`直下の`*.json`を非再帰に探索する（`glob("*.json")`。サブディレクトリは対象外。[plugin_exporter.py](https://github.com/microsoft/apm/blob/main/src/apm_cli/bundle/plugin_exporter.py)・[validation.py](https://github.com/microsoft/apm/blob/main/src/apm_cli/models/validation.py)）。
ネストしたサブディレクトリでは探索されないため、`scripts/`配下の開発ツーリング（`package.json`・`tsconfig.json`等）はマニフェストとして誤検知されない。

## Harnessとモデルの区別

Harnessは、スキル・hookのプロトコルを実装するホスト実行環境（Claude Code、Codex CLI、Gemini CLI、GitHub Copilot CLI等）を指し、推論を行うAIモデルとは区別する。
成果物は複数Harnessへ配布されるため、特定Harness専用の手段に依存しない（[設計原則](./principles.md)）。
スキルはモデルが読むMarkdownとして、hookは移植性の高い終了コードとして、それぞれHarness非依存に成立させる。
