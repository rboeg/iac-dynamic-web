#!/bin/bash
set -e

# Define paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAMBDA_SRC_DIR="$SCRIPT_DIR/../terraform/lambda"
BUILD_DIR="$SCRIPT_DIR/../lambda_build"
ZIP_FILE="$BUILD_DIR/tf_dyn_web_lambda.zip"

# Ensure build directory exists
mkdir -p "$BUILD_DIR"

# Package Lambda code
cd "$LAMBDA_SRC_DIR"

zip -r "$ZIP_FILE" . -x "*.pyc" "__pycache__/*"

echo "Lambda package created at $ZIP_FILE"
