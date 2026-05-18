---
name: testing
description: Use for XCTest targets, DVR, and CI config secrets in contentstack-swift.
---

# Testing – contentstack-swift

## When to use

- Adding or fixing tests under `Tests/`
- Debugging CI-only failures that need `Tests/config.json`

## Instructions

### XCTest

- Tests target **`ContentstackTests`** in `Package.swift`; run via `swift test` or Xcode schemes.

### CI secrets

- Workflow may generate **`Tests/config.json`** from GitHub secrets—do not commit real stack credentials; mirror structure locally for integration runs only.

### HTTP recording

- **DVR** (dev dependency) may be used for recorded sessions—keep cassettes maintainable and free of secrets.
