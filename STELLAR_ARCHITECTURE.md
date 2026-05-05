# MatchMe — Stellar Integration Architecture

## Overview

MatchMe integrates the [Stellar blockchain](https://stellar.org) to power a decentralised identity and token economy layer on top of the existing Firebase backend. Every user gets a non-custodial Stellar wallet at signup. The wallet is the foundation for all on-chain features: token rewards, peer-to-peer tipping, premium subscriptions, and verifiable profile badges.

The integration uses the [Soneso Stellar iOS/macOS SDK](https://github.com/Soneso/stellar-ios-mac-sdk) (`stellarsdk`), added as a Swift Package Manager dependency alongside Firebase and SwiftfulRouting.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        MatchMe iOS App                          │
│                                                                 │
│  ┌──────────────┐    ┌──────────────────┐    ┌──────────────┐  │
│  │ AuthViewModel│───▶│StellarWalletSvc  │───▶│  Keychain    │  │
│  │  (MVVM)      │    │  (Singleton)     │    │ (Secret Seed)│  │
│  └──────┬───────┘    └────────┬─────────┘    └──────────────┘  │
│         │                    │                                  │
│         ▼                    ▼                                  │
│  ┌──────────────┐    ┌──────────────────┐                       │
│  │  User Model  │    │  stellarsdk      │                       │
│  │ +publicKey   │    │  (Soneso SDK)    │                       │
│  └──────┬───────┘    └────────┬─────────┘                       │
│         │                    │                                  │
└─────────┼────────────────────┼─────────────────────────────────┘
          │                    │
          ▼                    ▼
   ┌─────────────┐    ┌────────────────────────────────┐
   │  Firestore  │    │       Stellar Network           │
   │  (users/    │    │                                │
   │  publicKey) │    │  ┌──────────┐  ┌────────────┐  │
   └─────────────┘    │  │ Horizon  │  │ Friendbot  │  │
                      │  │  (API)   │  │ (Testnet)  │  │
                      │  └──────────┘  └────────────┘  │
                      │                                │
                      │  ┌──────────────────────────┐  │
                      │  │   Soroban (Smart          │  │
                      │  │   Contracts — Planned)    │  │
                      │  └──────────────────────────┘  │
                      └────────────────────────────────┘
```

---

## Current Implementation (Phase 1)

### 1. Dependency

Added to `matchme.mobile_swift.xcodeproj` via Swift Package Manager:

| Package | URL | Version |
|---|---|---|
| `stellarsdk` | `https://github.com/Soneso/stellar-ios-mac-sdk.git` | `>= 2.5.0` |

### 2. `StellarWalletService` — `models/StellarWalletService.swift`

The single point of contact between the app and the Stellar network. Implemented as a singleton (`StellarWalletService.shared`).

| Method | Description |
|---|---|
| `getOrCreateKeypair()` | Loads keypair from Keychain, or generates a new Ed25519 keypair and persists the secret seed |
| `fundTestnetAccount(publicKey:)` | Calls Friendbot to fund the account with 10,000 XLM on testnet |
| `xlmBalance(for:)` | Queries Horizon for the account's native XLM balance |

**Key security decisions:**
- Secret seed stored in Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` — never leaves the device, never written to Firestore or any remote store
- Only the **public key** is stored in Firestore and shared with other users
- The app is **non-custodial**: MatchMe never has access to user funds

### 3. `User` Model — `models/userModel.swift`

```swift
struct User: Identifiable, Codable {
    let id: String           // Firebase UID
    let fullname: String
    let email: String
    var stellarPublicKey: String?   // Stellar G... address, stored in Firestore
}
```

### 4. Signup Flow — `AuthViewModel.createUser`

```
User submits signup form
        │
        ▼
Firebase Auth.createUser()
        │
        ▼
StellarWalletService.getOrCreateKeypair()
  → generates Ed25519 keypair
  → saves secret seed to Keychain
        │
        ▼
StellarWalletService.fundTestnetAccount()
  → Friendbot credits 10,000 XLM (testnet)
        │
        ▼
Firestore: users/{uid} { stellarPublicKey: "G..." }
        │
        ▼
AuthViewModel.fetchUser() → currentUser populated
```

### 5. `StellarWalletView` — `views/StellarWalletView.swift`

A reusable SwiftUI card component. Embed anywhere a user's wallet info is needed:

```swift
if let key = currentUser.stellarPublicKey {
    StellarWalletView(publicKey: key)
}
```

Displays:
- Truncated public key (selectable for copy)
- Live XLM balance fetched from Horizon on appear

---

## Planned Implementation (Phase 2 & 3)

### Phase 2 — MATCH Token Economy

Issue a custom Stellar asset `MATCH` (issuer account controlled by MatchMe).

| Event | Token Flow |
|---|---|
| Profile completed | +50 MATCH earned |
| Received a like | +10 MATCH earned |
| Sent a super like | −20 MATCH spent |
| Tipped another user | User-defined XLM/MATCH sent |
| Unlocked premium feature | −MATCH spent |

**Implementation:**
- `StellarWalletService.addTrustline(asset:)` — user opts in to MATCH asset
- `StellarWalletService.sendPayment(to:asset:amount:)` — peer-to-peer transfers
- `StellarWalletService.matchBalance(for:)` — fetch MATCH balance from Horizon

### Phase 3 — Soroban Smart Contracts

Three contracts planned, written in Rust and deployed to Stellar's Soroban platform:

#### 3a. Subscription Contract
Replaces Firebase-based subscription logic with on-chain state.
```
User pays MATCH → Contract verifies → Sets expiry timestamp on-chain
App queries contract → Gates premium features
```

#### 3b. Escrow Contract ("Verified Date")
Both users stake XLM before a date. Mutual confirmation returns stakes; no-show forfeits.
```
User A stakes 1 XLM ──┐
                       ├──▶ Escrow Contract ──▶ Both confirm → refund
User B stakes 1 XLM ──┘                     └──▶ No-show → other party gets stake
```

#### 3c. Badge / NFT Contract
On-chain achievement badges minted as Soroban tokens.
```
Milestone reached → App calls contract → Badge minted to user's Stellar account
Badge is portable — user owns it independent of MatchMe
```

---

## File Structure

```
matchme.mobile_swift/
├── models/
│   ├── userModel.swift              # User struct + stellarPublicKey field
│   ├── AuthViewModel.swift          # Keypair generation wired into createUser
│   └── StellarWalletService.swift   # All Stellar network interactions
└── views/
    └── StellarWalletView.swift      # Wallet card UI component
```

---

## Network Configuration

| Environment | Network | Horizon URL | Friendbot |
|---|---|---|---|
| Development / Testnet | `testNet()` | `https://horizon-testnet.stellar.org` | Available |
| Production | `publicNet()` | `https://horizon.stellar.org` | Not available |

To switch to mainnet, change `StellarWalletService`:
```swift
// Testnet (current)
private let sdk = StellarSDK.testNet()

// Mainnet (production)
private let sdk = StellarSDK.publicNet()
```

> ⚠️ On mainnet, `fundTestnetAccount()` must be removed. Users will need to fund their account via an on-ramp (e.g. MoneyGram Ramps, exchange transfer, or in-app purchase flow).

---

## Security Model

| Asset | Storage | Access |
|---|---|---|
| Secret seed (private key) | iOS Keychain (`WhenUnlockedThisDeviceOnly`) | Device only, never transmitted |
| Public key | Firestore `users/{uid}.stellarPublicKey` | Readable by other users |
| XLM / MATCH balance | Stellar Horizon (public ledger) | Publicly queryable |
| Firebase UID ↔ Public key mapping | Firestore | App-level read rules apply |

The app is **non-custodial**. MatchMe holds no private keys and cannot move user funds.

---

## SDK References

- [Soneso stellar-ios-mac-sdk](https://github.com/Soneso/stellar-ios-mac-sdk)
- [Stellar Horizon API](https://developers.stellar.org/docs/data/apis/horizon)
- [Soroban Smart Contracts](https://developers.stellar.org/docs/build/smart-contracts)
- [Stellar Testnet Friendbot](https://friendbot.stellar.org)
- [SwiftBasicPay — Reference iOS App](https://github.com/Soneso/SwiftBasicPay)
