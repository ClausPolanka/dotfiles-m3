###
# ========================================
# 🧩 Custom user scripts
# ----------------------------------------
# Add personal bin directory to PATH
# ========================================
export PATH="$HOME/bin:$PATH"


# ========================================
# 🧰 SDKMAN
# ----------------------------------------
# Loads SDKMAN, which manages Java, Kotlin,
# Gradle, and other SDK versions.
# NOTE: This must remain at the end of the file for SDKMAN to work!
# ========================================
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# ========================================
# 🔠 Case-insensitive autocompletion
# ----------------------------------------
# Makes tab completion ignore case (e.g., "cd Do" completes "Documents")
# ========================================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'


# ========================================
# 🧱 Artifact Store (JFrog)
# ----------------------------------------
# Environment variables for accessing the internal
# JFrog artifact repository.
# The secret is securely fetched from the macOS keychain.
# ========================================
export ARTIFACT_STORE_HOST="jfrog.g-labs.io"
export ARTIFACT_STORE_USER="sgebb"
export ARTIFACT_STORE_SECRET="$(security find-generic-password -a sgebb -s artifactStoreSecret -w)"


# ========================================
# 🚀 zoxide (smarter cd)
# ----------------------------------------
# Initializes zoxide for zsh and defines the `z` command
# ========================================
eval "$(zoxide init zsh)"


# ========================================
# 🐳 Rancher Desktop
# ----------------------------------------
# Automatically managed by Rancher Desktop.
# Do not edit this section manually.
# ========================================
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/sageniuz/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
###


# ========================================
# 🔎 fzf-powered history search (Ctrl+R)
# ----------------------------------------
# Uses fzf's own pattern syntax (NOT full regex):
#   ^git          → lines starting with "git"
#   curl account  → lines containing both "curl" and "account"
#   'ssh          → exact match (disables tokenization)
#
# Selected command is inserted into the prompt (NOT executed automatically).
# ========================================
if command -v fzf >/dev/null 2>&1; then
  fzf-history-widget() {
    # Load full history, remove line numbers, pipe into fzf
    local selected
    selected=$(
      fc -l -n 1 \
        | sed 's/^ *[0-9]\+ *//' \
        | fzf --tac --reverse --exact
    ) || return

    [[ -z "$selected" ]] && return

    # Add selected command back to history
    print -s -- "$selected"

    # Insert command into the prompt (do not execute)
    BUFFER="$selected"
    CURSOR=${#BUFFER}        # move cursor to end
    zle reset-prompt         # refresh prompt
  }

  # Register ZLE widget and bind Ctrl+R
  zle -N fzf-history-widget
  bindkey '^R' fzf-history-widget


  # ======================================
  # 🔍 Regex-based history search (Ctrl+G)
  # --------------------------------------
  # Uses real regex via grep -E on top of zsh history.
  #
  # Usage:
  #   1. Type your regex at the prompt, e.g.:
  #        dep.*Updates
  #        ^./gradlew .*dependencyUpdates
  #        (curl|http) .*accounts
  #   2. Press Ctrl+G
  #   3. Matching history entries are shown in fzf
  #   4. Selected command is inserted into the prompt (not executed)
  # ======================================
  hregex-widget() {
    local pattern selected

    # Take the current left buffer as regex pattern
    pattern="$LBUFFER"
    [[ -z "$pattern" ]] && return

    # Clear current line while searching
    BUFFER=""
    zle reset-prompt

    # Filter history via grep -E with the given regex and select via fzf
    selected=$(
      fc -l -n 1 \
        | sed 's/^ *[0-9]\+ *//' \
        | grep -E -- "$pattern" \
        | fzf --tac --reverse
    ) || return

    [[ -z "$selected" ]] && return

    # Add selected command back to history
    print -s -- "$selected"

    # Insert command into the prompt (do not execute)
    BUFFER="$selected"
    CURSOR=${#BUFFER}
    zle reset-prompt
  }

  # Register ZLE widget and bind Ctrl+G for regex history search
  zle -N hregex-widget
  bindkey '^G' hregex-widget
fi
