# Skills – Contentstack Swift CDA SDK

This directory contains **skills**: reusable guidance for AI agents (and developers) on specific tasks. Each skill is a folder with a `SKILL.md` file.

## When to use which skill

| Skill | Use when |
|-------|----------|
| **contentstack-swift-cda** | Implementing or changing CDA features: Stack/ContentstackConfig, entries, assets, content types, sync, taxonomy, global fields, URLSession usage, callbacks, error handling. |
| **testing** | Writing or refactoring tests: XCTest, unit vs integration layout, fixtures, `Tests/config.json`, DVR where applicable. |
| **code-review** | Reviewing a PR or preparing your own: API design, optionals/errors, backward compatibility, dependencies/security, test coverage. |
| **framework** | Touching configuration or HTTP session behavior: `ContentstackConfig`, `URLSession`/`URLSessionConfiguration`, `CSURLSessionDelegate`, headers, cache. |

## How agents should use skills

- **contentstack-swift-cda:** Apply when editing SDK core (`Sources/`) or adding CDA-related behavior. Follow Stack/Config, CDA API alignment, and existing `Result` / completion-handler patterns.
- **testing:** Apply when creating or modifying test types under `Tests/`. Follow existing naming (`*Test`, `*APITest`) and shared test utilities.
- **code-review:** Apply when performing or simulating a PR review. Go through the checklist (API stability, errors, compatibility, dependencies, tests) and optional severity levels.
- **framework:** Apply when changing `ContentstackConfig`, session creation in `Stack`, or delegate/cache behavior. Keep networking consistent across the SDK.

Each skill’s `SKILL.md` contains more detailed instructions and references.
