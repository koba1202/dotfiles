Invoke-Expression (&starship init powershell)

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

Set-PSReadLineKeyHandler `
    -Chord 'Alt+t' `
    -BriefDescription 'FindFileWithFzf' `
    -ScriptBlock {
        $selected = git ls-files --cached --others --exclude-standard |
            fzf

        if ($selected) {
            $quotedPath = "'" + $selected.Replace("'", "''") + "'"
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quotedPath)
        }
    }
