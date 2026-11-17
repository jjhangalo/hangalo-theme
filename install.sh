#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<EOF
Usage: ./install.sh <shell>

Supported shells:
  bash        Install theme to ~/.config/shell-themes/ and source in ~/.bashrc
  zsh         Install theme to ~/.config/shell-themes/ and source in ~/.zshrc
  oh-my-zsh   Install theme to \$ZSH_CUSTOM/themes/ and set ZSH_THEME="simple-git"
  powershell  Install PowerShell 7 profile to ~/.config/powershell/
EOF
}

append_once() {
    local line="$1"
    local file="$2"
    touch "$file"
    if ! grep -Fqx "$line" "$file"; then
        printf '\n%s\n' "$line" >> "$file"
    fi
}

install_bash() {
    local dest_dir="$HOME/.config/shell-themes"
    local dest="$dest_dir/simple-git.bash"
    mkdir -p "$dest_dir"
    cp "$REPO_DIR/bash/simple-git.bash" "$dest"
    append_once 'source "$HOME/.config/shell-themes/simple-git.bash"' "$HOME/.bashrc"
    echo "Installed Bash theme to $dest and updated ~/.bashrc"
}

install_zsh() {
    local dest_dir="$HOME/.config/shell-themes"
    local dest="$dest_dir/simple-git.zsh"
    mkdir -p "$dest_dir"
    cp "$REPO_DIR/zsh/simple-git.zsh" "$dest"
    append_once 'source "$HOME/.config/shell-themes/simple-git.zsh"' "$HOME/.zshrc"
    echo "Installed Zsh theme to $dest and updated ~/.zshrc"
}

install_omz() {
    local omz_dir="${ZSH:-$HOME/.oh-my-zsh}"
    if [[ ! -d "$omz_dir" ]]; then
        echo "Error: Oh My Zsh not found at $omz_dir" >&2
        exit 1
    fi

    local custom_dir="${ZSH_CUSTOM:-$omz_dir/custom}/themes"
    local dest="$custom_dir/simple-git.zsh-theme"
    mkdir -p "$custom_dir"
    cp "$REPO_DIR/oh-my-zsh/themes/simple-git.zsh-theme" "$dest"

    local zshrc="$HOME/.zshrc"
    touch "$zshrc"
    if grep -Eq '^ZSH_THEME=' "$zshrc"; then
        local tmp
        tmp=$(mktemp)
        awk '/^ZSH_THEME=/ { print "ZSH_THEME=\"simple-git\""; next } { print }' "$zshrc" > "$tmp"
        mv "$tmp" "$zshrc"
    else
        printf '\nZSH_THEME="simple-git"\n' >> "$zshrc"
    fi

    echo "Installed Oh My Zsh theme to $dest and set ZSH_THEME=\"simple-git\" in ~/.zshrc"
}

install_powershell() {
    local dest_dir="$HOME/.config/powershell"
    local dest="$dest_dir/Microsoft.PowerShell_profile.ps1"
    mkdir -p "$dest_dir"
    if [[ -f "$dest" ]]; then
        cp "$dest" "$dest.bak"
        echo "Backed up existing profile to $dest.bak"
    fi
    cp "$REPO_DIR/powershell/Microsoft.PowerShell_profile.ps1" "$dest"
    echo "Installed PowerShell 7 profile to $dest"
}

case "${1:-}" in
    bash)       install_bash ;;
    zsh)        install_zsh ;;
    oh-my-zsh)  install_omz ;;
    powershell) install_powershell ;;
    -h|--help)  usage ;;
    *)
        usage >&2
        exit 1
        ;;
esac
