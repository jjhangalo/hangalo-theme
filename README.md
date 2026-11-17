# shell-themes

A consistent, lightweight shell prompt (`simple-git`) across **PowerShell 7**, **Bash**, **Zsh**, and **Oh My Zsh**.

## Prompt Layout

```text
(1) user@host folder [main ↑1 ↓2 •3 ~4 ?5]>
$
```

- `(1)` — Last command exit code (shown in red only when non-zero)
- `user@host` — Bold green username and hostname
- `folder` — Current directory name in cyan
- `[branch ...]` — Git status in magenta/cyan (shown only inside a Git repository):
  - `↑N` (green) — Commits ahead of upstream
  - `↓N` (red) — Commits behind upstream
  - `•N` (green) — Staged files
  - `~N` (yellow) — Modified/deleted unstaged files
  - `?N` (blue) — Untracked files

## Repository Structure

```text
.
├── bash/simple-git.bash
├── oh-my-zsh/themes/simple-git.zsh-theme
├── powershell/Microsoft.PowerShell_profile.ps1
├── zsh/simple-git.zsh
└── install.sh
```

## Quick Install

Run `./install.sh` with your target shell:

```bash
./install.sh bash        # Installs to ~/.config/shell-themes/ and sources in ~/.bashrc
./install.sh zsh         # Installs to ~/.config/shell-themes/ and sources in ~/.zshrc
./install.sh oh-my-zsh   # Installs to $ZSH_CUSTOM/themes/ and sets ZSH_THEME="simple-git"
./install.sh powershell  # Installs to ~/.config/powershell/Microsoft.PowerShell_profile.ps1
```

Reload your shell afterwards (for example `source ~/.bashrc` or `source ~/.zshrc`).

## Manual Setup

### Bash

Copy `bash/simple-git.bash` somewhere permanent (e.g. `~/.config/shell-themes/simple-git.bash`) and add to `~/.bashrc`:

```bash
source "$HOME/.config/shell-themes/simple-git.bash"
```

### Zsh (standalone)

Copy `zsh/simple-git.zsh` to `~/.config/shell-themes/simple-git.zsh` and add to `~/.zshrc`:

```zsh
source "$HOME/.config/shell-themes/simple-git.zsh"
```

### Oh My Zsh

Copy `oh-my-zsh/themes/simple-git.zsh-theme` to your Oh My Zsh custom themes directory:

```bash
cp oh-my-zsh/themes/simple-git.zsh-theme "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/"
```

Then set the theme in `~/.zshrc`:

```zsh
ZSH_THEME="simple-git"
```

### PowerShell 7

**Linux / macOS:**

```powershell
New-Item -ItemType Directory -Force (Split-Path $PROFILE) | Out-Null
Copy-Item ./powershell/Microsoft.PowerShell_profile.ps1 $PROFILE
```

**Windows:**

```powershell
New-Item -ItemType Directory -Force (Split-Path $PROFILE) | Out-Null
Copy-Item .\powershell\Microsoft.PowerShell_profile.ps1 $PROFILE
```

Reload with `. $PROFILE`.
