---
name: testing
description: Use when writing or refactoring tests – XCTest, unit vs integration, fixtures, config.json, and test naming
---

# Testing – Contentstack Swift CDA SDK

Use this skill when adding or refactoring tests in the Swift CDA SDK.

## When to use

- Writing new unit or integration/API tests.
- Refactoring test helpers, builders, or shared session/stack setup.
- Adding fixtures or updating JSON used by tests.

## Instructions

### XCTest and layout

- Use **XCTest** (`import XCTest`, `XCTestCase`).
- Place tests under **`Tests/`**; the SPM target is **ContentstackTests** (see `Package.swift`).
- **Unit-style files:** Names like `*Test.swift` (e.g. `EntryTest`, `QueryTest`) for offline or focused behavior.
- **API / integration-style files:** Names like `*APITest.swift` or existing network tests (`EntryAPITest`, `SyncAPITest`, etc.). Reuse patterns from sibling files for stack initialization and expectations.

### Asynchronous tests

- Use **`XCTestExpectation`** and **`waitForExpectations`** for completion-handler-based APIs.
- Prefer **`XCTAssertThrowsError`** / **`try XCTUnwrap`** where appropriate; avoid unbounded waits.

### Test data and credentials

- **config / credentials:** Integration tests may read **`Tests/config.json`** or environment-specific setup. Never commit real tokens; document required fields for local/CI runs.
- **Fixtures:** JSON bundles (e.g. `Entry.json`, `Asset.json`) and DVR cassettes where the project uses **DVR**—keep paths and Xcode resource membership aligned when adding files.

### Naming and structure

- Mirror production areas: query tests near `Query*Test`, entry tests near `Entry*Test`, etc.
- Keep one primary concern per test case method; use descriptive `test*` names.

### Execution

- **SPM:** `swift test` from repo root.
- **Xcode:** Run the platform-specific test scheme that includes `Tests/` sources.

Maintain or improve meaningful coverage when changing production code; add tests for new or modified CDA behavior.

## References

- `Package.swift` – test target definition
- `Tests/` – existing patterns (`SutBuilder`, extensions, `*APITest`)
- Project rule: `.cursor/rules/testing.mdc`
