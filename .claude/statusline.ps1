# Claude Code ステータスライン用 PowerShell スクリプト
# 標準入力から JSON を受け取り、2 行のステータスラインを出力する

# 出力エンコーディングを UTF-8 に設定（ブロック文字や日本語の表示用）
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 標準入力から JSON を読み込み
$inputText = [Console]::In.ReadToEnd()
$data = $inputText | ConvertFrom-Json

# 各種値を取得
$model     = $data.model.display_name
$dirFull   = $data.workspace.current_dir
$directory = Split-Path -Leaf $dirFull

# コスト（USD）
$cost = 0.0
if ($null -ne $data.cost -and $null -ne $data.cost.total_cost_usd) {
    $cost = [double]$data.cost.total_cost_usd
}

# コンテキスト使用率（％）
$pct = 0
if ($null -ne $data.context_window -and $null -ne $data.context_window.used_percentage) {
    $pct = [int]$data.context_window.used_percentage
}

# 処理時間（ミリ秒）
$durationMs = 0
if ($null -ne $data.cost -and $null -ne $data.cost.total_duration_ms) {
    $durationMs = [int]$data.cost.total_duration_ms
}

# ANSI カラーコード
$ESC    = [char]27
$CYAN   = "$ESC[36m"
$GREEN  = "$ESC[32m"
$YELLOW = "$ESC[33m"
$RED    = "$ESC[31m"
$RESET  = "$ESC[0m"

# 使用率に応じてバーの色を切り替え（90％以上=赤、70-89％=黄、それ以外=緑）
$barColor = if ($pct -ge 90) { $RED } elseif ($pct -ge 70) { $YELLOW } else { $GREEN }

# プログレスバー（U+2588=塗りつぶし、U+2591=空）
# Python の // と同じ切り捨て挙動にするため Floor を使用（[int] は銀行家丸め）
$filled = [int][Math]::Floor($pct / 10)
$bar    = ([string][char]0x2588) * $filled + ([string][char]0x2591) * (10 - $filled)

# 経過時間（分・秒）
$mins = [int]($durationMs / 60000)
$secs = [int](($durationMs % 60000) / 1000)

# トークン数を K / M 単位に整形するヘルパー
function Format-Tok {
    param([long]$n)
    if ($n -ge 1000000) { return "{0:F1}M" -f ($n / 1000000.0) }
    if ($n -ge 1000)    { return "{0:F1}K" -f ($n / 1000.0) }
    return [string]$n
}

# トランスクリプト JSONL からアシスタントメッセージのトークン使用量を集計
# ステータスライン JSON 自体にはトークン情報が無いため、transcript_path を辿って取得する
$tokInfo = ""
$transcriptPath = $data.transcript_path
if ($transcriptPath -and (Test-Path $transcriptPath)) {
    try {
        [long]$totalInput       = 0
        [long]$totalCacheCreate = 0
        [long]$totalCacheRead   = 0
        [long]$totalOutput      = 0

        $lines = [System.IO.File]::ReadAllLines($transcriptPath, [System.Text.Encoding]::UTF8)
        foreach ($line in $lines) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            try {
                $entry = $line | ConvertFrom-Json
                $u = $entry.message.usage
                if ($null -ne $u) {
                    if ($null -ne $u.input_tokens)                { $totalInput       += [long]$u.input_tokens }
                    if ($null -ne $u.cache_creation_input_tokens) { $totalCacheCreate += [long]$u.cache_creation_input_tokens }
                    if ($null -ne $u.cache_read_input_tokens)     { $totalCacheRead   += [long]$u.cache_read_input_tokens }
                    if ($null -ne $u.output_tokens)               { $totalOutput      += [long]$u.output_tokens }
                }
            } catch {
                # 壊れた行や非アシスタントメッセージは無視
            }
        }

        $totalIn = $totalInput + $totalCacheCreate + $totalCacheRead
        $cacheRatio = if ($totalIn -gt 0) { [int](($totalCacheRead / $totalIn) * 100) } else { 0 }
        $tokInfo = " | tok:I=$(Format-Tok $totalIn) O=$(Format-Tok $totalOutput) cache=${cacheRatio}%"
    } catch {
        # transcript 読み込み失敗時は表示しない
    }
}

# レート制限情報（5時間 = Current session、7日 = week）
# data.rate_limits は最初の API レスポンス後、Pro/Max ユーザーで利用可能
$rateLimitInfo = ""
if ($null -ne $data.rate_limits) {
    $segments = @()

    # 共通: パーセンテージからバー文字列と色を生成するヘルパー
    function Build-RateBar {
        param([int]$pct, [string]$label, [string]$resetStr = "")
        $filled = [int][Math]::Floor($pct / 10)
        $bar    = ([string][char]0x2588) * $filled + ([string][char]0x2591) * (10 - $filled)
        $color  = if ($pct -ge 90) { "$([char]27)[31m" } elseif ($pct -ge 70) { "$([char]27)[33m" } else { "$([char]27)[32m" }
        $reset  = "$([char]27)[0m"
        return "${label}:${color}${bar}${reset} ${pct}%${resetStr}"
    }

    # 5 時間（Current session 相当）
    $fiveHour = $data.rate_limits.five_hour
    if ($null -ne $fiveHour -and $null -ne $fiveHour.used_percentage) {
        $sPct = [int]$fiveHour.used_percentage

        # リセット時刻（フィールド名のバリエーションに対応）
        $resetStr = ""
        $resetsAt = $fiveHour.resets_at
        if (-not $resetsAt) { $resetsAt = $fiveHour.reset_at }
        if (-not $resetsAt) { $resetsAt = $fiveHour.reset_time }
        if ($resetsAt) {
            try {
                $dt = [DateTime]::Parse($resetsAt).ToLocalTime()
                $resetStr = " (resets $($dt.ToString('HH:mm')))"
            } catch {
                # パース失敗時はリセット時刻を出さない
            }
        }
        $segments += (Build-RateBar -pct $sPct -label "session" -resetStr $resetStr)
    }

    # 7 日（week）
    $sevenDay = $data.rate_limits.seven_day
    if ($null -ne $sevenDay -and $null -ne $sevenDay.used_percentage) {
        $wPct = [int]$sevenDay.used_percentage
        $segments += (Build-RateBar -pct $wPct -label "week")
    }

    if ($segments.Count -gt 0) {
        $rateLimitInfo = $segments -join " | "
    }
}

# Git ブランチ取得（カレントディレクトリを変えずに実行）
$branchInfo = ""
try {
    if ($dirFull -and (Test-Path $dirFull)) {
        $branch = & git -C $dirFull branch --show-current 2>$null
        if ($LASTEXITCODE -eq 0 -and $branch) {
            $branchInfo = " | branch:$($branch.Trim())"
        }
    }
} catch {
    # git 未インストールや非リポジトリは無視
}

# 1 行目: [モデル名] dir:ディレクトリ | branch:ブランチ名
Write-Output ("{0}[{1}]{2} dir:{3}{4}" -f $CYAN, $model, $RESET, $directory, $branchInfo)

# 2 行目: バー XX% | $コスト | time:Xm Ys | tok:I=... O=... cache=...%
$costStr = "{0:F2}" -f $cost
Write-Output ("context:{0}{1}{2} {3}% | {4}`${5}{6} | time:{7}m {8}s{9}" -f $barColor, $bar, $RESET, $pct, $YELLOW, $costStr, $RESET, $mins, $secs, $tokInfo)

# 3 行目: rate_limits 情報（取得できた場合のみ）
if ($rateLimitInfo) {
    Write-Output $rateLimitInfo
}
