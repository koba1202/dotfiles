## Setup(Windows)

```powershell
cd ~
git clone https://github.com/koba1202/dotfiles.git
cd dotfiles
.\link.ps1
```

各種設定ファイルは `.config` 配下に格納しています。
`link.ps1` は以下のシンボリックリンクを作成します。

- `~/.config` -> `dotfiles/.config`(wezterm, starship, lazygit, scoop など)
- `%LOCALAPPDATA%\nvim` -> `dotfiles/.config/nvim`(Windows版Neovim用)

シンボリックリンクの作成には管理者権限、または Windows の開発者モードの有効化が必要です。

