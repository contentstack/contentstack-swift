# CHANGELOG

## v2.3.4

### Date: 12-Jun-2026

### Bug Fixes

- Added `toJSON()` to `EntryModel`, `AssetModel`, and `ContentTypeModel` to make entries with resolved references serializable via `JSONSerialization`.

## v2.3.3

### Date: 18-May-2026

### Documentation

- Announced deprecation of **CocoaPods** as the recommended distribution for the Contentstack Swift SDK; **Swift Package Manager** is recommended for new integrations. Updated [README.md](README.md), [Docs/overview.md](Docs/overview.md), and [DEPRECATION.md](DEPRECATION.md).

- Scope DVR dependency to test target only

## v2.3.2

### Date: 12-Jan-2026

- Improved error messages

## v2.3.1

### Date: 03-Nov-2025

- Github issues fixed

## v2.3.0

### Date: 29-Sep-2025

- Added AU and GCP-EU region support

## v2.2.0

### Date: 22-Sep-2025

- Async/await support added

## v2.1.0

### Date: 06-Jun-2025

- ✅ SSL pinning implementation 
- 🔧 Added support for Global Fields 
- 🔄 Workflow fixes
- ⚙️ Updated `.talismanrc` to version 1.0 

---

## v2.0.1

### Date: 13-May-2025

- 🔧 Minor internal fixes
- ✅ Updated testing support
- ⚠️ Note: Versions `v1.6.2` and `v2.0.0` are not recommended due to stability concerns.
  Please use `v2.0.1` or later.

---

## v2.0.0

### Date: 12-May-2025

- 🧹 Removed unused workspace configuration file 
- 📦 DX Release 

---

## v1.6.2

### Date: 07-Feb-2025

- 📦 Dependencies updated
- 🔄 Workflow fixes
- ✅ Updated test cases

---

## v1.6.1

### Date: 07-Oct-2024

- ✨ Added Early Access Header Support

---

## v1.6.0

### Date: 23-Aug-2024

- 🌿 Added support for taxonomy

---

## v1.5.3

### Date: 17-May-2024

- 🌐 Added GCP support
- 🛡️ Added privacy manifest file

---

## v1.5.2

### Date: 21-Mar-2024

- 🔧 Fixed issues while switching stacks

---

## v1.5.1

### Date: 02-Aug-2023

- 🐞 Resolved URLCache issue

---

## v1.5.0

### Date: 26-May-2023

- 🌍 Added Azure-EU region in `ContentstackRegion`
- ➕ Included metadata in:

  - `AssetQuery` class
  - `EntryQueriable` class
- 🧰 Fixed image transform initialization issue

---

## v1.4.0

### Date: 09-Mar-2023

- ➕ Added header support in:
  - `Entry`
  - `Asset`
  - `Query`

---

## v1.3.1

### Date: 11-Nov-2022

- 🛠️ Resolved URL session default cache issue

---

## v1.3.0

### Date: 18-Aug-2022

- 🌐 Added Azure-NA region in `ContentstackRegion`
- 🔐 Security details added

---

## v1.2.6

### Date: 10-Aug-2021

- 📦 Updated Utils SDK package

---

## v1.2.5

### Date: 16-Jul-2021

- 📝 Added JSON RTE feature support
- 📦 Updated Util SDK version

---

## v1.2.4

### Date: 09-Apr-2021

- 📦 Added CocoaPods dependency

---

## v1.2.3

### Date: 09-Apr-2021

- ➕ Added Utils SDK function support

---

## v1.2.2

### Date: 06-Apr-2021

- 🛠️ Resolved CocoaPods issue
- ➖ Removed unnecessary dependency

---

## v1.2.1

### Date: 06-Apr-2021

- 📁 Project file updated

---

## v1.2.0

### Date: 06-Apr-2021

- ➕ Added embedded items feature:
-`includeEmbeddedItems` in Entry and Query modules
- 📦 Added Utils SDK support

---

## v1.1.0

### Date: 05-Dec-2020

- 🔄 Added content fallback support in:
- `Asset`, `AssetLibrary`, `Entry`, `Query` modules

---

## v1.0.0

### Date: 11-May-2020

- 🚀 Initial release
