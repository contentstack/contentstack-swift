---
name: swift-style
description: Use for Swift source layout, naming, SwiftLint rules, and SPM structure in contentstack-swift.
---

# Swift style & layout – contentstack-swift

## When to use

- Adding files under `Sources/ContentstackSwift` or tests under `Tests/`
- Fixing SwiftLint violations

## Instructions

### Layout

- Sources under **`Sources/`**; tests under **`Tests/`** per SPM conventions.

### Lint

- Run **`swiftlint`** using **`.swiftlint.yml`** before PRs when changing Swift code broadly.

### Style

- Match existing access control (`public`/`internal`) and error-handling patterns in sibling types.
