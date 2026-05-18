# Contentstack Swift CDA SDK – Agent guide

**Universal entry point** for contributors and AI agents. Detailed conventions live in **`skills/*/SKILL.md`**.

## What this repo is

| Field | Detail |
|--------|--------|
| **Name:** | [contentstack-swift](https://github.com/contentstack/contentstack-swift) (SwiftPM product **ContentstackSwift**) |
| **Purpose:** | Swift Package for Contentstack Content Delivery—queries, entries, sync, etc.—for Apple platforms. |
| **Out of scope:** | Not the legacy Objective-C iOS CocoaPods SDK (`contentstack-ios`); new apps should prefer this Swift SDK per product direction. |

## Tech stack (at a glance)

| Area | Details |
|------|---------|
| Language | Swift (Package.swift tools **5.6+**); platforms include iOS 13+, macOS 10.15+, tvOS, watchOS per `Package.swift` |
| Build | SwiftPM; Xcode workspace **`ContentstackSwift.xcworkspace`**; Carthage used in CI |
| Tests | XCTest in **`Tests/`**; CI runs `xcodebuild test` (see `.github/workflows/ci.yml`) |
| Lint / coverage | SwiftLint **`.swiftlint.yml`** |
| CI | `.github/workflows/ci.yml`, `check-branch.yml`, `sca-scan.yml`, `policy-scan.yml`, `publish-cocoapods.yml` |

## Commands (quick reference)

| Command type | Command |
|--------------|---------|
| SPM | `swift build` / `swift test` |
| Lint | `swiftlint` (if installed) |
| Xcode (CI-style) | `xcodebuild test -workspace ContentstackSwift.xcworkspace -scheme "ContentstackSwift macOS Tests" ...` (see `ci.yml`) |

## Where the documentation lives: skills

| Skill | Path | What it covers |
|-------|------|----------------|
| **Development workflow** | [`skills/dev-workflow/SKILL.md`](skills/dev-workflow/SKILL.md) | Branches, CI, Carthage, SPM resolve |
| **Swift CDA SDK** | [`skills/contentstack-swift-cda/SKILL.md`](skills/contentstack-swift-cda/SKILL.md) | Public API, Stack types, dependencies on utils |
| **Swift style & layout** | [`skills/swift-style/SKILL.md`](skills/swift-style/SKILL.md) | `Sources/`, `Tests/`, SwiftLint |
| **Testing** | [`skills/testing/SKILL.md`](skills/testing/SKILL.md) | XCTest, DVR, `Tests/config.json` for CI |
| **Build & platform** | [`skills/framework/SKILL.md`](skills/framework/SKILL.md) | Workspace, schemes, CocoaPods publish |
| **Code review** | [`skills/code-review/SKILL.md`](skills/code-review/SKILL.md) | PR checklist |

## Using Cursor (optional)

If you use **Cursor**, [`.cursor/rules/README.md`](.cursor/rules/README.md) only points to **`AGENTS.md`**—same docs as everyone else.
