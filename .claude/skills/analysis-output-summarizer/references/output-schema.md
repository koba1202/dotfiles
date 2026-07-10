# Output Schema

Always produce the final output in Japanese.

Use the following section order exactly:

## 1. 分析目的
State the likely analysis objective in 2 to 4 lines.

## 2. 入力アーティファクト一覧
For each important artifact include:
- 名称
- 種別
- 想定役割
- 重要度

## 3. 主要な観察結果
Provide 3 to 7 findings.
For each finding include:
- タイトル
- 根拠アーティファクト
- 観察内容
- 解釈
- 確信度
- 表現上の注意

## 4. 採用推奨図
For each recommended figure include:
- 図の名称
- この図で伝えるべきこと
- 採用理由
- 優先度

## 5. 注意点・限界
List the key caveats and unresolved issues.

## 6. スライド化に向けた整理
Include:
- 推奨ストーリー
- 推奨章立て
- 想定スライド枚数
- 必ず入れるべき図
- 予備扱いの図

## 7. SLIDE_INPUT
Use the exact structure below.

SLIDE_INPUT
- presentation_goal:
- audience:
- preferred_language: Japanese
- recommended_slide_count:
- recommended_sections:
  -
- key_messages:
  -
- selected_figures:
  - figure_name:
    path:          # 分析ディレクトリからの相対パス（例: output/figures/xxx.png）
    message:
    priority:
- backup_figures:
  -
- cautions:
  -
- open_questions:
  -