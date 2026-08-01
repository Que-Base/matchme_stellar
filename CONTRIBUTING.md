# Contributing to MatchMe Stellar Mobile

Guide for working on the MatchMe iOS application (`matchme.mobile_swift`), extending features, or integrating new Stellar blockchain capabilities.

---

## 📁 Repository Layout

```text
matchme.mobile_swift/
├── matchme_mobile_swiftApp.swift   # App entry point
├── ContentView.swift                # Root view & auth state routing
├── models/                          # ViewModels & services (Auth, StellarWallet, User)
├── views/                           # SwiftUI views organized by feature (Auth, Onboarding, Profile, Explore, Chats, Likes)
├── Helpers/                         # Utilities, typography, custom extensions
└── Assets.xcassets/                 # Asset catalog (icons, colors, media)

matchme.mobile_swiftTests/          # XCTest unit test suites
.githooks/                           # Git hook scripts (pre-commit format & conflict guards)
scripts/                             # Operational & build helper scripts (build.sh, test.sh, setup-hooks.sh)
docs/                                # Project documentation & design assets
```

---

## ⚙️ Development Environment Prerequisites

- **macOS** running **Xcode 15.0+** with iOS Simulator installed.
- **Swift 5.10+** toolchain.
- **Git** with local hooks configured. Run once after cloning:
  ```bash
  bash scripts/setup-hooks.sh
  # or
  git config core.hooksPath .githooks
  ```

---

## ⛓ Architecture & Coding Standards

1. **MVVM with `@Observable`**:
   - Use Swift 5.9+ `@Observable` macro for view models (`AuthViewModel`, `ProfileViewModel`).
   - Keep state mutation localized to ViewModels and services.

2. **Stellar Wallet Security**:
   - Every user has an Ed25519 Stellar keypair generated on-device at signup.
   - **Secret seeds must NEVER leave Keychain storage** (`kSecAccessControlBiometryAny` / `WhenUnlockedThisDeviceOnly`).
   - `StellarWalletService` handles all Horizon operations asynchronously.

3. **Navigation & Routing**:
   - Navigation is handled via `SwiftfulRouting`. Avoid hardcoding nested `NavigationLink` logic directly in views.

4. **Styling & Assets**:
   - Use reusable components in `views/reusable_views/` (`CuddleGradientButton`, `CuddleInputField`, `CuddleProfileInfoView`).
   - Color palettes and typography should use extensions defined in `Helpers/`.

---

## 🧪 Before Opening a Pull Request

Run the local build and test verification scripts to verify that code compiles cleanly and unit tests pass:

```bash
# Setup local git hooks (one-time setup)
bash scripts/setup-hooks.sh

# Build the iOS App target
bash scripts/build.sh

# Run the unit test suite
bash scripts/test.sh
```

---

## 🏷 PR & Issue Hygiene

- **Scope PRs to a single issue**: Reference the target `ISS-xxx` ID in your PR title and description.
- **Verify test coverage**: Add XCTest coverage under `matchme.mobile_swiftTests/` for any new ViewModels or service methods.
- **No unrelated changes**: Keep formatting and refactoring strictly relevant to the task at hand.
