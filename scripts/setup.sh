#!/bin/bash

set -eu

PROJECT_DIR="$(git rev-parse --show-toplevel)"
PLATFORM="ios"
SDK_VERSION="tayyabjaved/v3-example-release-build" #release/3.0.0-beta

PACKAGE_NAMES=(
    "SwitchboardSDK"
    "SwitchboardOnnx"
    "SwitchboardSileroVAD"
    "SwitchboardWhisper"
)

for PACKAGE_NAME in "${PACKAGE_NAMES[@]}"; do

    LIBS_DIR="${PROJECT_DIR}/Frameworks/${PACKAGE_NAME}/${PLATFORM}"
    rm -rf "${LIBS_DIR}"
    mkdir -p "${LIBS_DIR}"

    TMP_LIBS_DIR="${LIBS_DIR}/tmp"
    mkdir -p "${TMP_LIBS_DIR}"

    pushd "${TMP_LIBS_DIR}"

    echo "Downloading ${PACKAGE_NAME}..."
    curl -O "https://switchboard-sdk-public.s3.amazonaws.com/builds/${SDK_VERSION}/${PLATFORM}/${PACKAGE_NAME}.zip"

    echo "Unpacking ${PACKAGE_NAME}..."
    mkdir -p "${LIBS_DIR}"
    unzip "${PACKAGE_NAME}.zip" -d "${LIBS_DIR}"
    
    popd
    
    rm -rf "${TMP_LIBS_DIR}"
done