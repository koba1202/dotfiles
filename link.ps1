# dotfiles のシンボリックリンクをまとめて作成するスクリプト
# シンボリックリンク作成には管理者権限、または Windows の開発者モードが必要です。

$ErrorActionPreference = "Stop"

$DotfilesDir = "$HOME\dotfiles"

function New-DotfileSymlink {
    param(
        [string]$Path,
        [string]$Target
    )

    if (Test-Path $Path) {
        $item = Get-Item $Path -Force
        if ($item.LinkType -eq "SymbolicLink" -and $item.Target -eq $Target) {
            Write-Host "[skip] already linked: $Path"
            return
        }
        Write-Host "[remove] existing item: $Path"
        Remove-Item $Path -Force -Recurse
    }
    else {
        $parent = Split-Path $Path -Parent
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
    }

    New-Item -ItemType SymbolicLink -Path $Path -Target $Target | Out-Null
    Write-Host "[link] $Path -> $Target"
}

Write-Host "Creating symlinks..."

# wezterm, starship, lazygit, scoop, pycodestyle, configstore など
# XDG_CONFIG_HOME 経由のツールをまとめてカバー
New-DotfileSymlink -Path "$HOME\.config" -Target "$DotfilesDir\.config"

# Windows 版 Neovim は ~/.config を見ないため個別にリンクする
New-DotfileSymlink -Path "$env:LOCALAPPDATA\nvim" -Target "$DotfilesDir\.config\nvim"

Write-Host "Done!"
