# slide-deck-builder Skill — 使い方ガイド

このドキュメントは **人間向け**の説明です。
Claude への指示は `SKILL.md` と `references/` 配下の各ファイルが担います。

---

## このSkillが何をするか

分析結果のサマリーを受け取り、**PowerPoint の精密な設計書（MD ファイル）** を生成します。
その設計書を Claude Desktop / Claude.ai などに読み込ませることで、統一デザインのスライドを作成します。

```
分析サマリー（または SLIDE_INPUT）
        ↓
  slide_script.md（スライド設計書）
        ↓
  Claude Desktop / Claude.ai などに添付して「このMDでPPT作って」
        ↓
    slides.pptx（完成ファイル）
```

設計書にフォント・色・スライドサイズを明記するため、
誰が使っても・どのツールで生成しても **同じ仕様** になるように設計されています。

---

## 使い方

### 基本の呼び出し方

Claude に以下のように依頼します。

```
/slide-deck-builder
```

または：

```
この分析結果からスライドを作って
```

### 入力として渡せるもの

| 渡すもの | 説明 |
|----------|------|
| `analysis-output-summarizer` の出力（SLIDE_INPUT） | 最も推奨。フィールドが自動でスライドにマッピングされる |
| 分析の説明文や README | 直接テキストで渡してもよい |
| 既存の `slide_script.md` | 「このMDからPPT作って」と渡せば Step 4 から開始できる |

### 出力されるもの

| ファイル | 場所 | 説明 |
|----------|------|------|
| `slide_script.md` | `{分析ディレクトリ}/output/slides/` | スライド設計書（デザイン定数・構成・内容を含む） |

この設計書を Claude Desktop / Claude.ai に添付して「このMDの仕様に従ってPowerPointを作成して」と依頼します。

### 途中で止めたい場合

```
アウトラインだけ確認したい    → slide_script.md を作った時点で止まる
内容を確認してから続けてほしい → slide_script.md を確認後、OKを出せば Step 4（案内）へ進む
```

---

## ファイル構成と役割

```
slide-deck-builder/
├── README.md                        ← このファイル（人間向け説明）
├── SKILL.md                         ← Claudeへの指示（ワークフロー定義）
├── agents/
│   └── openai.yaml                  ← Skill の表示名・説明（システム設定）
└── references/
    ├── components_catalog.pptx      ← デザインシステムの見本（色・サイズの参照元）
    ├── design-spec.md               ← フォント・色・スライドサイズ仕様
    ├── md-slide-format.md           ← slide_script.md の書き方ルール
    ├── slide-structure.md           ← スライドの並び順・枚数・レイアウト種別
    ├── writing-rules.md             ← タイトル・箇条書きの文章ルール
    ├── visual-placement-rules.md    ← 図の配置・キャプションのルール
    └── key-point-for-creating-slides.md  ← 良いスライドを作る設計原則
```

### 各ファイルの一言説明

| ファイル | 「何が書いてあるか」 | 「誰が使うか」 |
|----------|---------------------|----------------|
| `SKILL.md` | Claudeへの指示・ワークフロー | Claude |
| `design-spec.md` | フォント名・色コード・スライドサイズ（全部実測値） | Claude |
| `md-slide-format.md` | `slide_script.md` の書式（フロントマター・layout 指定・箇条書き） | Claude・人間が手で書く場合 |
| `slide-structure.md` | 何枚目にどのスライドを置くか（表紙→背景→結果→結び） | Claude |
| `writing-rules.md` | タイトルは25文字以内・箇条書きは2〜4項目・断定しない表現など | Claude |
| `visual-placement-rules.md` | 図は1枚に1つ・キャプション必須・ノイズが多い図は使わない | Claude |
| `key-point-for-creating-slides.md` | ストーリーで理解させる・強弱をつける・削る・聴衆視点で作る | Claude |
| `components_catalog.pptx` | デザインシステムの見本集（色・サイズの参照元） | デザイン確認時に人間が参照 |

---

## スライドの layout 種別一覧

`slide_script.md` で `<!-- layout: xxx -->` に指定できる値です。

| layout 値 | 見た目 | 使う場面 |
|-----------|--------|----------|
| `title` | 大きなタイトル・担当者・日付 | 表紙 |
| `section` | セクション名のみ（teal 色大文字） | 章の区切り |
| `content` | タイトル + 箇条書き | 背景・手法・解釈・注意事項 |
| `figure` | タイトル + 図（大きく表示） | グラフや図が主役のスライド |
| `figure-text` | タイトル + 図（左）+ 箇条書き（右） | 図と観察コメントを並べたいとき |
| `closing` | タイトル + 箇条書き + 結論バナー | 次のアクション・まとめ |

---

## よくある質問

**Q: slide_script.md を手で書いてもいいですか？**
A: はい。[`references/md-slide-format.md`](references/md-slide-format.md) の書式に従えば、Claude を経由せずに直接記述できます。

**Q: components_catalog.pptx は何のためにありますか？**
A: デザインシステムの見本集です。色・フォント・スライドサイズ（10 × 5.625 inch）の確認に使えます。

---

## 上流Skillとの連携

`analysis-output-summarizer` と組み合わせると自動でスライド構成が決まります。

```
/analysis-output-summarizer  →  SLIDE_INPUT を生成
/slide-deck-builder          →  SLIDE_INPUT を読んでスライドを生成
```

`SLIDE_INPUT` の各フィールドがどのスライドにマッピングされるかは
`SKILL.md` の「入力の読み込みとマッピング」テーブルを参照してください。
