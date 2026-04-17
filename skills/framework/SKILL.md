---
name: framework
description: Use for Xcode workspace, schemes, Carthage, CocoaPods publish, and platform matrix in contentstack-swift.
---

# Build & platform – contentstack-swift

## When to use

- Changing `ContentstackSwift.xcworkspace`, shared schemes, or pod publish flow
- Updating minimum OS versions or SPM dependencies

## Instructions

### Xcode

- CI uses **`ContentstackSwift.xcworkspace`** and scheme **"ContentstackSwift macOS Tests"** on Apple Silicon—verify scheme names when renaming.

### CocoaPods

- Publishing pipeline in **`.github/workflows/publish-cocoapods.yml`**—coordinate version bumps with podspec if present at repo root.

### Carthage

- CI bootstraps Carthage with **`--use-xcframeworks`**—local changes to binary deps should be validated with the same flow.
