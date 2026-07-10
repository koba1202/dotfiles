---
name: analysis-output-summarizer
description: summarize analysis scripts, generated figures, tables, logs, and analyst notes into a structured intermediate handoff for slide creation. use when chatgpt needs to review analysis outputs, identify reporting-worthy findings, select the most useful visuals, separate confirmed observations from tentative interpretations, and prepare a stable slide-building input.
---

# Overview

Summarize analysis artifacts into a reusable presentation handoff.
Write the final output in Japanese unless the user explicitly requests another language.

## Use the following references
- `references/output-schema.md` for the required output structure
- `references/figure-selection-rules.md` for deciding which visuals should be selected, kept as backup, or omitted
- `references/interpretation-rules.md` for handling confidence, uncertainty, and cautious wording

# Required behavior

- Inspect the available artifacts before drafting conclusions.
- Group related artifacts when they belong to the same experiment, condition, or result family.
- Prefer direct evidence from scripts, figures, tables, logs, and analyst-written notes.
- Separate confirmed observations from plausible interpretations.
- Optimize the output for downstream slide creation rather than technical exhaustiveness.
- Avoid redundant findings and redundant visuals.
- Do not create the final slide deck by default.

# Required workflow

## 1. Inventory the inputs
Create a compact inventory of important artifacts.

## 2. Group related artifacts
Group scripts and outputs that should be interpreted together.

## 3. Select reporting-worthy evidence
Use `references/figure-selection-rules.md`.

## 4. Extract findings and caveats
Use `references/interpretation-rules.md`.

## 5. Produce the structured handoff
Follow `references/output-schema.md` exactly.

# Output requirement

The final answer must be written in Japanese and must end with a `SLIDE_INPUT` section that follows the required schema exactly.

# What not to do

- Do not overclaim causality.
- Do not convert exploratory outputs into definitive proof.
- Do not include every file if it does not help reporting.
- Do not skip uncertainty when it matters.