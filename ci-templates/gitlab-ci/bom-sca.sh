#!/bin/bash

# BOM SCA Scanner - Automated CI/CD version
# Implements SCAHelper.java logic in minimal bash script

set -euo pipefail

# Constants
BOM_DETECT_JAR_NAME="sca-bom-detect.jar"
BOM_DETECTOR_URL=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="${SCRIPT_DIR}/.scantist"
PROJECT_PATH="$(pwd)"
REPORT_DIR="${PROJECT_PATH}/devsecops_report"
JAR_PATH="${PLUGIN_DIR}/${BOM_DETECT_JAR_NAME}"

# Download SCA detector if not exists
if [[ ! -f "$JAR_PATH" ]]; then
    echo "[SCA] Downloading SCA detector..."
    mkdir -p "$PLUGIN_DIR"
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$JAR_PATH" "$BOM_DETECTOR_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$JAR_PATH" "$BOM_DETECTOR_URL"
    else
        echo "[SCA ERROR] Neither curl nor wget available" >&2
        exit 1
    fi
    echo "[SCA] Download completed"
fi

# Clean and create report directory
rm -rf "$REPORT_DIR" 2>/dev/null || true
mkdir -p "$REPORT_DIR"

# Validate DevSecOps token is provided
if [[ -z "${DEVSECOPS_TOKEN:-}" ]]; then
    echo "[SCA ERROR] DEVSECOPS_TOKEN environment variable is required" >&2
    exit 1
fi

# Run SCA scan
echo "[SCA] Starting scan on: $PROJECT_PATH"
echo "[SCA] DevSecOps integration enabled"
env DEVSECOPS_TOKEN="$DEVSECOPS_TOKEN" ${DEVSECOPS_IMPORT_URL:+DEVSECOPS_IMPORT_URL="$DEVSECOPS_IMPORT_URL"} \
    java -jar "$JAR_PATH" -f "$PROJECT_PATH" --debug -report json

echo "[SCA] Scan completed. Reports in: $REPORT_DIR"