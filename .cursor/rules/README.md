# Cursor Rules – Contentstack Swift CDA SDK

This directory contains Cursor AI rules that apply when working in this repository. Rules provide persistent context so the AI follows project conventions and Contentstack CDA patterns.

## How rules are applied

- **File-specific rules** use the `globs` frontmatter: they apply when you open or edit files matching that pattern.
- **Always-on rules** use `alwaysApply: true`: they are included in every conversation in this project.

## Rule index

| File | Applies when | Purpose |
|------|--------------|---------|
| **dev-workflow.md** | (Reference only; no glob) | Core development workflow: branches, running tests, PR expectations. Read for process guidance. |
| **swift.mdc** | Editing any `**/*.swift` file | Swift standards: naming, `Sources`/`Tests` layout, module **ContentstackSwift**, logging, optionals and error style. |
| **contentstack-swift-cda.mdc** | Editing `Sources/**/*.swift` | CDA-specific patterns: Stack/ContentstackConfig, host/version/region/branch, URLSession, `Result`/`ResultsHandler`, alignment with Content Delivery API. |
| **testing.mdc** | Editing `Tests/**/*.swift` | Testing patterns: XCTest, unit vs integration tests, fixtures, DVR where used. |
| **code-review.mdc** | Always | PR/review checklist: API stability, error handling, backward compatibility, dependencies and security (e.g. SCA). |

## Related

- **AGENTS.md** (repo root) – Main entry point for AI agents: project overview, entry points, and pointers to rules and skills.
- **skills/** – Reusable skill docs (Contentstack Swift CDA, testing, code review, framework) for deeper guidance on specific tasks.
