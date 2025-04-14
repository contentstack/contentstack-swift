#!/bin/bash
# Run this script before building or testing the project

ZIP_PATH="Utility/contentstack-swift-dvr.zip"
UNZIP_DIR="Utility/contentstack-swift-dvr"

# Only unzip if the DVR source doesn't already exist
if [ ! -d "$UNZIP_DIR/Sources" ]; then
  echo "🔧 Unzipping DVR testing framework..."
  unzip -q "$ZIP_PATH" -d "$UNZIP_DIR"
  echo "✅ DVR testing framework ready."
else
  echo "✅ DVR already unzipped."
fi
