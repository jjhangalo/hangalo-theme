# simple-git theme for Bash

_simple_git_info() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    local red='\[\e[31m\]'
    local green='\[\e[32m\]'
    local yellow='\[\e[33m\]'
    local blue='\[\e[34m\]'
    local magenta='\[\e[35m\]'
    local cyan='\[\e[36m\]'
    local reset='\[\e[m\]'

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
        [[ ${#line} -lt 2 ]] && continue
        idx="${line:0:1}"
        wt="${line:1:1}"
        [[ "$idx" != " " && "$idx" != "?" ]] && ((staged++))
        [[ "$wt" == "M" || "$wt" == "D" ]] && ((modified++))
        [[ "$idx" == "?" && "$wt" == "?" ]] && ((untracked++))
    done < <(git status --porcelain 2>/dev/null)

    local out="${magenta}[${cyan}${branch}"
    (( ahead > 0 ))     && out+=" ${green}↑${ahead}"
    (( behind > 0 ))    && out+=" ${red}↓${behind}"
    (( staged > 0 ))    && out+=" ${green}•${staged}"
    (( modified > 0 ))  && out+=" ${yellow}~${modified}"
    (( untracked > 0 )) && out+=" ${blue}?${untracked}"
    out+="${magenta}]${reset}"

    printf '%s' "$out"
}

_simple_git_prompt() {
    local lastcode=$?
    local red='\[\e[31m\]'
    local green='\[\e[32m\]'
    local cyan='\[\e[36m\]'
    local bold='\[\e[1m\]'
    local reset='\[\e[m\]'

    local gitinfo
    gitinfo=$(_simple_git_info)

    local prefix=""
    if (( lastcode != 0 )); then
        prefix="${red}(${lastcode})${reset} "
    fi

    PS1="${prefix}${bold}${green}\u@\h${reset} ${cyan}\W${reset} ${gitinfo}>\n\$ "
}

PROMPT_COMMAND="_simple_git_prompt"
