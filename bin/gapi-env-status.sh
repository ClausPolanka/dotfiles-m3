#!/usr/bin/env bash

# Ensure common binaries are available (important for non-interactive shells)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Fail fast
set -euo pipefail

# --------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------

SERVICE="GAPI"
REPO_DIR="/Users/sageniuz/dev/george/gapi-gimp"

# Country selection (HR = default)
COUNTRY_INPUT="${1:-HR}"
COUNTRY_UPPER=$(printf '%s' "$COUNTRY_INPUT" | tr '[:lower:]' '[:upper:]')

# Arrays prepared for country-specific values
declare -a ENVS
declare -a URLS

case "$COUNTRY_UPPER" in
  HR)
    COUNTRY="HR"
    ENVS=("FAT" "PPR" "UAT")
    URLS=(
      "https://apifat.erstebank.hr/george/monitoring/geapi/version"
      "https://apippr.erstebank.hr/george/monitoring/geapi/version"
      "https://apiuat.erstebank.hr/george/monitoring/geapi/version"
    )
    ;;

  RO)
    COUNTRY="RO"
    ENVS=("FAT" "PROD" "UAT")
    URLS=(
      "https://apitest.bcr.ro/proxy-web/proxy/g/api/public/version"
      "https://api.bcr.ro/proxy-web/proxy/g/api/public/version"
      "https://apiuat.bcr.ro/proxy-web/proxy/g/api/public/version"
    )
    ;;

  RS)
    COUNTRY="RS"
    ENVS=("FAT BLUE" "FAT GREEN" "PERF" "PROD" "UAT")
    URLS=(
      "https://george.blue.fat.erstebank.rs/pxy/g/api/public/version"
      "https://george.green.fat.erstebank.rs/pxy/g/api/public/version"
      "https://george.perf.erstebank.rs/pxy/g/api/public/version"
      "https://george.erstebank.rs/pxy/g/api/public/version"
      "https://george.uat.erstebank.rs/pxy/g/api/public/version"
    )
    ;;

  *)
    echo "Unsupported country: $COUNTRY_UPPER (supported: HR, RO, RS)" >&2
    exit 1
    ;;
esac

# --------------------------------------------------------------------
# Determine latest release from local git repo (like latest_releases)
# --------------------------------------------------------------------

if git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Get all tags matching release/*, sorted by semantic version (desc)
  TAGS=$(git -C "$REPO_DIR" tag -l 'release/*' --sort=-v:refname || true)

  if [[ -z "$TAGS" ]]; then
    echo "No tags matching 'release/*' found in $REPO_DIR." >&2
    exit 1
  fi

  # First tag in this sort order is the latest release
  LATEST_TAG=$(printf '%s\n' "$TAGS" | head -n 1)

  # Strip prefix 'release/' to get pure version (e.g. 6.3.0)
  LATEST_VERSION="${LATEST_TAG#release/}"

  # Commit date of that tag (YYYY-MM-DD)
  LATEST_DATE=$(git -C "$REPO_DIR" log -1 --pretty=format:%cs "$LATEST_TAG" 2>/dev/null || echo "")
else
  echo "Directory is not a git repository: $REPO_DIR" >&2
  exit 1
fi

LATEST_DATE_SHORT="$LATEST_DATE"

# --------------------------------------------------------------------
# Fetch version information per environment
# --------------------------------------------------------------------

declare -a VERSIONS

for i in "${!ENVS[@]}"; do
  ENV="${ENVS[$i]}"
  URL="${URLS[$i]}"

  JSON=$(/usr/bin/curl -s "$URL")

  if [[ -z "$JSON" ]]; then
    echo "Warning: empty response from ${URL}" >&2
    VERSION="unknown"
  else
    # Adjust jq path if your JSON looks different
    VERSION=$(jq -r '.version // .app.version // .build.version // empty' <<<"$JSON")
    if [[ -z "$VERSION" || "$VERSION" == "null" ]]; then
      VERSION="unknown"
    fi
  fi

  VERSIONS[$i]="$VERSION"
done

# --------------------------------------------------------------------
# Final output
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
