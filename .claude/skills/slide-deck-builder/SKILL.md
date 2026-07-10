---
name: slide-deck-builder
description: build powerpoint-ready slide content from a structured analysis summary, especially the standardized handoff produced by analysis-output-summarizer. use when chatgpt needs to turn selected findings, recommended visuals, storyline notes, and caveats into a clear japanese presentation outline, slide draft, speaker notes, or a finished powerpoint deck for internal reporting.
---

# Overview

分析サマリーを受け取り、統一デザインの PowerPoint ファイルを生成する。
スライドテキスト・スピーカーノートはすべて日本語で書く（ユーザーが別言語を指定した場合を除く）。

## 使用する参照ファイル

| ファイル | 内容 |
|----------|------|
| `references/design-spec.md` | フォント・カラー・スライドサイズ仕様 |
| `references/md-slide-format.md` | スライドスクリプト MD の書式仕様 |
| `references/slide-structure.md` | 標準スライド構成・レイアウト種別・枚数目安 |
| `references/writing-rules.md` | 日本語スライド文体・箇条書きルール |
| `references/visual-placement-rules.md` | 図の配置・キャプション・省略ルール |
| `references/key-point-for-creating-slides.md` | 良いスライドを作るための設計原則（ストーリー・強弱・削る・聴衆視点） |
| `references/components_catalog.pptx` | デザインシステムの見本（スライドサイズ・カラーの参照元） |

# Required behavior

- `analysis-output-summarizer` の `SLIDE_INPUT` が渡された場合は、それを一次情報として使う。
- 目的 → 手法 → 結果 → 解釈 → 次のアクション の順で一貫したストーリーを構築する。
- 1スライド1主張を厳守する。
- 図は主メッセージを強化する場合のみ使う。
- 上流サマリーが暫定的な表現を使っている場合は、そのまま引き継ぐ（断定しない）。
- 生データを再分析しない（明示的に求められた場合または明らかに必要な場合を除く）。

# Required workflow

## 1. 入力の読み込みと slide_script.md ヘッダーへのマッピング

`analysis-output-summarizer` の `SLIDE_INPUT` が渡された場合は以下のマッピングで読み込む。
直接入力の場合は同じ項目をユーザーの文章から抽出する。

| SLIDE_INPUT フィールド | slide_script.md フロントマター / 本文への対応 |
|------------------------|----------------------------------------------|
| `presentation_goal` | フロントマター `subtitle` に要約して記載 |
| `audience` | スピーカーノートの語り口調に反映（専門度に合わせる） |
| `recommended_slide_count` | スライド枚数の目安として使う（`slide-structure.md` の範囲内で調整） |
| `recommended_sections` | `section` レイアウトのスライドタイトルに使う |
| `key_messages` | 各結果スライドのタイトル（主張）に使う |
| `selected_figures[].path` | `**図:**` に記載するファイルパス（分析ディレクトリからの相対パス） |
| `selected_figures[].message` | `**キャプション:**` に使う |
| `backup_figures` | バックアップスライドとして末尾に追加（メインには使わない） |
| `cautions` | 注意事項スライドの箇条書きに使う |
| `open_questions` | 次のアクションスライドに「未解決事項」として添える |

フロントマターの `title` は `presentation_goal` または分析ディレクトリ名から簡潔に設定する。
`author` と `date` はユーザーに確認する（不明な場合は空欄にして確認を求める）。

## 2. スライド構成の設計

`slide-structure.md` の標準フローに従い、各スライドに layout 種別を割り当てる。
スライド枚数は目的に合わせて調整する（`slide-structure.md` の枚数目安を参照）。

## 3. slide_script.md の作成

`md-slide-format.md` の書式に従って `{分析ディレクトリ}/output/slides/slide_script.md` を作成する。

- タイトルは主張を1行で述べる（`writing-rules.md` に従う）
- 図の配置は `visual-placement-rules.md` に従う
- スピーカーノートは `<!-- notes: -->` に書く

作成後、ユーザーに内容確認を求める。

## 4. 設計書の完成と案内

1. `slide_script.md` のフロントマターにデザイン定数（フォント・色・スライドサイズ）が含まれていることを確認する
2. 完成した設計書のパス（`{分析ディレクトリ}/output/slides/slide_script.md`）をユーザーに伝える
3. このファイルを Claude Desktop / Claude.ai などに添付して「このMDの仕様に従ってPowerPointを作成して」と依頼するよう案内する

# Output requirement

**最終成果物は `slide_script.md`（設計書）。Python スクリプトは実行しない。**

| ユーザーの指定 | 動作 |
|----------------|------|
| 指定なし | Step 0〜4 をすべて実行して設計書を生成する |
| 「アウトラインだけ」 | Step 3 で止める（構成案のみ、デザイン定数なし） |
| 「内容を確認してから」 | Step 3 まで実行してユーザー確認後に Step 4 へ進む |

# What not to do

- スライドに情報を詰め込まない（1スライド1主張）
- バックアップ用図を理由なくメイン図にしない
- 重要な注意事項を省略しない
- スライドにレポート調の長文を書かない
- フォント・カラーを `design-spec.md` の仕様から逸脱させない
