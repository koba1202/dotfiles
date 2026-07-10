
// ============================================================
// Rate Limit Settings (Max 5x plan)
// ⚠️ 以下の定数値・計算ロジックは暫定値です
// Anthropicは正確な制限値を公開していないため、
// 実際の使用状況に合わせて調整してください
// ============================================================
const PLAN = 'Max 5x';
const LIMIT_5H_TOKENS = 5_000_000;    // 5時間ローリングウィンドウ (暫定値)
const LIMIT_WEEKLY_TOKENS = 45_000_000; // 週間上限 (暫定値)
// ============================================================

// --- stdin 読み取り ---
// Claude Code が JSON をパイプで送信する
// Buffer で受け取り、最後に UTF-8 でデコードすることで
// Windows の CP932 エンコーディング問題を回避
const chunks = [];
process.stdin.on('data', c => chunks.push(c));
process.stdin.on('end', () => {
  try {
    // Buffer.concat → toString('utf8') で確実に UTF-8 デコード
    const json = JSON.parse(Buffer.concat(chunks).toString('utf8'));

    // --- モデル名 ---
    const model = json.model?.display_name || 'N/A';

    // --- コンテキストウィンドウ使用率 ---
    const used = Math.round(json.context_window?.used_percentage || 0);
    const totalIn = json.context_window?.total_input_tokens || 0;
    const totalOut = json.context_window?.total_output_tokens || 0;
    const tokens = totalIn + totalOut;

    // --- コスト（API提供値を使用） ---
    const cost = json.cost?.total_cost_usd
      ? json.cost.total_cost_usd.toFixed(4)
      : '0.0000';

    // --- コンテキストウィンドウのトークン数（k表記） ---
    const ctxSize = json.context_window?.context_window_size || 200000;
    const ctxUsed = Math.round(ctxSize * used / 100);
    const fmtK = n => n >= 1000 ? Math.round(n / 1000) + 'k' : String(n);

    // --- プログレスバー（20文字幅） ---
    const filled = Math.floor(used * 20 / 100);
    const bar = '[' + '='.repeat(filled) + ' '.repeat(20 - filled) + ']';

    // --- レートリミット推定（5時間ローリングウィンドウ） ---
    // 注意: セッション単位の累積値であり、5時間全体ではない
    const rate5h = (tokens / LIMIT_5H_TOKENS * 100).toFixed(1);

    // --- レートリミット推定（週間） ---
    const rateWeek = (tokens / LIMIT_WEEKLY_TOKENS * 100).toFixed(2);

    // --- ディレクトリ名（末尾のフォルダ名のみ） ---
    const cwd = json.workspace?.current_dir || json.cwd || 'N/A';
    const shortDir = cwd.split(/[/\\]/).pop();

    // --- セッション経過時間 ---
    let duration = 'N/A';
    const durationMs = json.cost?.total_duration_ms;
    if (durationMs) {
      const sec = Math.floor(durationMs / 1000);
      const h = Math.floor(sec / 3600);
      const m = Math.floor((sec % 3600) / 60);
      duration = `${h}h${m}m`;
    }

    // --- 出力 ---
    process.stdout.write(
      `${shortDir} | ${model} | ${bar} ${used}% ${fmtK(ctxUsed)}/${fmtK(ctxSize)} | $${cost} | ${duration} | ${tokens} tok | 5h: ${rate5h}% | Week: ${rateWeek}%`
    );
  } catch (e) {
    process.stdout.write('statusline error: ' + e.message);
  }
});
