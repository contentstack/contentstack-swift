---
name: code-review
description: Use when reviewing PRs for contentstack-swift—API stability, tests, SPM, and Apple platform impact.
---

# Code review – contentstack-swift

## When to use

- Reviewing Swift SDK changes
- Evaluating dependency version bumps (utils, DVR)

## Instructions

### Checklist

- **API**: Public surface changes semver-appropriate; changelog updated for user-visible behavior.
- **Tests**: New logic covered; CI scheme still passes.
- **Lint**: SwiftLint clean for touched files when applicable.
- **Dependencies**: Exact versions in `Package.swift` justified; security advisories considered.

### Severity hints

- **Blocker**: Broken `swift test` / `xcodebuild test`, or platform availability mistakes.
- **Major**: Missing tests for sync/query edge cases.
- **Minor**: Naming, internal structure.
