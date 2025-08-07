#!/bin/bash

set -e

ORB_NAME="scan/sca"

log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1"
}

case "$1" in
    "pack")
        log_info "Packing orb..."
        circleci orb pack src > orb.yml
        log_info "Packed to orb.yml"
        ;;
    "publish")
        if [ -z "$2" ]; then
            log_error "Version required: ./publish-orb.sh publish 0.0.11"
            exit 1
        fi
        log_info "Publishing $ORB_NAME@$2"
        circleci orb publish orb.yml "$ORB_NAME@$2"
        log_info "Published successfully"
        ;;
    *)
        echo "Usage:"
        echo "  $0 pack                 - Pack orb to orb.yml"
        echo "  $0 publish <version>    - Publish orb version"
        echo ""
        echo "Example:"
        echo "  $0 pack"
        echo "  $0 publish 0.0.11"
        ;;
esac
