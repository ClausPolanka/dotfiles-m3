#!/usr/bin/env bash

# Make sure common binaries are available (important for non-interactive shells)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Fail fast:
# -e  exit on error
# -u  error on undefined variables
# -o pipefail  fail a pipeline if any command fails
set -euo pipefail

# --------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------

SERVICE="GAPI"
COUNTRY="HR"      # Uppercase country code

# Environments shown in the monitoring UI
ENVS=("FAT" "PPR" "UAT")

# Matching host prefixes for each environment (from your screenshot)
HOSTS=("apifat" "apippr" "apiuat")

# Domain and version endpoint path
DOMAIN="erstebank.hr"
MONITOR_PATH="/george/monitoring/geapi/version"

# Arrays to store results
declare -a VERSIONS
declare -a DATES

# --------------------------------------------------------------------
# Fetch version information per environment
# --------------------------------------------------------------------

for i in "${!ENVS[@]}"; do
  ENV="${ENVS[$i]}"
  HOST="${HOSTS[$i]}"
  URL="https://${HOST}.${DOMAIN}${MONITOR_PATH}"

  # Fetch JSON from monitoring endpoint using system curl
  JSON=$(/usr/bin/curl -s "$URL")

  if [[ -z "$JSON" ]]; then
    echo "Warning: empty response from ${URL}" >&2
    VERSION="unknown"
    BUILD_TIME=""
  else
    # Extract version (adjust jq paths to your actual JSON if needed)
    VERSION=$(jq -r '.version // .app.version // .build.version // empty' <<<"$JSON")

    # Extract build timestamp (field names may differ between services)
    BUILD_TIME=$(jq -r '.buildTime // .git.build.time // .time // empty' <<<"$JSON")
  fi

  VERSIONS[$i]="$VERSION"
  DATES[$i]="$BUILD_TIME"
done

# --------------------------------------------------------------------
# Determine latest release (highest semantic version)
# --------------------------------------------------------------------

LATEST_VERSION=$(printf '%s\n' "${VERSIONS[@]}" | sort -V | tail -n 1)

LATEST_DATE=""
for i in "${!VERSIONS[@]}"; do
  if [[ "${VERSIONS[$i]}" == "$LATEST_VERSION" ]]; then
    LATEST_DATE="${DATES[$i]}"
    break
  fi
done

# Cut timestamp to YYYY-MM-DD (if available)
LATEST_DATE_SHORT="${LATEST_DATE:0:10}"

# --------------------------------------------------------------------
# Final output in the desired format
# --------------------------------------------------------------------

echo "Service: ${SERVICE}"
echo "Country: ${COUNTRY}"
echo "Latest Release: ${LATEST_VERSION}  ${LATEST_DATE_SHORT}"

for i in "${!ENVS[@]}"; do
  ENV="${ENVS[$i]}"
  VERSION="${VERSIONS[$i]}"

  if [[ "$VERSION" == "$LATEST_VERSION" ]]; then
    MARK="✅"
  else
    MARK="❌"
  fi

  echo "${ENV}: ${VERSION} ${MARK}"
done
