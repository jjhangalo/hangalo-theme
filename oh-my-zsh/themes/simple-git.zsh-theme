# simple-git theme for Oh My Zsh

_simple_git_info() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    local branch upstream ahead=0 behind=0
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)

    if [[ -n "$upstream" ]]; then
        read -r behind ahead <<< "$(git rev-list --left-right --count "${upstream}...HEAD" 2>/dev/null)"
        ahead=${ahead:-0}
        behind=${behind:-0}
    fi

    local staged=0 modified=0 untracked=0 line idx wt
    while IFS= read -r line; do
        (( ${#line} < 2 )) && continue
        idx="${line[1]}"
        wt="${line[2]}"
        [[ "$idx" != " " && "$idx" != "?" ]] && ((staged++))
        [[ "$wt" == "M" || "$wt" == "D" ]] && ((modified++))
        [[ "$idx" == "?" && "$wt" == "?" ]] && ((untracked++))
    done < <(git status --porcelain 2>/dev/null)

    local out="%F{magenta}[%F{cyan}${branch}"
    (( ahead > 0 ))     && out+=" %F{green}↑${ahead}"
    (( behind > 0 ))    && out+=" %F{red}↓${behind}"
    (( staged > 0 ))    && out+=" %F{green}•${staged}"
    (( modified > 0 ))  && out+=" %F{yellow}~${modified}"
    (( untracked > 0 )) && out+=" %F{blue}?${untracked}"
    out+="%F{magenta}]%f"

    print -n "$out"
}

PROMPT='%(?..%F{red}(%?)%f )%B%F{green}%n@%m%f%b %F{cyan}%1~%f $(_simple_git_info)>'$'\n''$ '
