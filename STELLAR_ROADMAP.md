# MatchMe — Stellar Roadmap

Full roadmap for the Stellar blockchain integration in MatchMe. Phases build on each other — each phase is a prerequisite for the next.

---

## Phase 1 — Wallet & Identity ✅ Complete

The foundation. Every user gets a non-custodial Stellar wallet at signup.

| Feature | Status | Details |
|---|---|---|
| Ed25519 keypair generation | ✅ | Generated on-device at signup via `stellarsdk` |
| Keychain storage | ✅ | Secret seed stored with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` |
| Testnet funding | ✅ | Friendbot credits 10,000 XLM automatically |
| Public key → Firestore | ✅ | `stellarPublicKey` field on `User` struct, persisted to `users/{uid}` |
| Live XLM balance | ✅ | `StellarWalletView` queries Horizon on appear |
| Non-custodial model | ✅ | MatchMe never holds or transmits private keys |

---

## Phase 2 — MATCH Token Economy 🔜

Issue a custom Stellar asset `MATCH` and wire it into core app interactions. Users earn tokens for positive engagement and spend them on premium actions.

### 2a. Token Issuance

- Create a MatchMe-controlled issuer account on Stellar mainnet
- Issue `MATCH` asset (code: `MATCH`, issuer: MatchMe account)
- Set asset home domain and publish `stellar.toml` for discoverability
- Lock issuer account after initial supply to make supply fixed (optional)

### 2b. Trustlines

Users must opt in to hold `MATCH` before receiving it. This happens automatically on first earn event.

```
User earns first MATCH reward
        │
        ▼
StellarWalletService.addTrustline(asset: MATCH)
  → submits ChangeTrust operation
        │
        ▼
MatchMe backend sends MATCH payment to user
```

### 2c. Earn Events

| User Action | MATCH Earned |
|---|---|
| Complete profile (bio + photo) | +50 MATCH |
| First match | +100 MATCH |
| Daily login | +5 MATCH |
| Received a like | +10 MATCH |
| Profile verified | +200 MATCH |

### 2d. Spend Events

| Action | MATCH Cost |
|---|---|
| Send a super like | 20 MATCH |
| Tip another user (min) | 10 MATCH |
| Boost profile visibility (24h) | 100 MATCH |
| Unlock premium message | 15 MATCH |

### 2e. Peer-to-Peer Tipping

Users can send XLM or MATCH directly to a match's Stellar account — no intermediary, near-instant settlement.

```swift
// Planned API
StellarWalletService.shared.sendPayment(
    to: recipientPublicKey,
    asset: .match,
    amount: "10"
)
```

### 2f. New Service Methods Needed

| Method | Description |
|---|---|
| `addTrustline(asset:)` | Submit ChangeTrust op for MATCH asset |
| `sendPayment(to:asset:amount:)` | Submit Payment op (XLM or MATCH) |
| `matchBalance(for:)` | Query MATCH balance from Horizon |
| `transactionHistory(for:)` | Fetch recent payments from Horizon |

---

## Phase 3 — Soroban Smart Contracts 🔜

Deploy Rust-based smart contracts on Stellar's Soroban platform for trustless, on-chain business logic.

### 3a. Subscription Contract

Replaces Firebase-based subscription gating with tamper-proof on-chain state.

**Flow:**
```
User pays MATCH → Subscription contract
        │
        ▼
Contract records: { user: G..., tier: "premium", expiresAt: timestamp }
        │
        ▼
App queries contract state → gates features accordingly
```

**Benefits over Firebase:**
- Subscription state is publicly verifiable
- Cannot be manipulated server-side
- User retains proof of subscription independent of MatchMe

**Contract interface (Rust/Soroban):**
```rust
fn subscribe(env: Env, user: Address, tier: Symbol, duration_days: u32);
fn is_active(env: Env, user: Address) -> bool;
fn expiry(env: Env, user: Address) -> u64;
```

---

### 3b. Escrow Contract — "Verified Date"

Both users stake a small amount of XLM before a date. Mutual confirmation returns stakes; a no-show forfeits their stake to the other party. Incentivises respectful behaviour and reduces ghosting.

**Flow:**
```
User A stakes 1 XLM ──┐
                       ├──▶ Escrow Contract
User B stakes 1 XLM ──┘         │
                                 ├──▶ Both confirm → full refund to each
                                 ├──▶ A no-shows   → B gets A's stake
                                 └──▶ Dispute      → MatchMe arbitration key
```

**Contract interface:**
```rust
fn create_escrow(env: Env, user_a: Address, user_b: Address, amount: i128);
fn confirm(env: Env, user: Address, escrow_id: u64);
fn claim_noshow(env: Env, claimant: Address, escrow_id: u64);
```

---

### 3c. NFT Profile Badges

On-chain achievement badges minted as Soroban tokens. Badges are owned by the user's Stellar account — portable and permanent even if they leave MatchMe.

| Badge | Trigger |
|---|---|
| 🌟 First Match | First mutual match |
| 💬 Conversationalist | 50 messages sent |
| ❤️ 100 Likes | Received 100 likes |
| ✅ Verified Human | Identity verification passed |
| 👑 Premium Member | Active premium subscription |
| 🗓 Date Verified | Completed a Verified Date escrow |

**Contract interface:**
```rust
fn mint_badge(env: Env, recipient: Address, badge_type: Symbol);
fn badges_of(env: Env, user: Address) -> Vec<Symbol>;
fn has_badge(env: Env, user: Address, badge_type: Symbol) -> bool;
```

---

## Phase 4 — Mainnet & On-Ramp 🔜

Move from testnet to Stellar mainnet and provide users a way to acquire XLM/MATCH.

| Feature | Details |
|---|---|
| Switch to `StellarSDK.publicNet()` | One-line change in `StellarWalletService` |
| Remove Friendbot funding | Replace with on-ramp flow |
| MoneyGram Ramps integration | Fiat → XLM via SEP-6/SEP-24 anchor protocol |
| In-app purchase → MATCH | Apple IAP triggers MATCH distribution from reserve |
| Wallet backup / recovery | Seed phrase export flow with user education |
| Transaction history view | Full payment history from Horizon |

---

## Phase 5 — Decentralised Identity (DID) 🔜

Use Stellar keypairs as the basis for a verifiable, self-sovereign identity layer.

| Feature | Details |
|---|---|
| Profile attestations | Third-party verifiers sign claims (e.g. "verified photo") anchored to user's public key |
| Cross-app portability | User's verified identity travels with their Stellar account |
| SEP-10 Web Auth | Prove account ownership to anchors and third-party services without a password |
| Privacy-preserving proofs | ZK proofs on Stellar for age/location verification without revealing raw data |

---

## Implementation Priority

```
Phase 1 ──▶ Phase 2a/2b ──▶ Phase 2c/2d ──▶ Phase 2e
                                                │
                                                ▼
                                          Phase 3a (Subscriptions)
                                                │
                                                ▼
                                          Phase 3b (Escrow)
                                                │
                                                ▼
                                          Phase 3c (Badges)
                                                │
                                                ▼
                                          Phase 4 (Mainnet)
                                                │
                                                ▼
                                          Phase 5 (DID)
```

---

## Resources

- [Soneso stellar-ios-mac-sdk](https://github.com/Soneso/stellar-ios-mac-sdk)
- [Stellar Asset Issuance](https://developers.stellar.org/docs/tokens/how-to-issue-an-asset)
- [Soroban Smart Contracts](https://developers.stellar.org/docs/build/smart-contracts)
- [SEP-10 Web Authentication](https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0010.md)
- [MoneyGram Ramps (SEP-6/24)](https://developers.stellar.org/docs/tools/ramps/moneygram)
- [Stellar Community Fund](https://communityfund.stellar.org) — grants up to $100k for qualifying projects
