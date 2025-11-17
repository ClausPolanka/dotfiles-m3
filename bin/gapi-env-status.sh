#!/usr/bin/env bash

# Ensure common binaries are available (important for non-interactive shells)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Fail fast
set -euo pipefail

# --------------------------------------------------------------------
# Country selection (HR = default)
# --------------------------------------------------------------------

COUNTRY_INPUT="${1:-HR}"
COUNTRY_UPPER=$(printf '%s' "$COUNTRY_INPUT" | tr '[:lower:]' '[:upper:]')

SERVICE="GAPI"

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

# Arrays to store results
declare -a VERSIONS
declare -a DATES

# --------------------------------------------------------------------
# Fetch version information per environment
# --------------------------------------------------------------------

for i in "${!ENVS[@]}"; do
  ENV="${ENVS[$i]}"
  URL="${URLS[$i]}"

  JSON=$(/usr/bin/curl -s "$URL")

  if [[ -z "$JSON" ]]; then
    echo "Warning: empty response from ${URL}" >&2
    VERSION="unknown"
    BUILD_TIME=""
  else
    VERSION=$(jq -r '.version // .app.version // .build.version // empty' <<<"$JSON")
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

LATEST_DATE_SHORT="${LATEST_DATE:0:10}"

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
