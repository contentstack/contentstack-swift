---
name: framework
description: Use when touching ContentstackConfig, URLSession, CSURLSessionDelegate, headers, cache – configuration and HTTP transport layer
---

# Framework – Contentstack Swift CDA SDK

Use this skill when changing configuration, URL session setup, or transport-level behavior (not CDA resource semantics).

## When to use

- Modifying **`ContentstackConfig`** (session configuration, decoding, early access, delegate hook).
- Changing how **`Stack`** builds **`URLSession`** or merges headers with `URLSessionConfiguration`.
- Adjusting **`CSURLSessionDelegate`**, SSL pinning, or cache usage (`URLCache`, cache policy on `Stack`).
- Introducing or changing timeouts, additional headers, or retry behavior at the session level.

## Instructions

### ContentstackConfig

- Holds **`URLSessionConfiguration`** (default `.default`), optional **`dateDecodingStrategy`** and **`timeZone`**, **`earlyAccess`**, **`urlSessionDelegate`**, and helpers for user agent / SDK version strings.
- SDK code sets **`httpAdditionalHeaders`** (e.g. `User-Agent`, `X-User-Agent`, `branch`); preserve merge semantics so caller-supplied headers are not dropped unintentionally.
- **Reference:** `Sources/ContentstackConfig.swift`.

### URLSession in Stack

- **`Stack`** initializes **`URLSession`** with `config.sessionConfiguration` and optional **`CSURLSessionDelegate`**.
- **`URLCache.shared`** is applied to the session configuration in current code paths—understand impact before changing cache defaults.
- **Reference:** `Sources/Stack.swift`.

### CSURLSessionDelegate

- Used for SSL pinning and session customization; changes should remain backward compatible for adopters implementing the delegate.
- **Reference:** `Sources/CSURLSessionDelegate.swift`.

### Retry and resilience

- Unlike the Java SDK, retry is not centralized in an interceptor. Prefer **`URLSessionConfiguration`** (timeouts, waits for connectivity) or explicit documented retry in the SDK if adding it—coordinate with **contentstack-swift-cda** skill for API surface.

### Error handling

- Transport failures should still surface as SDK **`Error`** instances through existing **`Result`** / handler paths after session tasks complete.

## Key types

- **Config / session:** `ContentstackConfig`, `URLSessionConfiguration`, `URLSession`
- **Delegate / cache:** `CSURLSessionDelegate`, `URLCache`, `CachePolicy` (on `Stack`)
- **Errors:** `Error` (SDK), mapping from `URLError` / HTTP status as implemented in request code

## References

- Project rules: `.cursor/rules/contentstack-swift-cda.mdc`, `.cursor/rules/swift.mdc`
- CDA skill: `skills/contentstack-swift-cda/SKILL.md` for how Stack uses the session for CDA calls
