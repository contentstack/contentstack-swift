# CocoaPods and the Contentstack Swift SDK

This page explains how **CocoaPods** fits into our story for the **Contentstack Swift SDK** (`ContentstackSwift`). It is written for **app developers** integrating the Content Delivery API on Apple platforms.

## Summary

- **The Swift SDK is not deprecated.** This repo continues to ship the supported Swift CDA client.
- We are **deprecating CocoaPods as the recommended way to consume** that SDK. **Swift Package Manager (SPM)** is what we recommend for **new** projects.
- If you already use the pod, you can **keep using it** until you choose to move to SPM.

## What to use

| You want to… | Use this |
|----------------|----------|
| Start a **new** integration | **SPM** — see [Swift Package Index](https://swiftpackageindex.com/contentstack/contentstack-swift) or add `https://github.com/contentstack/contentstack-swift` in Xcode (**File → Add Package Dependencies…**). |
| Read API docs | [Swift Content Delivery SDK reference](https://www.contentstack.com/docs/developers/sdks/content-delivery-sdk/swift/reference) |
| Browse source and tags | [contentstack-swift on GitHub](https://github.com/contentstack/contentstack-swift) |

## Existing CocoaPods users

No forced migration deadline is implied here. Projects that already depend on `ContentstackSwift` via CocoaPods can continue to ship. When you are ready, remove the pod and add the same library through SPM using the GitHub URL above.

## Why SPM for new work

The CocoaPods ecosystem has shifted toward maintenance and archived specs ([CocoaPods Specs repo — industry context](https://blog.cocoapods.org/CocoaPods-Specs-Repo/)). **SPM** is the default for most new Swift and Apple-platform codebases, and it is where we focus **new** documentation and examples. The CocoaPods spec may still receive **maintenance** updates for a time; **SPM should be your first choice** for new apps and modules.

## Help

Questions about the product or your stack: [Contentstack support](https://www.contentstack.com/support).

---

*Last updated: April 2026*
