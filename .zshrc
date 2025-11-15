# ========================================
# 📜 History tuning (more useful history)
# ========================================
HISTSIZE=50000          # how many commands kept in memory
SAVEHIST=50000          # how many saved to ~/.zsh_history
setopt HIST_IGNORE_DUPS         # ignore direct duplicates
setopt HIST_IGNORE_ALL_DUPS     # remove older duplicates
setopt HIST_REDUCE_BLANKS       # trim superfluous spaces
setopt INC_APPEND_HISTORY       # write history incrementally
setopt SHARE_HISTORY            # share history across terminals


# ========================================
# 🧩 Custom user scripts
# ----------------------------------------
# Add personal bin directory to PATH
# ========================================
export PATH="$HOME/bin:$PATH"


# ========================================
# 🧰 SDKMAN
# ----------------------------------------
# Loads SDKMAN (Java, Kotlin, Gradle, etc.)
# NOTE: Must remain near end of file.
# ========================================
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# ========================================
# 🔠 Case-insensitive autocompletion
# ========================================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'


# ========================================
# 🧱 Artifact Store (JFrog)
# ========================================
export ARTIFACT_STORE_HOST="jfrog.g-labs.io"
export ARTIFACT_STORE_USER="sgebb"
export ARTIFACT_STORE_SECRET="$(security find-generic-password -a sgebb -s artifactStoreSecret -w)"


# ========================================
# 🚀 zoxide (smarter cd)
# ========================================
eval "$(zoxide init zsh)"


# ========================================
# 📂 zoxide + fzf directory jumper (Ctrl+O)
# ----------------------------------------
# Uses your zoxide database as a source of "frecency" dirs
# and lets you fuzzy-pick one with fzf.
# Preview uses eza (or ls as fallback) to show directory contents.
# ========================================
if command -v zoxide >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
  fzf-zoxide-widget() {
    local dir preview_cmd

    if command -v eza >/dev/null 2>&1; then
      preview_cmd='eza --icons --group-directories-first --color=always {} 2>/dev/null | head -100'
    else
      preview_cmd='ls -la {} 2>/dev/null | head -100'
    fi

    dir=$(
      zoxide query -l \
        | fzf --height=40% \
              --reverse \
              --prompt="zoxide> " \
              --preview "$preview_cmd" \
              --preview-window=right:60%
    ) || return

    [[ -z "$dir" ]] && return

    builtin cd -- "$dir"
    zle reset-prompt
  }

  zle -N fzf-zoxide-widget
  # Ctrl+O to open zoxide fzf jumper
  bindkey '^O' fzf-zoxide-widget
fi


# ========================================
# 🐳 Rancher Desktop — managed
# ========================================
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/sageniuz/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
###


# ========================================
# 📁 eza (modern ls)
# ----------------------------------------
# Fully replace ls with modern features:
# icons, git integration, better formatting
# Guarded so shell still works if eza is missing.
# ========================================
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons --group-directories-first --git"
  alias ll="eza -l --icons --git --group-directories-first --header"
  alias la="eza -la --icons --group-directories-first --header"
  alias lt="eza --tree --icons --git-ignore --level=2"
  alias ltt="eza --tree --icons --git-ignore --level=3"
  alias lld="eza -l --icons --only-dirs"
else
  # sensible defaults if eza is not installed
  alias ls="ls -G"
  alias ll="ls -l"
  alias la="ls -la"
fi


# ========================================
# 🧲 Git Aliases (fast & minimal)
# ========================================
alias g="git"
alias ga="git add"
alias gaa="git add -A"
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch -d"
alias gbD="git branch -D"

alias gc="git commit -v"
alias gcm="git commit -m"
alias gca="git commit -a -v"
alias gcam="git commit -a -m"

alias gco="git checkout"
alias gcb="git checkout -b"

alias gd="git diff"
alias gds="git diff --staged"

alias gl="git log --oneline --decorate --graph --all"
alias glp="git log --pretty=format:'%C(yellow)%h%Creset %Cgreen%cd%Creset %Cblue%an%Creset %C(auto)%d%Creset %s' --date=relative"

alias gs="git status -sb"
alias gss="git status"

alias gp="git push"
alias gpf="git push --force-with-lease"
alias gpl="git pull --rebase"
alias gpr="git pull --rebase --autostash"

alias gcl="git clone"
alias gclean="git clean -xdf"

alias gr="git restore"
alias grs="git restore --staged"

alias gm="git merge"
alias gmt="git mergetool"
alias gundo="git reset --hard HEAD~1"
alias gc!="git commit -v --no-edit"

# fzf checkout branch
gcof() {
  local branch
  branch=$(git branch --all --color=always | sed 's/^[* ]*//' \
    | fzf --height=40% --ansi --preview-window=right:60% \
          --preview 'git log --oneline --decorate --graph -n 20 --color=always {}' \
          --prompt="checkout> ") || return
  git checkout "$(echo "$branch" | tr -d '[:space:]')"
}
alias gco="gcof"

glo() {
  git log --graph --oneline --decorate --color=always --all \
    | fzf --ansi --height=70% --reverse \
        --preview 'git show --color=always {1}' \
        --bind "enter:execute:
            (echo {} | awk '{print \$1}' | xargs git show --color=always | less -R)"
}

gstash() {
  git stash list --color=always \
    | fzf --ansi --preview 'git stash show -p --color=always {1}' \
          --prompt="stash> " \
    | awk -F: '{print $1}'
}
alias gst="gstash"

gcdiff() {
  local file
  file=$(git diff --name-only | fzf --height=40% --reverse --prompt="diff> " \
          --preview "git diff --color=always -- {}") || return
  git diff "$file"
}

gadd() {
  local file
  file=$(git ls-files --modified --others --exclude-standard \
    | fzf --height=40% --reverse --prompt="add> " \
          --preview 'git diff --color=always -- {}') || return
  git add "$file"
}
alias ga="gadd"

grebase() {
  local commit
  commit=$(git log --oneline --reverse --color=always \
    | fzf --ansi --tac --prompt="rebase onto> " \
          --preview 'git show --color=always {1}') || return
  git rebase -i "$(echo "$commit" | awk '{print $1}')"
}

gmerge() {
  local file
  file=$(git diff --name-only --diff-filter=U \
    | fzf --height=40% --reverse --prompt="merge-conflict> " \
          --preview 'git diff --color=always -- {}') || return
  echo "Opening conflicted file: $file"
  ${EDITOR:-vim} "$file"
}

gdel() {
  local branch
  branch=$(git branch | sed 's/*//' | sed 's/ //g' \
    | fzf --height=40% --reverse --prompt="delete-branch> ") || return
  git branch -D "$branch"
}

grename() {
  local branch new
  branch=$(git branch --show-current)
  read -r "new?New name for branch '$branch': "
  git branch -m "$new"
}

gopen() {
  local file
  file=$(git ls-files \
    | fzf --height=40% --reverse --prompt="open> " \
          --preview 'sed -n "1,200p" {} 2>/dev/null') || return
  ${EDITOR:-vim} "$file"
}


# ========================================
# 🧭 gmenu – fzf-based Git command center
# ========================================
gmenu() {
  # Abort if not in a git repo
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Not inside a git repository."
    return 1
  }

  local choice
  choice=$(
    printf '%s\n' \
      "status (git status -sb)" \
      "diff (working tree)" \
      "diff staged" \
      "log (graph)" \
      "checkout branch (fzf)" \
      "open tracked file (fzf)" \
      "add file (fzf)" \
      "commit (message)" \
      "push" \
      "pull --rebase" \
      "stash browser" \
      "conflicts (open file)" \
      "rebase onto commit (fzf)" \
      "delete local branch (fzf)" \
      "rename current branch" \
      "quit" \
    | fzf --height=70% --reverse --prompt="git> "
  ) || return

  case "$choice" in
    "status (git status -sb)")
      git status -sb
      ;;
    "diff (working tree)")
      git diff
      ;;
    "diff staged")
      git diff --staged
      ;;
    "log (graph)")
      # falls du glo definiert hast, nimm das – sonst plain log
      if typeset -f glo >/dev/null 2>&1; then
        glo
      else
        git log --oneline --decorate --graph --all
      fi
      ;;
    "checkout branch (fzf)")
      if typeset -f gcof >/dev/null 2>&1; then
        gcof
      else
        echo "gcof not defined – falling back to plain 'git checkout':"
        read "br?Branch name: "
        [[ -n "$br" ]] && git checkout "$br"
      fi
      ;;
    "open tracked file (fzf)")
      if typeset -f gopen >/dev/null 2>&1; then
        gopen
      else
        local file
        file=$(git ls-files | fzf --prompt="open> ") || return
        ${EDITOR:-vim} "$file"
      fi
      ;;
    "add file (fzf)")
      if typeset -f gadd >/dev/null 2>&1; then
        gadd
      else
        local file
        file=$(git ls-files --modified --others --exclude-standard \
               | fzf --prompt="add> " \
                     --preview 'git diff --color=always -- {}') || return
        git add "$file"
      fi
      ;;
    "commit (message)")
      local msg
      read "msg?Commit message: "
      [[ -n "$msg" ]] && git commit -am "$msg"
      ;;
    "push")
      git push
      ;;
    "pull --rebase")
      git pull --rebase
      ;;
    "stash browser")
      if typeset -f gstash >/dev/null 2>&1; then
        gstash
      else
        git stash list
      fi
      ;;
    "conflicts (open file)")
      if typeset -f gmerge >/dev/null 2>&1; then
        gmerge
      else
        local file
        file=$(git diff --name-only --diff-filter=U \
               | fzf --prompt="conflict> " \
                     --preview 'git diff --color=always -- {}') || return
        ${EDITOR:-vim} "$file"
      fi
      ;;
    "rebase onto commit (fzf)")
      if typeset -f grebase >/dev/null 2>&1; then
        grebase
      else
        local commit
        commit=$(
          git log --oneline --reverse --color=always \
          | fzf --ansi --tac --prompt="rebase onto> " \
                --preview 'git show --color=always {1}'
        ) || return
        git rebase -i "$(echo "$commit" | awk '{print $1}')"
      fi
      ;;
    "delete local branch (fzf)")
      if typeset -f gdel >/dev/null 2>&1; then
        gdel
      else
        local br
        br=$(git branch | sed 's/*//' | sed 's/ //g' \
             | fzf --prompt="delete-branch> ") || return
        git branch -D "$br"
      fi
      ;;
    "rename current branch")
      if typeset -f grename >/dev/null 2>&1; then
        grename
      else
        local cur new
        cur=$(git branch --show-current)
        read "new?New name for branch '$cur': "
        [[ -n "$new" ]] && git branch -m "$new"
      fi
      ;;
    "quit"|*)
      return 0
      ;;
  esac
}


# ========================================
# 📚 E-Book filename search helper
# Usage: booksearch <pattern...>
# Example: booksearch "harry potter"
# ========================================
booksearch() {
  local ROOT="/Volumes/G-DRIVE SSD/E-Books"
  local pattern

  if [[ ! -d "$ROOT" ]]; then
    echo "E-Books folder not found: $ROOT" >&2
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    echo "Usage: booksearch <pattern or regex>" >&2
    return 1
  fi

  # Join all arguments into one search pattern
  pattern="$*"

  # List files (epub/pdf/zip), then filter by pattern (case-insensitive)
  rg --files -g '*.{epub,pdf,zip}' "$ROOT" \
    | rg -i "$pattern"
}


# ========================================
# 📚 Interactive E-Book search + open (fzf)
# Usage: bookpick <pattern...>
# ========================================
bookpick() {
  local ROOT="/Volumes/G-DRIVE SSD/E-Books"
  local pattern file

  if [[ ! -d "$ROOT" ]]; then
    echo "E-Books folder not found: $ROOT" >&2
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    echo "Usage: bookpick <pattern or regex>" >&2
    return 1
  fi

  pattern="$*"

  file=$(
    rg --files -g '*.{epub,pdf,zip}' "$ROOT" \
      | rg -i "$pattern" \
      | fzf --height=40% --reverse --prompt="E-Books> "
  ) || return

  [[ -z "$file" ]] && return

  echo "Opening: $file"
  open "$file"   # macOS: opens with default app
}


# ========================================
# ⌨️ Vim-style Insert-mode escape: jk / kj
# (only applies inside Vim, harmless in zsh)
# ========================================
inoremap() { :; } 2>/dev/null


# ========================================
# 🔎 fzf-powered history search (Ctrl+R)
# ----------------------------------------
# - Uses fzf's matching syntax (NOT full regex)
# - Deduplicates history lines (newest commands win)
# - Inserts selected command into prompt (not executed)
# ========================================
if command -v fzf >/dev/null 2>&1; then

  fzf-history-widget() {
    local selected
    selected=$(
      fc -l -n 1 \
        | sed 's/^ *[0-9]\+ *//' \
        | awk '
            {
              lines[NR] = $0
            }
            END {
              # iterate from newest to oldest, keep first occurrence
              for (i = NR; i >= 1; i--) {
                if (!seen[lines[i]]++) {
                  out[++k] = lines[i]
                }
              }
              # print back in original chronological order
              for (j = k; j >= 1; j--) {
                print out[j]
              }
            }
          ' \
        | fzf --tac --reverse --exact
    ) || return

    [[ -z "$selected" ]] && return
    print -s -- "$selected"

    BUFFER="$selected"
    CURSOR=${#BUFFER}
    zle reset-prompt
  }

  zle -N fzf-history-widget
  bindkey '^R' fzf-history-widget


  # ======================================
  # 🔍 Regex-based history search (Ctrl+G)
  # --------------------------------------
  # Usage:
  #   1. Type regex into the prompt (e.g. dep.*Update)
  #   2. Press Ctrl+G
  #   3. fzf shows only matches
  #   4. Selected command is inserted into prompt (not executed)
  # ======================================
  hregex-widget() {
    local pattern selected

    pattern="$LBUFFER"
    [[ -z "$pattern" ]] && return

    BUFFER=""
    zle reset-prompt

    selected=$(
      fc -l -n 1 \
        | sed 's/^ *[0-9]\+ *//' \
        | grep -E -- "$pattern" \
        | fzf --tac --reverse
    ) || return

    [[ -z "$selected" ]] && return
    print -s -- "$selected"

    BUFFER="$selected"
    CURSOR=${#BUFFER}
    zle reset-prompt
  }

  zle -N hregex-widget
  bindkey '^G' hregex-widget
fi


# ========================================
# 📄 fzf file finder (Ctrl+F)
# ----------------------------------------
# CTRL+F:
#   - Uses fd if available, otherwise find
#   - Lets you fuzzy-search files with fzf
#   - Opens selection in $EDITOR (default: vim)
# ========================================
if command -v fzf >/dev/null 2>&1; then
  fzf-file-widget() {
    local finder file editor

    if command -v fd >/dev/null 2>&1; then
      finder='fd --type f --hidden --follow --exclude .git'
    else
      # Fallback to find if fd is not installed
      finder='find . -type f'
    fi

    file=$(
      eval "$finder" \
        | fzf --height=40% \
              --reverse \
              --prompt="Files> " \
              --preview 'sed -n "1,120p" {} 2>/dev/null' \
              --preview-window=right:60%
    ) || return

    [[ -z "$file" ]] && return

    editor=${EDITOR:-vim}

    BUFFER="$editor ${(q)file}"
    CURSOR=${#BUFFER}
    zle accept-line
  }

  zle -N fzf-file-widget
  # Ctrl+F = file finder (you chose this instead of Ctrl+P)
  bindkey '^F' fzf-file-widget
fi


# ========================================
# 🖼 Prompt / environment tuning
# ----------------------------------------
# Minimal prompt:
#   ~/path/to/project branch ✚✓⚡⇣⇡ %
# ========================================
git_prompt_info() {
  local branch dirty staged untracked conflict ahead behind
  local symbols=""

  # If not in a git repo: nothing
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return

  # Status indicators (colored)
  [[ -n "$(git diff --name-only --diff-filter=U 2>/dev/null)" ]] \
      && symbols+="%F{red}✖%f"

  [[ -n "$(git status --porcelain --untracked-files=no 2>/dev/null)" ]] \
      && symbols+="%F{red}⚡%f"

  [[ -n "$(git diff --cached --name-only 2>/dev/null)" ]] \
      && symbols+="%F{green}✓%f"

  [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]] \
      && symbols+="%F{yellow}✚%f"

  # Ahead / behind
  if git rev-parse --abbrev-ref @{upstream} >/dev/null 2>&1; then
    local counts
    counts=($(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null))
    behind=${counts[1]}
    ahead=${counts[2]}

    [[ "$behind" -gt 0 ]] && symbols+="%F{magenta}⇣$behind%f"
    [[ "$ahead"  -gt 0 ]] && symbols+="%F{blue}⇡$ahead%f"
  fi

  # If no symbols, only show branch
  if [[ -z "$symbols" ]]; then
    echo "$branch"
  else
    echo "$branch $symbols"
  fi
}

setopt PROMPT_SUBST

# Path (~/...), then branch + git symbols, then prompt char
PROMPT='%F{yellow}%~%f %F{blue}$(git_prompt_info)%f %# '
PS1=$PROMPT
