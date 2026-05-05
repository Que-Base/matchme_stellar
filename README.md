# MatchMe Stellar Mobile (Swift, Stellar)

MatchMe is a modern, visually rich social networking application built with SwiftUI. It features a seamless onboarding experience, profile management, discovery (Explore), and real-time interactions (Chats/Likes). The application follows a modern MVVM architecture, integrates with Firebase for authentication and backend services, and uses the **Stellar blockchain** for decentralised identity, wallet management, and a token economy.

## 🚀 Features

- **Onboarding & Authentication**: Smooth user onboarding flow with secure Firebase-backed sign-up and profile setup.
- **Stellar Wallet**: Every user gets a non-custodial Stellar wallet automatically on signup — keypair generated on-device, secret seed stored in Keychain.
- **Discovery (Explore)**: An intuitive interface to discover other users.
- **Interactions**: Like and connect with others, supported by a dedicated "Likes" view and real-time chat.
- **Rich Profiles**: Comprehensive profile management including bios, interests, and photo uploads.
- **Modern UI**: Custom-designed components with a focus on aesthetics, utilizing custom typography and gradients.
- **Dynamic Routing**: Powered by `SwiftfulRouting` for a decoupled and flexible navigation experience.

## 🛠 Tech Stack

- **Language**: Swift 5.10+
- **UI Framework**: SwiftUI
- **Navigation**: [SwiftfulRouting](https://github.com/SwiftfulThinking/SwiftfulRouting)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage)
- **Blockchain**: [Stellar](https://stellar.org) via [Soneso stellar-ios-mac-sdk](https://github.com/Soneso/stellar-ios-mac-sdk)
- **Architecture**: MVVM (using the latest `@Observable` macro)
- **Design Assets**: Custom icons (Linear & Misc), Custom Fonts (Athletics, General Sans, SF Pro Rounded)

## ⛓ Stellar Integration

See [`STELLAR_ARCHITECTURE.md`](./STELLAR_ARCHITECTURE.md) for the full technical architecture.

### What's implemented

- **Auto wallet creation** — a Stellar Ed25519 keypair is generated at signup. The secret seed is stored in iOS Keychain (`WhenUnlockedThisDeviceOnly`). The public key is saved to Firestore alongside the user's profile.
- **Testnet funding** — new accounts are automatically funded via Friendbot (10,000 XLM on testnet).
- **Live balance** — `StellarWalletView` fetches and displays the user's XLM balance from Horizon in real time.
- **Non-custodial** — MatchMe never holds private keys. Users own their wallets.

### Stellar files

| File | Purpose |
|---|---|
| `models/StellarWalletService.swift` | Keypair management, Keychain storage, Friendbot funding, balance queries |
| `models/userModel.swift` | `stellarPublicKey` field on the `User` struct |
| `models/AuthViewModel.swift` | Wallet creation wired into `createUser` |
| `views/StellarWalletView.swift` | SwiftUI card showing public key + XLM balance |

### Roadmap

| Phase | Feature |
|---|---|
| ✅ Phase 1 | Wallet creation, Keychain storage, testnet funding, balance display |
| 🔜 Phase 2 | `MATCH` token economy — earn on likes/matches, spend on super likes & tips |
| 🔜 Phase 3 | Soroban smart contracts — subscriptions, date escrow, NFT profile badges |

## 📁 Project Structure

```text
matchme.mobile_swift/
├── matchme_mobile_swiftApp.swift   # App entry point
├── ContentView.swift                # Root view (auth routing)
├── models/
│   ├── AuthViewModel.swift          # Auth state + Stellar wallet wiring
│   ├── userModel.swift              # User data structure (+ stellarPublicKey)
│   ├── StellarWalletService.swift   # Stellar network interactions
│   └── profileViewModel.swift       # Profile logic
├── views/
│   ├── StellarWalletView.swift      # Wallet card UI
│   ├── dashboardView.swift          # Main tab navigation
│   ├── Auth_view/                   # Sign up / sign in
│   ├── Onboarding_flow_view/        # Profile setup & onboarding
│   ├── Explore/                     # Discovery
│   ├── Likes/                       # Likes feed
│   ├── Chats/                       # Messaging
│   ├── Profile/                     # Profile management
│   └── reusable_views/              # Shared UI components
├── Helpers/
│   ├── cuddleColor.swift            # Color extensions
│   ├── customScrollView.swift       # Scroll helpers
│   └── Fonts/                       # Custom font assets
└── Assets.xcassets/                 # Icons, logos, colors
```

## ⚙️ Setup Instructions

### Prerequisites
- macOS with **Xcode 15.0+**
- A Firebase project set up in the [Firebase Console](https://console.firebase.google.com/)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Que-Base/matchme_stellar.git
   cd matchme_stellar
   ```

2. **Open the project**:
   ```
   open matchme.mobile_swift.xcodeproj
   ```

3. **Firebase Configuration**:
   - Download `GoogleService-Info.plist` from the Firebase Console.
   - Add it to the `matchme.mobile_swift/` directory in Xcode, ensuring it's added to the app target.
   - `GoogleService-Info.plist` is gitignored — you must add it manually on each clone.

4. **Dependencies** — Xcode resolves all SPM packages automatically on first build:
   - `Firebase` (Auth, Firestore, Storage, Messaging, etc.)
   - `SwiftfulRouting`
   - `SwiftfulRecursiveUI`
   - `stellarsdk` (Soneso Stellar iOS/macOS SDK)

5. **Run**:
   Select a simulator (e.g., iPhone 15) and press `Cmd + R`.

> **Stellar network**: The app currently targets the **Stellar testnet**. New user accounts are funded automatically via Friendbot. No real XLM is used.

## 🎨 Design System

- **Typography**: `Athletics`, `General Sans`, `SF Pro Rounded`
- **Colors**: Defined in `cuddleColor.swift` — primary gradients (`gradientLight`, `gradientDark`) and secondary status colors
