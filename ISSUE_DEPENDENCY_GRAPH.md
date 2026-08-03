# MatchMe Stellar — Issue Dependency Graph

> **How to use this document**
> Work top-to-bottom. Never start an issue until every issue it depends on is merged and closed.
> Each issue links to its GitHub tracker entry. For coding conventions and PR requirements before opening a pull request, see the [Contributing Guide](CONTRIBUTING.md).

---

## Layer 0 — Root Blockers
*These have no dependencies. They must be resolved first — everything Stellar is broken without them.*

```
┌─────────────────────────────────────────────────────────────────┐
│  #77  ISS-057  MatchAssetConfig issuer key is a fake placeholder │  ← START HERE
└──────────────────────────┬──────────────────────────────────────┘
                           │ unblocks
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    #76 ISS-056      #80 ISS-060     #22 ISS-022
    Reserve wallet   rewardLog rule  MATCH trustline ──► all Phase 2
    fix              in Firestore
```

| Issue | Title | GitHub |
|---|---|---|
| ISS-057 | MatchAssetConfig.defaultIssuerAccountId is a fake placeholder key | [#77](https://github.com/Que-Base/matchme_stellar/issues/77) |

---

## Layer 1 — Foundation Fixes
*No inter-dependencies. Can all be done in parallel once Layer 0 is underway.*

| Issue | Title | GitHub | Notes |
|---|---|---|---|
| ISS-056 | RewardService.distributeReward() sends payment to self | [#76](https://github.com/Que-Base/matchme_stellar/issues/76) | Needs ISS-057 first |
| ISS-060 | Firestore rules missing /rewardLog — de-duplication broken | [#80](https://github.com/Que-Base/matchme_stellar/issues/80) | Needs ISS-057 first |
| ISS-058 | StellarWalletView unreachable — publicKey never passed from Settings | [#78](https://github.com/Que-Base/matchme_stellar/issues/78) | Independent |
| ISS-064 | deleteAccount() partial failure / no reauthentication | [#84](https://github.com/Que-Base/matchme_stellar/issues/84) | Independent |
| ISS-065 | fetchUser() swallows errors — infinite loading state | [#85](https://github.com/Que-Base/matchme_stellar/issues/85) | Independent |
| ISS-067 | signOut() error silently swallowed | [#87](https://github.com/Que-Base/matchme_stellar/issues/87) | Independent |
| ISS-068 | getOrCreateKeypair() Keychain failure silently ignored | [#88](https://github.com/Que-Base/matchme_stellar/issues/88) | Independent |
| ISS-069 | StellarWalletServiceTests tearDown() race condition | [#89](https://github.com/Que-Base/matchme_stellar/issues/89) | Independent — do early |
| ISS-063 | ProfileView "Tab 1" / "Tab 2" placeholder labels | [#83](https://github.com/Que-Base/matchme_stellar/issues/83) | Independent — cosmetic |
| ISS-062 | Settings Terms/Privacy rows navigate nowhere | [#82](https://github.com/Que-Base/matchme_stellar/issues/82) | Independent |
| ISS-073 | ExploreCardView no failure/loading state distinction | [#93](https://github.com/Que-Base/matchme_stellar/issues/93) | Independent — UX polish |

---

## Layer 2 — Core Feature Implementation
*Depend on Layer 1 foundations being stable. Most are independent of each other within this layer.*

```
ISS-051  like/pass → Firestore         ISS-053  fetchLikes → Firestore
    │                                       │
    ├──► ISS-052  fetchProfiles exclusion   └──► ISS-054  likeBack/pass → Firestore
    │                                                │
    └──────────────────────────────────────────────►┘
               (shared checkForMatch logic)
```

| Issue | Title | GitHub | Blocked by |
|---|---|---|---|
| ISS-051 | like() and pass() never write to Firestore | [#71](https://github.com/Que-Base/matchme_stellar/issues/71) | Nothing |
| ISS-053 | LikesViewModel.fetchLikes() unconditional empty stub | [#73](https://github.com/Que-Base/matchme_stellar/issues/73) | ISS-051 |
| ISS-055 | All Chat methods are stubs — messaging non-functional | [#75](https://github.com/Que-Base/matchme_stellar/issues/75) | ISS-051 (for match→conversation creation) |
| ISS-072 | ProfileViewModel.updateProfile() never called | [#92](https://github.com/Que-Base/matchme_stellar/issues/92) | Nothing |
| ISS-061 | Settings toggles not persisted | [#81](https://github.com/Que-Base/matchme_stellar/issues/81) | Nothing |
| ISS-074 | StellarWalletView 'Loading...' permanent on failure | [#94](https://github.com/Que-Base/matchme_stellar/issues/94) | ISS-058 |
| ISS-059 | TransactionHistoryView link broken via SwiftfulRouting | [#79](https://github.com/Que-Base/matchme_stellar/issues/79) | ISS-058 |

---

## Layer 3 — Depends on Layer 2

| Issue | Title | GitHub | Blocked by |
|---|---|---|---|
| ISS-052 | fetchProfiles() excludes no already-seen UIDs | [#72](https://github.com/Que-Base/matchme_stellar/issues/72) | ISS-051 |
| ISS-054 | LikesViewModel likeBack/pass never write to Firestore | [#74](https://github.com/Que-Base/matchme_stellar/issues/74) | ISS-051 + ISS-053 |
| ISS-066 | Stellar wallet creation failure recovery | [#86](https://github.com/Que-Base/matchme_stellar/issues/86) | ISS-058 + ISS-065 |

---

## Layer 4 — Tests
*Write tests after the features they cover are implemented.*

| Issue | Title | GitHub | Blocked by |
|---|---|---|---|
| ISS-070 | No tests for RewardService | [#90](https://github.com/Que-Base/matchme_stellar/issues/90) | ISS-057, ISS-056, ISS-060, ISS-069 |
| ISS-071 | No tests for Explore/Likes/Chat ViewModels | [#91](https://github.com/Que-Base/matchme_stellar/issues/91) | ISS-051, ISS-052, ISS-053, ISS-054, ISS-055 |

---

## Layer 5 — Stellar Phase 3 (Soroban Smart Contracts)
*Entire layer blocked on Phase 2 being correct and live.*

```
Phase 2 complete (ISS-057 → ISS-022/023/024/025/026)
    │
    ▼
ISS-027  Subscription contract ──► ISS-028  Date escrow ──► ISS-029  NFT badges
```

| Issue | Title | GitHub | Blocked by |
|---|---|---|---|
| ISS-027 | Subscription smart contract | [#27](https://github.com/Que-Base/matchme_stellar/issues/27) | All of Phase 2 |
| ISS-028 | Date escrow contract | [#28](https://github.com/Que-Base/matchme_stellar/issues/28) | ISS-027 |
| ISS-029 | NFT profile badges contract | [#29](https://github.com/Que-Base/matchme_stellar/issues/29) | ISS-027 + ISS-028 |

---

## Layer 6 — Stellar Phase 4 (Mainnet)
*Blocked on Phase 3 being stable on testnet.*

| Issue | Title | GitHub | Blocked by |
|---|---|---|---|
| ISS-030 | Mainnet switch / no testnet hardcoding | [#30](https://github.com/Que-Base/matchme_stellar/issues/30) | ISS-027, ISS-028, ISS-029 |
| ISS-031 | Seed phrase backup / wallet recovery | [#31](https://github.com/Que-Base/matchme_stellar/issues/31) | ISS-030 |

---

## Layer 7 — Stellar Phase 5 (DID)
*Final layer — blocked on everything prior.*

| Issue | Title | GitHub | Blocked by |
|---|---|---|---|
| ISS-033 | Decentralised identity (DID) layer | [#32](https://github.com/Que-Base/matchme_stellar/issues/32) | ISS-031 + all prior phases |

---

## Full Execution Order (recommended)

```
 1.  #77  ISS-057  Real MATCH issuer key                ← root blocker
 2.  #76  ISS-056  Fix reserve wallet in RewardService
 3.  #80  ISS-060  Add /rewardLog to Firestore rules
 4.  #78  ISS-058  Pass publicKey to StellarWalletView
 5.  #84  ISS-064  deleteAccount reauthentication
 6.  #85  ISS-065  fetchUser error handling
 7.  #89  ISS-069  Fix tearDown() race in tests
 8.  #71  ISS-051  like/pass write to Firestore          ← highest value feature work
 9.  #73  ISS-053  fetchLikes real Firestore data
10.  #75  ISS-055  Chat Firestore implementation
11.  #72  ISS-052  fetchProfiles exclusion (needs #8)
12.  #74  ISS-054  likeBack/pass Firestore (needs #8+#9)
13.  #92  ISS-072  Profile edit flow / updateProfile()
14.  #86  ISS-066  Wallet creation failure recovery
15.  #90  ISS-070  RewardService tests
16.  #91  ISS-071  ViewModel tests
17.  #87  ISS-067  signOut error handling
18.  #88  ISS-068  Keychain error handling
19.  #82  ISS-062  Settings Terms/Privacy SafariView
20.  #81  ISS-061  Settings toggles persisted
21.  #79  ISS-059  TransactionHistoryView NavigationLink
22.  #94  ISS-074  StellarWalletView error/retry state
23.  #83  ISS-063  Profile placeholder tab labels
24.  #93  ISS-073  ExploreCardView shimmer states
25.  #27  ISS-027  Subscription smart contract          ← Phase 3
26.  #28  ISS-028  Date escrow contract
27.  #29  ISS-029  NFT profile badges
28.  #30  ISS-030  Mainnet switch                       ← Phase 4
29.  #31  ISS-031  Seed phrase backup
30.  #32  ISS-033  DID layer                            ← Phase 5
```

---

## References

| Document | Purpose |
|---|---|
| [CONTRIBUTING.md](CONTRIBUTING.md) | Code conventions, PR requirements, build/test commands |
| [ISSUES.md](ISSUES.md) | Full issue tracker with descriptions and sub-task breakdowns |
| [STELLAR_ARCHITECTURE.md](STELLAR_ARCHITECTURE.md) | Keypair generation, Keychain access, Horizon integration |
| [STELLAR_ROADMAP.md](STELLAR_ROADMAP.md) | Multi-phase Stellar feature breakdown |
| [SECURITY.md](SECURITY.md) | Vulnerability reporting and key storage model |
