---
name: dev-workflow
description: Use for SwiftPM, Xcode CI, Carthage, and branch workflow in contentstack-swift.
---

# Development workflow – contentstack-swift

## When to use

- Resolving dependencies or matching CI steps locally
- Preparing a release with CocoaPods workflow

## Instructions

### Dependencies

- **`swift package resolve`** after manifest changes; CI also runs Carthage bootstrap for xcframeworks—see `.github/workflows/ci.yml`.

### Branches

- **`master`** and **`staging`** trigger CI—align PR targets with team practice.

### Local checks

- `swift build && swift test` for quick validation.
- Full parity with CI may require Xcode `xcodebuild test` with the workspace and scheme from the workflow file.
