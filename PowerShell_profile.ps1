Invoke-Expression (&starship init powershell)

Import-Module PSFzf

# fzf の見た目の共通設定(枠の余白)。--height 等は Invoke-Fzf の引数側で指定する
$env:FZF_DEFAULT_OPTS = '--margin=1,2'

function Set-Location {
    param([string]$Path)

    Microsoft.PowerShell.Management\Set-Location $Path

    # $venv = Join-Path (Get-Location) "venv\Scripts\Activate.ps1"
    #
    # if (Test-Path $venv) {
    #     & $venv
    # }

    $activate = Get-ChildItem -Path $cwd -Directory -Filter 'venv*' |
        Sort-Object Name |
        ForEach-Object {
            $candidate = Join-Path $_.FullName 'Scripts\Activate.ps1'
            if (Test-Path $candidate) { $candidate }
        } |
        Select-Object -First 1

    if ($activate) {
        & $activate
    }
}

function memo {
    $desktop = [Environment]::GetFolderPath("Desktop")
    Set-Location (Join-Path $desktop "memo")
}

function dot {
    Set-Location "$HOME\dotfiles"
}

function dev {
    Set-Location "$HOME\development"
}
function obmemo {
    Set-Location "$HOME\memo"
}

# Set-PSReadLineKeyHandler `
#     -Chord 'Alt+t' `
#     -BriefDescription 'FindFileWithFzf' `
#     -ScriptBlock {
#         $insideGitRepo =
#             (git rev-parse --is-inside-work-tree 2>$null) -eq 'true'
#
#         if (-not $insideGitRepo) {
#             return
#         }
#
#         $selected = git ls-files --cached --others --exclude-standard |
#             & fzf.exe `
#                 --height=50% `
#                 --layout=reverse `
#                 --border=rounded `
#                 --margin=1,2 `
#                 --prompt='Files > ' `
#                 --preview='bat --color=always --style=numbers --line-range=:500 {}' `
#                 --preview-window='down,55%,border-top'
#
#         if ($selected) {
#             $quotedPath = "'" + $selected.Replace("'", "''") + "'"
#             [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quotedPath)
#         }
#     }

Set-PSReadLineKeyHandler -Chord 'Alt+t' -BriefDescription 'FindFileWithFzf' -ScriptBlock {
    if ((git rev-parse --is-inside-work-tree 2>$null) -ne 'true') { return }

    $out    = [System.IO.Path]::GetTempFileName()
    $oldCmd = $env:FZF_DEFAULT_COMMAND
    $env:FZF_DEFAULT_COMMAND = 'git ls-files --cached --others --exclude-standard'

    try {
        $fzfArgs = @(
            '--height=50%'
            '--layout=reverse'
            '--border=rounded'
            '--margin=1,2'
            '--prompt="Files > "'
            '--preview="bat --color=always --style=numbers --line-range=:500 {}"'
            '--preview-window=down,55%,border-top'
        )
        Start-Process -FilePath 'fzf.exe' -ArgumentList $fzfArgs `
                      -NoNewWindow -Wait -RedirectStandardOutput $out
        $selected = (Get-Content -LiteralPath $out -Raw).Trim()
    }
    finally {
        $env:FZF_DEFAULT_COMMAND = $oldCmd
        Remove-Item $out -ErrorAction Ignore
    }

    if ($selected) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("'" + $selected.Replace("'","''") + "'")
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
