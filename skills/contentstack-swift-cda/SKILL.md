---
name: contentstack-swift-cda
description: Use when implementing or changing CDA features – Stack/ContentstackConfig, entries, assets, sync, taxonomy, URLSession, callbacks, and Content Delivery API alignment
---

# Contentstack Swift CDA SDK – CDA Implementation

Use this skill when implementing or changing Content Delivery API (CDA) behavior in the Swift SDK.

## When to use

- Adding or modifying Stack, Entry, Query, Asset, Content Type, Sync, Taxonomy, or Global Field behavior.
- Changing `Contentstack.stack(...)` parameters or regional/host/branch handling.
- Working with URLSession-backed requests, response decoding, or `Result` / `ResultsHandler` error delivery.

## Instructions

### Stack and ContentstackConfig

- **Entry point:** `Contentstack.stack(apiKey:deliveryToken:environment:region:host:apiVersion:branch:config:)`. Optional **`ContentstackConfig`** controls session configuration, decoding, early access, and `urlSessionDelegate`.
- **Defaults:** `Host.delivery` (`cdn.contentstack.io`), `apiVersion` default `v3`, `ContentstackRegion.us` unless overridden.
- **Reference:** `Sources/Contentstack.swift`, `Sources/Stack.swift`, `Sources/ContentstackConfig.swift`.

### CDA resources

- **Entries / content types:** `Stack.contentType(uid:)`, `Entry`, `Query`, models such as `EntryModel`, `ContentTypeModel`.
- **Assets:** `Stack.asset`, asset query/fetch patterns and `AssetModel`.
- **Sync:** `SyncStack` and sync endpoint usage under `Endpoint.sync`.
- **Taxonomy / global fields:** `Taxonomy`, `GlobalField`, related models and queries.
- **Official API:** Align with [Content Delivery API](https://www.contentstack.com/docs/apis/content-delivery-api/) for parameters, response shape, and semantics.

### HTTP and session

- **HTTP:** CDA calls go through **`Stack`**’s **`URLSession`**, built from **`ContentstackConfig.sessionConfiguration`** (with SDK headers applied). Do not duplicate ad-hoc sessions for standard CDA traffic.
- **Retry:** There is no separate retry framework like the Java SDK’s `RetryInterceptor`; if you add retries, integrate via config/session and document behavior (see **framework** skill).

### Errors and callbacks

- **Errors:** Use the SDK **`Error`** type and surface failures via **`Result<Success, Error>`** and **`ResultsHandler`** (or existing async APIs).
- **Callbacks:** Preserve completion-handler signatures for public API; additive overloads (e.g. `async`) should map to the same error and response semantics.

## Key types

- **Entry points:** `Contentstack`, `Stack`, `ContentstackConfig`
- **CDA:** `Entry`, `Query`, `Asset`, `ContentType`, `SyncStack`, `Taxonomy`, `GlobalField`, `Endpoint`
- **Responses / errors:** `ContentstackResponse`, `Error`, `ResponseType`

## References

- [Content Delivery API – Contentstack Docs](https://www.contentstack.com/docs/apis/content-delivery-api/)
- Project rules: `.cursor/rules/contentstack-swift-cda.mdc`, `.cursor/rules/swift.mdc`
