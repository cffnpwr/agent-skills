# 運用

スキル・hookの追加、検証、配布の流れを示す。

## 追加

- スキルは`.apm/skills/<スキル名>/`に作る。skill-creatorスキルが雛形作成・依存宣言・検証を提供する。構成は[スキル機構](./skills.md)に従う。
- hookは`.apm/hooks/`にマニフェスト`<hook名>.json`と実装`scripts/<hook名>/`を置く。配置規約は[Hook機構](./hooks.md)に従う。

## 検証

- スキルのフロントマターと依存宣言の整合は、skill-creator同梱の`quick_validate.py`で検査する。
- hookのテスト可能なロジックには単体テストを置き、実装言語のテストランナーで実行する。

## 配布

成果物はAPM（Agent Package Manager）パッケージとして取り込まれ、各Harnessへデプロイされる。
APMは依存を供給しないため、ホスト環境で依存が充足されている前提で動作する（[設計原則](./principles.md)・[外部ランタイム依存](./dependencies.md)）。
