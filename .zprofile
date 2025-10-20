# ========================================
# 🧰 JetBrains Toolbox
# ----------------------------------------
# Adds JetBrains Toolbox scripts to the PATH
# (e.g., IntelliJ, Rider, etc.)
# ========================================
export PATH="$PATH:/Users/sageniuz/Library/Application Support/JetBrains/Toolbox/scripts"


# ========================================
# 🍺 Homebrew
# ----------------------------------------
# Loads Homebrew environment variables (e.g., PATH, MANPATH)
# ========================================
eval "$(/opt/homebrew/bin/brew shellenv)"


# ========================================
# 🐳 Rancher Desktop / Testcontainers
# ----------------------------------------
# Configures Docker and Testcontainers to work
# properly with Rancher Desktop on macOS
# ========================================

# Add Rancher Desktop binaries (e.g., rdctl, docker) to PATH
export PATH="$HOME/.rd/bin:$PATH"

# Docker host socket used by Rancher Desktop
export DOCKER_HOST="unix://$HOME/.rd/docker.sock"

# Testcontainers: override the default Docker socket path
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE="/var/run/docker.sock"

# Testcontainers: dynamically determine the IP address
# of Rancher Desktop's vznat interface
export TESTCONTAINERS_HOST_OVERRIDE="$(rdctl shell ip a show vznat | awk '/inet / {sub("/.*",""); print $2}')"
