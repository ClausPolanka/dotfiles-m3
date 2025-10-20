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
# 🐳 Rancher Desktop
# ----------------------------------------
# Automatically managed by Rancher Desktop.
# Do not edit this section manually.
# ========================================
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/sageniuz/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
