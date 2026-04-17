---
name: contentstack-swift-cda
description: Use for the Swift Content Delivery API, Stack and query types, and dependency on ContentstackUtils.
---

# Swift CDA SDK – contentstack-swift

## When to use

- Editing public Swift APIs under `Sources/`
- Integrating with **contentstack-utils-swift** for RTE or shared helpers

## Instructions

### Package

- Library target **`ContentstackSwift`** depends on **ContentstackUtils** (see `Package.swift`).

### API

- Preserve semver for public types and methods; document breaking changes in changelog/README.

### Cross-platform

- Respect minimum OS versions in `Package.swift` when using newer APIs—keep availability checks consistent.
