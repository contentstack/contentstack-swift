# Development Workflow – Contentstack Swift CDA SDK

Use this as the standard workflow when contributing to the Swift CDA SDK.

## Branches

- Use feature branches for changes (e.g. `feat/...`, `fix/...`).
- Base work off the appropriate long-lived branch (e.g. `staging`, `development`, `main`) per team norms.

## Running tests

- **SPM (from repo root):** `swift test`
- **SPM build only:** `swift build`
- **Xcode:** Open `ContentstackSwift.xcodeproj`, select a scheme (e.g. **ContentstackSwift iOS Tests**), and run tests (⌘U).
- **xcodebuild (example):**  
  `xcodebuild -project ContentstackSwift.xcodeproj -scheme "ContentstackSwift iOS" -destination 'platform=iOS Simulator,name=iPhone 16' test`  
  Adjust scheme and destination for macOS or tvOS as needed.

Run tests before opening a PR. Tests that call the live CDA may require stack credentials (e.g. `Tests/config.json` or environment-specific setup—do not commit real tokens).

## Pull requests

- Ensure the build passes: `swift test` and/or Xcode tests for affected platforms.
- Follow the **code-review** rule (see `.cursor/rules/code-review.mdc`) for the PR checklist.
- Keep changes backward-compatible for public API; call out any breaking changes clearly.

## Optional: TDD

If the team uses TDD, follow RED–GREEN–REFACTOR when adding behavior: write a failing test first, then implement to pass, then refactor. The **testing** rule and **skills/testing** skill describe test structure and naming.
