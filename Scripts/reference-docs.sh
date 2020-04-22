#!/bin/sh

source .env

echo "Generating Jazzy Reference Documentation for version $CONTENTSTACK_SDK_VERSION of the SDK"

jazzy \
  --clean \
  --author Contentstack \
  --author_url https://www.contentstack.com \
  --github_url https://github.com/contentstack/contentstack-swift \
  --github-file-prefix https://github.com/contentstack/contentstack-swift/tree/$CONTENTSTACK_SDK_VERSION \
  --xcodebuild-arguments -workspace,Contentstack.xcworkspace,-scheme,"Contentstack macOS" \
  --module Contentstack \
  --theme apple \
  --module-version "$CONTENSTACK_SDK_VERSION" \
  --exclude "*/*Model.swift"
