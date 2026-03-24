---
name: code-review
description: Use when reviewing PRs or before opening a PR – API design, optionals/errors, backward compatibility, dependencies, security, and test quality
---

# Code Review – Contentstack Swift CDA SDK

Use this skill when performing or preparing a pull request review for the Swift CDA SDK.

## When to use

- Reviewing someone else’s PR.
- Self-reviewing your own PR before submission.
- Checking that changes meet project standards (API, errors, compatibility, tests, security).

## Instructions

Work through the checklist below. Optionally tag items with severity: **Blocker**, **Major**, **Minor**.

### 1. API design and stability

- [ ] **Public API:** New or changed public types/methods are necessary and documented (`///` where the project documents public symbols, with parameters/returns as appropriate).
- [ ] **Backward compatibility:** No breaking changes to public API unless explicitly agreed (e.g. major version). Deprecations should use `@available` / messaging with alternatives where Swift allows.
- [ ] **Naming:** Consistent with existing SDK style and CDA terminology (`Stack`, `Entry`, `Query`, `ContentstackConfig`).

**Severity:** Breaking public API without approval = Blocker. Missing docs on new public API = Major.

### 2. Error handling and robustness

- [ ] **Errors:** Failures map to the SDK `Error` type and existing `Result` / completion patterns.
- [ ] **Optionals:** No inappropriate force unwraps; optionals are meaningful and handled.
- [ ] **Throws:** `throws` APIs document failure modes; callers can handle errors predictably.

**Severity:** Wrong or missing error handling in new code = Major.

### 3. Dependencies and security

- [ ] **Dependencies:** New or upgraded Swift packages / pods are justified; versions do not introduce known vulnerabilities.
- [ ] **SCA:** Security findings (e.g. Snyk, Dependabot) in the change set are addressed or explicitly deferred with a ticket.

**Severity:** New critical/high vulnerability = Blocker.

### 4. Testing

- [ ] **Coverage:** New or modified behavior has corresponding unit and/or integration tests.
- [ ] **Conventions:** Tests follow existing naming and layout under `Tests/`.
- [ ] **Quality:** Tests are readable, deterministic (no flakiness), and assert meaningful behavior.

**Severity:** No tests for new behavior = Blocker. Flaky or weak tests = Major.

### 5. Optional severity summary

- **Blocker:** Must fix before merge (e.g. breaking API without approval, security issue, no tests for new code).
- **Major:** Should fix (e.g. inconsistent error handling, missing documentation on new public API, flaky tests).
- **Minor:** Nice to fix (e.g. style, minor docs, redundant code).

## References

- Project rule: `.cursor/rules/code-review.mdc`
- Testing skill: `skills/testing/SKILL.md` for test standards
