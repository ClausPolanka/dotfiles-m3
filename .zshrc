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
# Preview uses eza to show directory contents.
# ========================================
if command -v zoxide >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
  fzf-zoxide-widget() {
    local dir
    dir=$(
      zoxide query -l \
        | fzf --height=40% \
              --reverse \
              --prompt="zoxide> " \
              --preview 'eza --icons --group-directories-first --color=always {} 2>/dev/null | head -100' \
              --preview-window=right:60%
    ) || return

    [[ -z "$dir" ]] && return

    # Jump directly to the selected directory
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
# ========================================
alias ls="eza --icons --group-directories-first --git"
alias ll="eza -l --icons --git --group-directories-first --header"
alias la="eza -la --icons --group-directories-first --header"
alias lt="eza --tree --icons --git-ignore --level=2"
alias ltt="eza --tree --icons --git-ignore --level=3"
alias lld="eza -l --icons --only-dirs"


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
# 🖼 Prompt / environment tuning (optional)
# Add custom prompt or ZSH theme here
# ========================================
