#!/usr/bin/env node
/**
 * Claude Code statusLine ラッパー
 *   ccusage statusline の出力 + 5時間 / 7日 レート制限バー
 *
 * settings.json:
 *   "statusLine": {
 *     "type": "command",
 *     "command": "node \"C:/Users/xxxx/.claude/hooks/statusline.js\"",
 *     "padding": 0,
 *     "refreshInterval": 60
 *   }
 */

"use strict";
const { spawn } = require("node:child_process");

// ── 設定 ────────────────────────────────────────────────
// npx は毎回起動コストが乗るので `npm i -g ccusage` 推奨。
// その場合は CCUSAGE_CMD / CCUSAGE_ARGS を下記に差し替える。
const USE_GLOBAL = false;
const CCUSAGE_CMD = USE_GLOBAL
  ? process.platform === "win32" ? "ccusage.cmd" : "ccusage"
  : process.platform === "win32" ? "npx.cmd" : "npx";
const CCUSAGE_ARGS = USE_GLOBAL
  ? ["statusline"]
  : ["-y", "ccusage@latest", "statusline"];

const BAR_WIDTH = 10;
const THRESH = { warn: 50, danger: 80 };

// ── ユーティリティ ──────────────────────────────────────
const paint = (code, s) => `\x1b[${code}m${s}\x1b[0m`;
const colorOf = (p) => (p >= THRESH.danger ? 31 : p >= THRESH.warn ? 33 : 32);

function bar(p) {
  const filled = Math.max(0, Math.min(BAR_WIDTH, Math.round((p / 100) * BAR_WIDTH)));
  return "\u2588".repeat(filled) + "\u2591".repeat(BAR_WIDTH - filled);
}

/** resets_at は unix秒 / ISO文字列 のどちらも来うる */
function untilText(resetsAt) {
  if (resetsAt == null) return "";
  const ms =
    (typeof resetsAt === "number" ? resetsAt * 1000 : Date.parse(resetsAt)) - Date.now();
  if (!Number.isFinite(ms) || ms <= 0) return "";
  const min = Math.floor(ms / 60000);
  if (min < 60) return `${min}m`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr}h${String(min % 60).padStart(2, "0")}m`;
  return `${Math.floor(hr / 24)}d${hr % 24}h`;
}

function window(label, w) {
  if (!w || w.used_percentage == null) return null;
  const p = Math.round(w.used_percentage);
  const left = untilText(w.resets_at);
  return paint(colorOf(p), `${label} ${bar(p)} ${p}%`) + (left ? ` ${left}` : "");
}

function formatLimits(rateLimits) {
  if (!rateLimits) return "";
  return [
    window("5h", rateLimits.five_hour),
    window("7d", rateLimits.seven_day),
  ]
    .filter(Boolean)
    .join(" ");
}

/** stdin は一度しか読めないので、受け取った生JSONをそのまま ccusage に流す */
function runCcusage(rawInput) {
  return new Promise((resolve) => {
    let child;
    try {
      child = spawn(CCUSAGE_CMD, CCUSAGE_ARGS, {
        stdio: ["pipe", "pipe", "ignore"],
        windowsHide: true,
        // Node 18.20.2+ / 20.12.2+ / 22 では .cmd / .bat の spawn に shell が必須
        // (無いと spawn EINVAL で落ちる)
        shell: process.platform === "win32",
      });
    } catch {
      return resolve("");
    }
    let out = "";
    const done = (v) => resolve(v);
    const timer = setTimeout(() => {
      child.kill();
      done(out.trim().split("\n")[0] || "");
    }, 5000);

    child.stdout.setEncoding("utf8");
    child.stdout.on("data", (c) => (out += c));
    child.on("error", () => (clearTimeout(timer), done("")));
    child.on("close", () => (clearTimeout(timer), done(out.trim().split("\n")[0] || "")));
    child.stdin.on("error", () => {});
    child.stdin.end(rawInput);
  });
}

// ── main ────────────────────────────────────────────────
let raw = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (raw += chunk));
process.stdin.on("end", async () => {
  let data = {};
  try {
    data = JSON.parse(raw);
  } catch {
    /* 壊れた入力でも ccusage 側は動かす */
  }

  const [usage, limits] = [await runCcusage(raw), formatLimits(data.rate_limits)];
  const line = [usage, limits].filter(Boolean).join(" \n ");
  process.stdout.write(line + "\n");
});
