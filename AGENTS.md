# Contentstack Swift CDA SDK – Agent Guide

This document is the main entry point for AI agents working in this repository.

## Project

- **Name:** Contentstack Swift CDA SDK (contentstack-swift)
- **Purpose:** Swift client for the Contentstack **Content Delivery API (CDA)**. It fetches content (entries, assets, content types, sync, taxonomy, global fields) from Contentstack for iOS, macOS, tvOS, watchOS, and Swift Package Manager consumers.
- **Repo:** [contentstack-swift](https://github.com/contentstack/contentstack-swift)

## Tech stack

- **Language:** Swift (SPM minimum **swift-tools-version 5.6**; align with Xcode requirements in README)
- **Build:** Swift Package Manager (`Package.swift`), **Xcode** (`ContentstackSwift.xcodeproj`) for multi-platform frameworks and CocoaPods (`ContentstackSwift.podspec`)
- **Testing:** **XCTest** (`Tests/`), optional **DVR** (HTTP recording) for some tests; integration-style tests may use `Tests/config.json` / stack credentials
- **HTTP:** **URLSession** (configured via `ContentstackConfig.sessionConfiguration`), optional **`CSURLSessionDelegate`** (SSL pinning / customization)
- **Other:** [contentstack-utils-swift](https://github.com/contentstack/contentstack-utils-swift) (Rich text rendering)

## Main entry points

- **`Contentstack`** – Static factory: `Contentstack.stack(apiKey:deliveryToken:environment:region:host:apiVersion:branch:config:)` returns a `Stack`.
- **`Stack`** – Main API surface: content types, entries, assets, sync, taxonomy, queries, cache policy, JSON decoding.
- **`ContentstackConfig`** – Optional configuration: `URLSessionConfiguration`, date/time zone decoding, early access headers, `urlSessionDelegate`, user agent.
- **Paths:** `Sources/` (library target **ContentstackSwift**), `Tests/` (test target **ContentstackTests**).

## Commands

- **SPM build:** `swift build`
- **SPM tests:** `swift test`
- **Xcode:** Open `ContentstackSwift.xcodeproj`, then build/test schemes such as **ContentstackSwift iOS**, **ContentstackSwift macOS**, **ContentstackSwift tvOS** (and matching test targets).
- **xcodebuild (example – adjust simulator/OS):**  
  `xcodebuild -project ContentstackSwift.xcodeproj -scheme "ContentstackSwift iOS" -destination 'platform=iOS Simulator,name=iPhone 16' build test`

Run tests before opening a PR. API/integration tests that hit a live stack need valid credentials (see test helpers and `Tests/config.json` where applicable); do not commit secrets.

## Rules and skills

- **`.cursor/rules/`** – Cursor rules for this repo:
  - **README.md** – Index of all rules and when each applies (globs / always-on).
  - **dev-workflow.md** – Development workflow (branches, tests, PR expectations).
  - **swift.mdc** – Applies to `**/*.swift`: Swift style, module layout, logging, optionals.
  - **contentstack-swift-cda.mdc** – Applies to `Sources/**/*.swift`: CDA patterns, Stack/Config, host/version/region/branch, callbacks, alignment with Content Delivery API.
  - **testing.mdc** – Applies to `Tests/**/*.swift`: test naming, unit vs integration, XCTest.
  - **code-review.mdc** – Always applied: PR/review checklist (aligned with other Contentstack CDA SDKs).
- **`skills/`** – Reusable skill docs:
  - Use **contentstack-swift-cda** when implementing or changing CDA API usage or SDK core behavior.
  - Use **testing** when adding or refactoring tests.
  - Use **code-review** when reviewing PRs or before opening one.
  - Use **framework** when changing config, URL session setup, or HTTP-related behavior (`ContentstackConfig`, `Stack` networking).

Refer to `.cursor/rules/README.md` for when each rule applies and to `skills/README.md` for skill details.
