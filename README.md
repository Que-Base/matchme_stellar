# MatchMe Mobile

SwiftUI iOS application and Stellar blockchain integration for the MatchMe social discovery network.

## Overview

MatchMe is a modern social networking application built with SwiftUI, Firebase, and the Stellar blockchain. It combines dynamic discovery feeds, profile management, and real-time messaging with non-custodial Stellar wallet creation, testnet funding, and Horizon RPC balance tracking.

## Components

| Component | Path | Status | Description |
|---|---|---|---|
| **App Target** | `matchme.mobile_swift/` | ✅ Active | Primary SwiftUI application containing views, view models, and asset catalogs |
| **Stellar Wallet Service** | `matchme.mobile_swift/models/StellarWalletService.swift` | ✅ Active | Thread-safe Swift `actor` handling keypair creation, Keychain vault storage, and Horizon RPC balance queries |
| **Auth & Profile** | `matchme.mobile_swift/models/AuthViewModel.swift` | ✅ Active | Firebase Authentication, session lifecycle, secure form inputs, and profile state |
| **Firestore Security** | `firestore.rules` | ✅ Active | Production Cloud Firestore security rules enforcing document-level owner authorization |
| **Unit Test Suite** | `matchme.mobile_swiftTests/` | ✅ Active | XCTest unit test suite covering Auth, Stellar Wallet, and Profile models |

## Tech Stack

- **Language**: Swift 5.10+ (iOS 17.0+ SDK)
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with Swift `@Observable` macro
- **Navigation**: [SwiftfulRouting](https://github.com/SwiftfulThinking/SwiftfulRouting)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Cloud Storage)
- **Blockchain**: [Stellar](https://stellar.org) via [Soneso stellar-ios-mac-sdk](https://github.com/Soneso/stellar-ios-mac-sdk)
- **Build & CI**: Xcode, xcodebuild, GitHub Actions

## Documentation

### Security

Please review our [Security Policy](SECURITY.md) for information on reporting vulnerabilities and our non-custodial key storage model.

### Architecture & Standards

- **[Contributing Guide](CONTRIBUTING.md)** - Code conventions, repository layout, and pre-PR verification guidelines.
- **[Issue Dependency Graph](ISSUE_DEPENDENCY_GRAPH.md)** - Ordered execution flow showing which issues block others.
- **[Stellar Architecture Guide](STELLAR_ARCHITECTURE.md)** - Keypair generation, iOS Keychain access rules, and Horizon integration details.
- **[Stellar Roadmap](STELLAR_ROADMAP.md)** - Multi-phase breakdown for tokens, smart contracts, and identity.
- **[Issue Tracker](ISSUES.md)** - Master issue index and milestone tracking.

## Planned Functionality

- `MATCH` token asset trustlines and balance queries
- P2P token payments and tipping on profile interactions
- Soroban smart contracts for premium subscriptions and date escrow
- NFT profile badge minting on Stellar
- 12-word seed phrase backup and mnemonic recovery flow
- Stellar DID identity verification layer

## Project Structure

```text
cuddleme.mobile_Stellar/
├── matchme.mobile_swift/               # Primary iOS app target
│   ├── matchme_mobile_swiftApp.swift   # App entry point
│   ├── ContentView.swift                # Root view and auth router
│   ├── models/                          # ViewModels and services
│   ├── views/                           # Feature UI views
│   ├── Helpers/                         # Utilities, typography, and styling
│   └── Assets.xcassets/                 # Asset catalog
├── matchme.mobile_swiftTests/          # XCTest unit test suite
├── .githooks/                           # Pre-commit hook scripts
├── .github/workflows/ci.yml             # GitHub Actions CI workflow
├── scripts/                             # Operational helper scripts
├── docs/                                # Project documentation assets
├── firestore.rules                      # Cloud Firestore security rules
├── firestore.indexes.json               # Cloud Firestore composite indexes
├── STELLAR_ARCHITECTURE.md              # Technical architecture documentation
├── STELLAR_ROADMAP.md                   # Feature roadmap documentation
├── CONTRIBUTING.md                      # Contributor guide
├── SECURITY.md                          # Security policy
├── ISSUES.md                            # Issue tracker
└── LICENSE                              # MIT License
```

## Getting Started

### Prerequisites

- **macOS** with **Xcode 15.0+** (iOS 17.0+ Simulator)
- **Swift 5.10+** toolchain
- A Firebase project configured in the [Firebase Console](https://console.firebase.google.com/)

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Que-Base/matchme_stellar.git
   cd matchme_stellar
   ```

2. **Configure local Git hooks**:
   ```bash
   bash scripts/setup-hooks.sh
   ```

3. **Add Firebase configuration**:
   Download `GoogleService-Info.plist` from the Firebase Console and place it inside `matchme.mobile_swift/`.

4. **Build and Run**:
   Open `matchme.mobile_swift.xcodeproj` in Xcode, select an iOS Simulator target, and press `Cmd + R`.

> **Stellar Network**: The app currently targets the **Stellar testnet**. New user wallets are funded automatically via Friendbot.

## Developer Commands

Convenience scripts are provided in `scripts/`:

```bash
# Configure local Git hooks path
bash scripts/setup-hooks.sh

# Build the Xcode iOS application target
bash scripts/build.sh

# Run the unit test suite
bash scripts/test.sh
```

## License

This project is licensed under the [MIT License](LICENSE).
