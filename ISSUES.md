# MatchMe Stellar — Issue Tracker

> **Last updated:** 2026-08-03
> **Repo:** https://github.com/Que-Base/matchme_stellar
> **Project:** MatchMe iOS (Swift / SwiftUI / Firebase / Stellar)

---

## Tag Legend

| Tag | Meaning |
|---|---|
| `[bug]` | Incorrect behaviour or broken code |
| `[missing]` | Feature/screen that does not exist yet |
| `[stub]` | File or function exists but has no real implementation |
| `[security]` | Security vulnerability or unsafe practice |
| `[arch]` | Architectural or structural design problem |
| `[ux]` | User-facing experience gap or friction |
| `[stellar]` | Related to Stellar / blockchain integration |
| `[firebase]` | Related to Firebase Auth / Firestore |
| `[ui]` | Visual / layout defect |
| `[tech-debt]` | Code quality, naming, or maintainability issue |
| `[blocking]` | Blocks other work from being started |

## Status Legend

| Status | Meaning |
|---|---|
| 🔴 **OPEN** | Not started |
| 🟡 **IN PROGRESS** | Actively being worked on |
| 🟢 **CLOSED** | Complete and verified |
| ⏸ **PENDING** | Waiting on a dependency or decision |

---

## Dashboard Summary

| Area | Open | In Progress | Pending | Closed |
|---|---|---|---|---|
| Authentication | 0 | 0 | 0 | 7 |
| Core Views (Stubs) | 0 | 0 | 0 | 4 |
| Profile | 2 | 0 | 0 | 4 |
| Stellar — Phase 1 | 0 | 0 | 0 | 6 |
| Stellar — Phase 2 | 2 | 0 | 0 | 3 |
| Stellar — Phase 3 | 0 | 0 | 3 | 0 |
| Stellar — Phase 4/5 | 0 | 0 | 4 | 0 |
| Security | 0 | 0 | 0 | 4 |
| Architecture | 0 | 0 | 0 | 4 |
| UI / UX | 0 | 0 | 0 | 4 |
| Tech Debt | 0 | 0 | 0 | 5 |
| Post-Audit (ISS-051–074) | 24 | 0 | 0 | 0 |
| **Total** | **28** | **0** | **7** | **41** |

---

---

## Section 1 — Authentication

### ISS-001 · Sign-in function is empty
**Status:** 🟢 CLOSED — implemented in PR #7 (`fix/iss-001-sign-in-function`)  
**Tags:** `[stub]` `[firebase]` `[blocking]`  
**File:** `models/AuthViewModel.swift` → `signIn(withEmail:password:)`

The function signature exists but the body is completely empty. No user who created an account can sign back in — they are permanently locked out after their session expires.

**Breakdown:**
- Call `Auth.auth().signIn(withEmail:password:)` and capture the result
- Set `self.userSession` from the result
- Call `await fetchUser()` to populate `currentUser`
- Handle and surface errors to the caller

---

### ISS-002 · Sign-out function is empty
**Status:** 🟢 CLOSED — implemented in PR #8 (`fix/iss-002-sign-out-function`)  
**Tags:** `[stub]` `[firebase]` `[security]`  
**File:** `models/AuthViewModel.swift` → `signOut()`

`signOut()` has no body. There is no way to log out of the app. This is also a security concern on shared devices.

**Breakdown:**
- Call `try Auth.auth().signOut()`
- Nil out `self.userSession` and `self.currentUser`
- Reset `self.authState` to `.notAuthenticated`

---

### ISS-003 · Delete account function is empty
**Status:** 🟢 CLOSED — implemented in PR #9 (`fix/iss-003-delete-account`)  
**Tags:** `[stub]` `[firebase]` `[security]`  
**File:** `models/AuthViewModel.swift` → `deleteAccount()`

`deleteAccount()` has no body. Users have no way to exercise data deletion rights (required under GDPR/App Store guidelines).

**Breakdown:**
- Re-authenticate the user before deletion (Firebase requires recent auth)
- Delete Firestore document at `users/{uid}`
- Call `Auth.auth().currentUser?.delete()`
- Nil out local session state
- Consider: Stellar keypair in Keychain should also be cleared

---

### ISS-004 · No sign-in view exists
**Status:** 🟢 CLOSED — implemented in PR #10 (`fix/iss-004-sign-in-view`)  
**Tags:** `[missing]` `[ux]` `[blocking]`  
**Files:** `views/Auth_view/` — no `SignInView.swift`

`OnboardingView` has a "Log in" button that calls an empty action `{}`. There is no `SignInView` at all. Returning users cannot authenticate.

**Breakdown:**
- Create `SignInView.swift` in `views/Auth_view/`
- Fields: email, password (SecureField)
- Wire to `AuthViewModel.signIn()`
- Add navigation from the "Log in" button in `OnboardingView`
- Handle "Forgot password?" via `Auth.auth().sendPasswordReset()`

---

### ISS-005 · Auth state listener is never called
**Status:** 🟢 CLOSED — implemented in PR #11 (`fix/iss-005-auth-listener`)  
**Tags:** `[bug]` `[firebase]` `[arch]`  
**File:** `models/AuthViewModel.swift` → `listenToAuthStateChanges()`

The method is defined but never invoked. `startUp()` manually reads `Auth.auth().currentUser` once at launch but does not subscribe to ongoing auth state changes. If a session is revoked or expires mid-use, the app will not react.

**Breakdown:**
- Call `listenToAuthStateChanges()` from `startUp()`
- Fix the logic inside the listener: currently checks `self.userSession != nil` before checking the `user` parameter — the order should be reversed and `self.userSession` should be set from the listener's `user` argument
- Ensure the listener is retained (store the handle as a property)

---

### ISS-006 · Auth routing race condition in ContentView
**Status:** 🟢 CLOSED — implemented in PR #12 (`fix/iss-006-auth-routing`)  
**Tags:** `[bug]` `[arch]` `[ux]`  
**File:** `ContentView.swift`

Two separate conditions gate the root view — `currentUser != nil` takes priority over `authState`. During startup, `authState` may still be `.undifined` while `fetchUser()` is in-flight, causing `OnboardingView` to flash before `DashboardView` appears.

**Breakdown:**
- Consolidate routing into a single source of truth (either `authState` or `currentUser`, not both)
- Show a loading/splash view while `authState == .undifined`
- Only route to `DashboardView` once both `authState == .authenticated` AND `currentUser != nil`

---

### ISS-007 · Firebase Auth and Stellar wallet created successfully at signup
**Status:** 🟢 CLOSED  
**Tags:** `[firebase]` `[stellar]`  
**File:** `models/AuthViewModel.swift` → `createUser()`

Firebase user creation, Stellar keypair generation, Friendbot funding, and Firestore persistence are all correctly wired together in the signup flow.

---

---

## Section 2 — Core Views (Stubs)

These are the four main tab views. All are navigation placeholders with no real content.

### ISS-008 · ExploreView is a placeholder
**Status:** 🟢 CLOSED — stub implemented in PR #50 (`fix/iss-008-explore-view-stubs`)  
**Tags:** `[stub]` `[missing]` `[blocking]`  
**File:** `views/Explore/exploreView.swift`

The entire view body is `Text("Explore view")`. This is the app's primary discovery feature.

**Breakdown:**
- **ISS-008a** · Fetch user list from Firestore (excluding self, already-liked, already-passed)
- **ISS-008b** · Build swipeable card stack UI (swipe right = like, swipe left = pass)
- **ISS-008c** · Implement drag gesture recogniser with spring animation
- **ISS-008d** · Show user card: photo, name, age, occupation, interests preview
- **ISS-008e** · Action buttons: Pass, Super Like, Like
- **ISS-008f** · Handle empty state (no more profiles to show)
- **ISS-008g** · Persist like/pass decisions to Firestore
- **ISS-008h** · Detect mutual like → trigger match event

---

### ISS-009 · LikeView is a placeholder
**Status:** 🟢 CLOSED — stub implemented in PR #51 (`fix/iss-009-like-view-stubs`)  
**Tags:** `[stub]` `[missing]`  
**File:** `views/Likes/likeView.swift`

The view body still contains the Xcode default placeholder comment (`@START_MENU_TOKEN@`). No content exists.

**Breakdown:**
- **ISS-009a** · Query Firestore for users who have liked the current user
- **ISS-009b** · Display a grid or list of profile cards of people who liked you
- **ISS-009c** · Tap to view full profile
- **ISS-009d** · Option to like back (triggers a match) or pass
- **ISS-009e** · Show empty state when no likes yet
- **ISS-009f** · (Phase 2) Blur liked profiles behind a MATCH token paywall for non-premium

---

### ISS-010 · ChatView is a placeholder
**Status:** 🟢 CLOSED — stub implemented in PR #52 (`fix/iss-010-chat-view-stubs`)  
**Tags:** `[stub]` `[missing]`  
**File:** `views/Chats/chatView.swift`

The view body is `Text("Chat View")` with a navigation title. No messaging functionality exists.

**Breakdown:**
- **ISS-010a** · Create `Conversation` model and Firestore collection (`conversations/{id}`)
- **ISS-010b** · Create `Message` model (`messages` subcollection)
- **ISS-010c** · Build conversation list view (matched users with last message preview)
- **ISS-010d** · Build individual chat screen with message bubbles
- **ISS-010e** · Real-time listener via Firestore `addSnapshotListener`
- **ISS-010f** · Message send action writes to Firestore
- **ISS-010g** · Timestamps, read receipts (optional)
- **ISS-010h** · (Phase 2) "Tip" button in chat header to send MATCH tokens

---

### ISS-011 · SettingsView is nearly empty
**Status:** 🟢 CLOSED — stub implemented in PR #53 (`fix/iss-011-settings-view-stubs`)  
**Tags:** `[stub]` `[missing]` `[ux]`  
**File:** `views/Settings/settingsView.swift`

Only one item exists ("Connect social media account") and its `NavigationLink(destination: {})` goes nowhere. Sign out, account deletion, notifications, and privacy settings are all absent.

**Breakdown:**
- **ISS-011a** · Sign out row — calls `AuthViewModel.signOut()`
- **ISS-011b** · Delete account row — calls `AuthViewModel.deleteAccount()` with confirmation alert
- **ISS-011c** · Notification preferences toggle
- **ISS-011d** · Privacy settings (who can see my profile, distance)
- **ISS-011e** · Connect social media — wire to actual OAuth flow
- **ISS-011f** · Stellar Wallet row — navigate to `StellarWalletView`
- **ISS-011g** · App version / legal links (Terms, Privacy Policy)

---

---

## Section 3 — Profile

### ISS-012 · ProfileView uses hardcoded mock data, not real Firebase user
**Status:** 🔴 OPEN  
**Tags:** `[bug]` `[arch]` `[firebase]`  
**File:** `views/Profile/profileView.swift`, `views/Profile/models/profileViewModel.swift`

`ProfileView` creates `ProfileViewModel.jostevModel(...)` with hardcoded values ("Josteve Amshatir", "Product Designer", mock images). The `AuthViewModel.currentUser` from the environment is never read. Profile data shown is always fake.

**Breakdown:**
- **ISS-012a** · Pass `AuthViewModel` environment object into `ProfileView`
- **ISS-012b** · Map `User` model fields onto `ProfileViewModel` (or replace with direct binding)
- **ISS-012c** · Expand `User` struct in `userModel.swift` to include: `bio`, `occupation`, `age`, `interests: [String]`, `photoURLs: [String]`
- **ISS-012d** · Update `AuthViewModel.createUser` to write expanded fields to Firestore
- **ISS-012e** · Fetch expanded profile on `fetchUser()`

---

### ISS-013 · Profile photos show mock images, no upload capability
**Status:** 🔴 OPEN  
**Tags:** `[stub]` `[missing]` `[firebase]`  
**File:** `views/Profile/profilePhotosView.swift`

`ProfilePhotosView` hardcodes `["mock_cat", "mock_cat"]` as photo paths. There is no photo picker, no Firebase Storage upload, and no URL persistence.

**Breakdown:**
- **ISS-013a** · Integrate `PhotosUI` / `PHPickerViewController` for photo selection
- **ISS-013b** · Upload selected images to Firebase Storage at `users/{uid}/photos/{filename}`
- **ISS-013c** · Persist download URLs to Firestore on the user document
- **ISS-013d** · Load remote images with `AsyncImage` or a caching library
- **ISS-013e** · Delete / reorder photos
- **ISS-013f** · Enforce minimum 1 photo, maximum 6 photos

---

### ISS-014 · Profile setup view is disconnected from auth flow
**Status:** 🔴 OPEN  
**Tags:** `[arch]` `[ux]` `[stub]`  
**File:** `views/Onboarding_flow_view/profileSetupView.swift`

`ProfileSetupView` exists and collects name and job title, but it is never navigated to after signup and its data is never persisted to Firestore. New users go straight to the dashboard with an empty profile.

**Breakdown:**
- **ISS-014a** · Navigate to `ProfileSetupView` immediately after `createUser` completes
- **ISS-014b** · Wire text fields to write bio, occupation, and age to Firestore on "All good"
- **ISS-014c** · Add additional onboarding steps: interests selection, photo upload
- **ISS-014d** · Track `profileSetupCompletion` progress dynamically based on filled fields
- **ISS-014e** · Gate dashboard access until minimum required fields are complete

---

### ISS-015 · "Complete my profile" button has no action
**Status:** 🔴 OPEN  
**Tags:** `[stub]` `[ux]`  
**File:** `views/Profile/profileInfoView.swift` → `CuddleProfileInfoView`

The "Complete my profile" button renders when `profileSetupCompletion < 1.0` but its action is an empty closure `{}`. Tapping it does nothing.

**Breakdown:**
- Wire button action to navigate to `ProfileSetupView`
- Pass current profile completion state so the setup view can resume from where the user left off

---

---

## Section 4 — Stellar Integration

### Phase 1 — Wallet & Identity

#### ISS-016 · StellarWalletView is never surfaced in the app UI
**Status:** 🟢 CLOSED — navigation wired in PR #53 (`fix/iss-011-settings-view-stubs`); Stellar Wallet row in SettingsView pushes StellarWalletView via router  
**Tags:** `[missing]` `[stellar]` `[ux]`  
**File:** `views/StellarWalletView.swift`

The wallet card component is fully built but never rendered anywhere in the app. Users have no way to see their public key or XLM balance.

**Breakdown:**
- Add `StellarWalletView` to `ProfileView` (tab 2 — premium/features section)
- Or add a dedicated wallet row in `SettingsView` (ISS-011f)
- Guard with `if let key = currentUser.stellarPublicKey`

---

#### ISS-017 · Ed25519 keypair generation at signup ✅
**Status:** 🟢 CLOSED — `StellarWalletService.getOrCreateKeypair()` implemented and wired into `createUser`.

#### ISS-018 · Keychain secret seed storage ✅
**Status:** 🟢 CLOSED — Stored with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. Non-custodial model confirmed.

#### ISS-019 · Testnet Friendbot funding ✅
**Status:** 🟢 CLOSED — `fundTestnetAccount()` called at signup. 10,000 XLM credited automatically.

#### ISS-020 · Public key persisted to Firestore ✅
**Status:** 🟢 CLOSED — `stellarPublicKey` field on `User` struct, written to `users/{uid}` at signup.

#### ISS-021 · Live XLM balance display ✅
**Status:** 🟢 CLOSED — `xlmBalance(for:)` queries Horizon. `StellarWalletView` fetches on `.task`.

---

### Phase 2 — MATCH Token Economy

### ISS-022 · MATCH asset trustline not implemented
**Status:** 🟢 CLOSED — implemented in branch `feat/iss-022-match-trustline`  
**Tags:** `[stellar]` `[missing]` `[blocking]`  
**File:** `models/StellarWalletService.swift`

Before a user can receive MATCH tokens, they must establish a trustline for the asset. No `addTrustline()` method exists.

**Breakdown:**
- **ISS-022a** · Define `MatchAsset` constant (asset code + issuer account)
- **ISS-022b** · Implement `addTrustline(asset:)` — build and submit a `ChangeTrustOperation`
- **ISS-022c** · Sign the transaction with the user's keypair from Keychain
- **ISS-022d** · Call automatically on first earn event if trustline not yet established
- **ISS-022e** · Handle already-exists error gracefully

---

### ISS-023 · Payment / transfer not implemented
**Status:** 🟢 CLOSED — implemented in branch `feat/iss-023-payment-transfer`  
**Tags:** `[stellar]` `[missing]`  
**File:** `models/StellarWalletService.swift`

No `sendPayment()` method exists. Neither peer-to-peer tipping nor backend reward distributions can be executed.

**Breakdown:**
- **ISS-023a** · Implement `sendPayment(to:asset:amount:)` — build `PaymentOperation`
- **ISS-023b** · Load sender's keypair from Keychain to sign the transaction
- **ISS-023c** · Fetch current sequence number from Horizon before submitting
- **ISS-023d** · Submit signed transaction envelope to Horizon
- **ISS-023e** · Return transaction hash on success; throw typed errors on failure
- **ISS-023f** · Handle insufficient balance, destination account not found, etc.

---

### ISS-024 · MATCH token balance query not implemented
**Status:** 🟢 CLOSED — implemented in branch `feat/iss-024-match-balance`  
**Tags:** `[stellar]` `[missing]`  
**File:** `models/StellarWalletService.swift`

`xlmBalance(for:)` exists but there is no equivalent for the MATCH asset.

**Breakdown:**
- Implement `matchBalance(for publicKey: String) async -> String?`
- Filter `response.balances` where `assetCode == "MATCH"` and `assetIssuer == MatchMe issuer`
- Display in `StellarWalletView` alongside XLM balance

---

### ISS-025 · Transaction history not implemented
**Status:** 🔴 OPEN  
**Tags:** `[stellar]` `[missing]`  
**File:** `models/StellarWalletService.swift`

No way to retrieve or display a user's on-chain payment history.

**Breakdown:**
- Implement `transactionHistory(for publicKey: String) async -> [PaymentRecord]`
- Create `PaymentRecord` model (amount, asset, direction, timestamp, counterparty)
- Build a `TransactionHistoryView` list screen
- Link from `StellarWalletView`

---

### ISS-026 · Earn/spend event triggers not implemented
**Status:** 🔴 OPEN  
**Tags:** `[stellar]` `[missing]` `[firebase]`  
**File:** Needs new `RewardService.swift`

No logic connects app events (match, like received, profile complete) to MATCH token distributions.

**Breakdown:**
- **ISS-026a** · Create `RewardService` to map app events → MATCH amounts (per roadmap table)
- **ISS-026b** · Trigger `+50 MATCH` when profile bio + photo both set
- **ISS-026c** · Trigger `+100 MATCH` on first mutual match
- **ISS-026d** · Trigger `+10 MATCH` when user receives a like
- **ISS-026e** · Trigger `+5 MATCH` on daily login (track last login in Firestore)
- **ISS-026f** · Deduct MATCH on super like (`-20`) and profile boost (`-100`)
- **ISS-026g** · Consider: backend Cloud Function to authorise distributions (prevents client-side spoofing)

---

---

### Phase 3 — Soroban Smart Contracts

> ⏸ All Phase 3 issues are **PENDING** on Phase 2 completion.

### ISS-027 · Subscription smart contract not built
**Status:** ⏸ PENDING (Phase 2 prerequisite)  
**Tags:** `[stellar]` `[missing]`

Replaces Firebase subscription gating with a Soroban contract that records on-chain subscription state.

**Breakdown:**
- **ISS-027a** · Write Rust/Soroban contract: `subscribe()`, `is_active()`, `expiry()`
- **ISS-027b** · Deploy contract to Stellar testnet
- **ISS-027c** · Add `StellarWalletService.invokeContract()` Swift wrapper
- **ISS-027d** · Replace Firebase premium flag checks with contract `is_active()` query
- **ISS-027e** · Handle contract upgrade / migration path

---

### ISS-028 · Date escrow contract not built
**Status:** ⏸ PENDING (Phase 2 prerequisite)  
**Tags:** `[stellar]` `[missing]`

Both users stake XLM before a date. Mutual confirmation refunds both; no-show forfeits stake to the other party.

**Breakdown:**
- **ISS-028a** · Write Rust/Soroban contract: `create_escrow()`, `confirm()`, `claim_noshow()`
- **ISS-028b** · Build "Verified Date" UI flow — propose, accept, confirm, dispute
- **ISS-028c** · Arbitration key setup for dispute resolution
- **ISS-028d** · Deploy and test on testnet

---

### ISS-029 · NFT profile badges contract not built
**Status:** ⏸ PENDING (Phase 2 prerequisite)  
**Tags:** `[stellar]` `[missing]`

On-chain achievement badges (First Match, 100 Likes, Verified Human, etc.) minted as Soroban tokens owned by the user's Stellar account.

**Breakdown:**
- **ISS-029a** · Write Rust/Soroban contract: `mint_badge()`, `badges_of()`, `has_badge()`
- **ISS-029b** · Define badge trigger conditions per roadmap table
- **ISS-029c** · Build badge display UI in `ProfileView`
- **ISS-029d** · Deploy and test on testnet

---

### Phase 4 — Mainnet & On-Ramp

### ISS-030 · App is testnet-only, no mainnet switch
**Status:** ⏸ PENDING (all prior phases)  
**Tags:** `[stellar]` `[missing]`  
**File:** `models/StellarWalletService.swift`

`StellarSDK.testNet()` is hardcoded. Switching to mainnet requires removing Friendbot and adding an on-ramp.

**Breakdown:**
- Replace `StellarSDK.testNet()` with `StellarSDK.publicNet()` behind a build flag
- Remove or disable `fundTestnetAccount()` on production builds
- Implement MoneyGram Ramps (SEP-6/SEP-24) on-ramp flow
- Apple IAP → MATCH distribution from reserve wallet

---

### ISS-031 · No seed phrase backup / recovery flow
**Status:** ⏸ PENDING (Phase 4)  
**Tags:** `[stellar]` `[missing]` `[ux]` `[security]`

Users have no way to back up or recover their Stellar wallet. If they lose their device, their wallet is permanently gone.

**Breakdown:**
- Design a secure seed phrase export screen (show 12/24 words)
- Require biometric auth before displaying
- Add user education about custody responsibility
- Add seed phrase import flow for account recovery

---

### ISS-032 · No transaction history view
**Status:** ⏸ PENDING (Phase 4)  
**Tags:** `[stellar]` `[missing]` `[ux]`

Users cannot see past payments, tips, or token movements. (Partially overlaps ISS-025.)

---

### ISS-033 · Decentralised identity (DID) layer not started
**Status:** ⏸ PENDING (Phase 5)  
**Tags:** `[stellar]` `[missing]`

Profile attestations, SEP-10 Web Auth, and ZK proofs for age/location verification are Phase 5 scope.

---

---

## Section 5 — Security

### ISS-034 · Password fields use TextField instead of SecureField
**Status:** 🔴 OPEN  
**Tags:** `[security]` `[bug]`  
**File:** `views/Auth_view/SignUpView.swift`

Both `textPassword` and `textConfirmPassword` use `CuddleInputField`, which renders a plain `TextField`. Passwords are visible in clear text while typing.

**Fix:**
- Add an `isSecure: Bool` parameter to `CuddleInputField`
- Use `SecureField` when `isSecure == true`
- Apply to both password fields in `SignUpView` and the new `SignInView`

---

### ISS-035 · Confirm password is never validated
**Status:** 🔴 OPEN  
**Tags:** `[security]` `[bug]` `[ux]`  
**File:** `views/Auth_view/SignUpView.swift`

The `textConfirmPassword` field is collected but never compared against `textPassword`. Users can set mismatched passwords and proceed.

**Fix:**
- Before calling `authViewModel.createUser`, assert `textPassword == textConfirmPassword`
- Show an inline validation error if they don't match
- Disable the "Sign Up" button until passwords match

---

### ISS-036 · No error handling shown to the user
**Status:** 🔴 OPEN  
**Tags:** `[security]` `[ux]` `[bug]`  
**Files:** `models/AuthViewModel.swift`, `views/Auth_view/SignUpView.swift`

All errors in `createUser` are caught and only `print()`-ed to the console. The user sees no feedback when signup fails (wrong email format, weak password, network error, etc.).

**Breakdown:**
- Add `@Published var errorMessage: String?` to `AuthViewModel`
- Populate it in the catch block of `createUser`, `signIn`, etc.
- Display an alert or inline error view in `SignUpView` and `SignInView` bound to `errorMessage`

---

### ISS-037 · Stellar private key never leaves the device ✅
**Status:** 🟢 CLOSED — Secret seed stored in Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. Only the public key is written to Firestore. Non-custodial model verified.

---

---

## Section 6 — Architecture

### ISS-038 · ProfileViewModel is local state — not Firestore-backed
**Status:** 🔴 OPEN  
**Tags:** `[arch]` `[firebase]`  
**File:** `views/Profile/models/profileViewModel.swift`

`ProfileViewModel` is an `@Observable` class holding local in-memory state. It is not connected to Firestore. Any changes made to profile data are lost on app restart.

**Breakdown:**
- Evaluate whether `ProfileViewModel` should be a pass-through view model or replaced by direct use of the `User` model
- Add Firestore read/write methods to `profileViewModel` or move persistence to `AuthViewModel`
- Profile edits should write to `users/{uid}` in Firestore

---

### ISS-039 · No loading / skeleton states for async operations
**Status:** 🔴 OPEN  
**Tags:** `[arch]` `[ux]`  
**Files:** Multiple views

Async operations (user fetch, balance query, image load) have no visual loading indicators. The UI appears broken or blank during network calls.

**Breakdown:**
- Add a `isLoading: Bool` state to `AuthViewModel`
- Show a loading spinner or skeleton view in `ContentView` while `authState == .undifined`
- `StellarWalletView` already shows "Loading..." for balance — extend this pattern consistently
- Add shimmer loading states to profile card in `ExploreView` (ISS-008)

---

### ISS-040 · No Firestore security rules in the repo
**Status:** 🔴 OPEN  
**Tags:** `[security]` `[arch]` `[firebase]`

No `firestore.rules` file exists in the repository. Without reviewing rules, it's unknown whether user documents are protected or world-readable/writable.

**Breakdown:**
- Add `firestore.rules` to the repo root
- Rule: users can only read/write their own document (`request.auth.uid == userId`)
- Rule: public key field should be readable by authenticated users (for profile discovery)
- Add `firebase.json` for deployment configuration

---

### ISS-041 · No unit or integration tests
**Status:** 🔴 OPEN  
**Tags:** `[arch]` `[tech-debt]`

No test target exists in the Xcode project. No tests for auth flow, Stellar wallet operations, or any business logic.

**Breakdown:**
- Add a test target to the Xcode project
- Unit test `StellarWalletService` — keypair generation, Keychain read/write, balance parsing
- Unit test `AuthViewModel` — state transitions, error propagation
- UI tests for critical user flows: signup, sign in, profile view

---

## Section 7 — UI / UX

### ISS-042 · Tab bar active state may not update correctly
**Status:** 🔴 OPEN  
**Tags:** `[ui]` `[bug]`  
**File:** `views/dashboardView.swift` → `CuddleTabItem`

`CuddleTabItem` receives `isActive: currentPage == N` evaluated at render time. SwiftUI's `TabView` manages its own selection state and the `CuddleTabItem` label closure does not re-evaluate on tab switch, which may cause the active/inactive images to get out of sync.

**Fix:**
- Use `.tabItem { }` with `Label` or a standard `Image` + `Text` pair driven by SwiftUI's native selection
- Or observe `currentPage` via `@Binding` directly inside `CuddleTabItem`

---

### ISS-043 · "Log in" button on OnboardingView goes nowhere
**Status:** 🔴 OPEN  
**Tags:** `[ux]` `[stub]`  
**File:** `views/Onboarding_flow_view/OnboardingView.swift`

The "Log in" `Button(action: {})` is a no-op. Tied to ISS-004 (no `SignInView`).

**Fix:** Wire to `SignInView` once ISS-004 is resolved.

---

### ISS-044 · Terms and Privacy Policy links have no action
**Status:** 🔴 OPEN  
**Tags:** `[ux]` `[stub]`  
**File:** `views/Onboarding_flow_view/OnboardingView.swift` → `TextLinkBuilder`

Both `TextLinkBuilder` instances pass `onCall: {}`. Tapping them does nothing.

**Fix:**
- Open Terms and Privacy Policy in a `SafariView` / `SFSafariViewController`
- Or route to in-app web view screens

---

### ISS-045 · `CuddleGradientButton` uses `UIScreen.main.bounds` (deprecated)
**Status:** 🔴 OPEN  
**Tags:** `[ui]` `[tech-debt]`  
**File:** `views/reusable_views/CuddleGraidientButton.swift`

`UIScreen.main.bounds.width` is deprecated in iOS 16+ and does not handle multi-window or iPad correctly.

**Fix:**
- Replace with `.frame(maxWidth: .infinity)` and let the parent view control horizontal padding
- Remove the `#if os(iOS)` guard as this is an iOS-only project

---

---

## Section 8 — Tech Debt

### ISS-046 · `AuthState.undifined` typo
**Status:** 🔴 OPEN  
**Tags:** `[tech-debt]`  
**File:** `models/AuthViewModel.swift`

`case undifined` should be `case undefined`. The typo propagates to `ContentView.swift` which matches on `.undifined`.

**Fix:** Rename enum case and all switch/match sites.

---

### ISS-047 · `ProfileViewModel.intersets` typo
**Status:** 🔴 OPEN  
**Tags:** `[tech-debt]`  
**File:** `views/Profile/models/profileViewModel.swift`

`var intersets: [String]` should be `var interests: [String]`. The typo also appears in the `init` parameter and all callers.

**Fix:** Rename property and all call sites.

---

### ISS-048 · `cuddleProfileImage.swift` filename is misleading
**Status:** 🔴 OPEN  
**Tags:** `[tech-debt]`  
**File:** `views/reusable_views/cuddleProfileImage.swift`

The file is named `cuddleProfileImage.swift` but contains `CuddleProfileInfoView` — a composite profile header component with name, age, occupation, and progress. The filename does not reflect its contents.

**Fix:** Rename file to `CuddleProfileInfoView.swift`.

---

### ISS-049 · `CuddleGraidientButton.swift` filename has a typo
**Status:** 🟢 CLOSED — renamed to `CuddleGradientButton.swift` in PR #64 (`fix/iss-048-049-filename-renames`)  
**Tags:** `[tech-debt]`  
**File:** `views/reusable_views/CuddleGraidientButton.swift`

"Graidient" should be "Gradient". Both the filename and any internal references should be corrected.

**Fix:** Rename file to `CuddleGradientButton.swift`.

---

### ISS-050 · `StellarWalletService` is a class singleton — should be actor
**Status:** 🔴 OPEN  
**Tags:** `[tech-debt]` `[arch]` `[stellar]`  
**File:** `models/StellarWalletService.swift`

`StellarWalletService` is a plain `class` singleton used from async contexts. Concurrent calls to Keychain helpers or balance queries are not thread-safe. Swift's `actor` model would make this safe and idiomatic.

**Fix:**
- Convert `StellarWalletService` from `class` to `actor`
- Update all call sites to `await StellarWalletService.shared.method()`

---

---

## Master Issue Index

| ID | Title | Status | Tags | Section |
|---|---|---|---|---|
| ISS-001 | Sign-in function is empty | 🟢 CLOSED | `[stub]` `[firebase]` `[blocking]` | Auth |
| ISS-002 | Sign-out function is empty | 🟢 CLOSED | `[stub]` `[firebase]` `[security]` | Auth |
| ISS-003 | Delete account function is empty | 🟢 CLOSED | `[stub]` `[firebase]` `[security]` | Auth |
| ISS-004 | No sign-in view exists | 🟢 CLOSED | `[missing]` `[ux]` `[blocking]` | Auth |
| ISS-005 | Auth state listener never called | 🟢 CLOSED | `[bug]` `[firebase]` `[arch]` | Auth |
| ISS-006 | Auth routing race condition | 🟢 CLOSED | `[bug]` `[arch]` `[ux]` | Auth |
| ISS-007 | Firebase Auth + Stellar wallet at signup | 🟢 CLOSED | `[firebase]` `[stellar]` | Auth |
| ISS-008 | ExploreView is a placeholder | 🟢 CLOSED | `[stub]` `[missing]` `[blocking]` | Core Views |
| ISS-009 | LikeView is a placeholder | 🟢 CLOSED | `[stub]` `[missing]` | Core Views |
| ISS-010 | ChatView is a placeholder | 🟢 CLOSED | `[stub]` `[missing]` | Core Views |
| ISS-011 | SettingsView is nearly empty | 🟢 CLOSED | `[stub]` `[missing]` `[ux]` | Core Views |
| ISS-012 | ProfileView uses hardcoded mock data | 🔴 OPEN | `[bug]` `[arch]` `[firebase]` | Profile |
| ISS-013 | Profile photos are mocked, no upload | 🔴 OPEN | `[stub]` `[missing]` `[firebase]` | Profile |
| ISS-014 | Profile setup disconnected from auth flow | 🔴 OPEN | `[arch]` `[ux]` `[stub]` | Profile |
| ISS-015 | "Complete my profile" button no-op | 🔴 OPEN | `[stub]` `[ux]` | Profile |
| ISS-016 | StellarWalletView never surfaced in UI | 🟢 CLOSED | `[missing]` `[stellar]` `[ux]` | Stellar P1 |
| ISS-017 | Keypair generation at signup | 🟢 CLOSED | `[stellar]` | Stellar P1 |
| ISS-018 | Keychain secret seed storage | 🟢 CLOSED | `[stellar]` `[security]` | Stellar P1 |
| ISS-019 | Testnet Friendbot funding | 🟢 CLOSED | `[stellar]` | Stellar P1 |
| ISS-020 | Public key persisted to Firestore | 🟢 CLOSED | `[stellar]` `[firebase]` | Stellar P1 |
| ISS-021 | Live XLM balance display | 🟢 CLOSED | `[stellar]` | Stellar P1 |
| ISS-022 | MATCH trustline not implemented | 🟢 CLOSED | `[stellar]` `[missing]` `[blocking]` | Stellar P2 |
| ISS-023 | Payment / transfer not implemented | 🟢 CLOSED | `[stellar]` `[missing]` | Stellar P2 |
| ISS-024 | MATCH balance query not implemented | 🟢 CLOSED | `[stellar]` `[missing]` | Stellar P2 |
| ISS-025 | Transaction history not implemented | 🔴 OPEN | `[stellar]` `[missing]` | Stellar P2 |
| ISS-026 | Earn/spend event triggers not implemented | 🔴 OPEN | `[stellar]` `[missing]` `[firebase]` | Stellar P2 |
| ISS-027 | Subscription smart contract not built | ⏸ PENDING | `[stellar]` `[missing]` | Stellar P3 |
| ISS-028 | Date escrow contract not built | ⏸ PENDING | `[stellar]` `[missing]` | Stellar P3 |
| ISS-029 | NFT profile badges contract not built | ⏸ PENDING | `[stellar]` `[missing]` | Stellar P3 |
| ISS-030 | App is testnet-only, no mainnet switch | ⏸ PENDING | `[stellar]` `[missing]` | Stellar P4 |
| ISS-031 | No seed phrase backup / recovery | ⏸ PENDING | `[stellar]` `[missing]` `[security]` | Stellar P4 |
| ISS-032 | No transaction history view | ⏸ PENDING | `[stellar]` `[missing]` `[ux]` | Stellar P4 |
| ISS-033 | DID layer not started | ⏸ PENDING | `[stellar]` `[missing]` | Stellar P5 |
| ISS-034 | Password fields not SecureField | 🟢 CLOSED | `[security]` `[bug]` | Security |
| ISS-035 | Confirm password never validated | 🟢 CLOSED | `[security]` `[bug]` `[ux]` | Security |
| ISS-036 | No error handling shown to user | 🟢 CLOSED | `[security]` `[ux]` `[bug]` | Security |
| ISS-037 | Stellar private key never leaves device | 🟢 CLOSED | `[security]` `[stellar]` | Security |
| ISS-038 | ProfileViewModel not Firestore-backed | 🟢 CLOSED | `[arch]` `[firebase]` | Architecture |
| ISS-039 | No loading states for async operations | 🟢 CLOSED | `[arch]` `[ux]` | Architecture |
| ISS-040 | No Firestore security rules in repo | 🟢 CLOSED | `[security]` `[arch]` `[firebase]` | Architecture |
| ISS-041 | No unit or integration tests | 🟢 CLOSED | `[arch]` `[tech-debt]` | Architecture |
| ISS-042 | Tab bar active state may desync | 🟢 CLOSED | `[ui]` `[bug]` | UI/UX |
| ISS-043 | "Log in" button goes nowhere | 🟢 CLOSED | `[ux]` `[stub]` | UI/UX |
| ISS-044 | Terms/Privacy Policy links no-op | 🟢 CLOSED | `[ux]` `[stub]` | UI/UX |
| ISS-045 | `UIScreen.main.bounds` deprecated usage | 🟢 CLOSED | `[ui]` `[tech-debt]` | UI/UX |
| ISS-046 | `AuthState.undifined` typo | 🟢 CLOSED | `[tech-debt]` | Tech Debt |
| ISS-047 | `ProfileViewModel.intersets` typo | 🟢 CLOSED | `[tech-debt]` | Tech Debt |
| ISS-048 | `cuddleProfileImage.swift` misleading filename | 🟢 CLOSED | `[tech-debt]` | Tech Debt |
| ISS-049 | `CuddleGraidientButton.swift` filename typo | 🟢 CLOSED | `[tech-debt]` | Tech Debt |
| ISS-050 | `StellarWalletService` should be an actor | 🟢 CLOSED | `[tech-debt]` `[arch]` `[stellar]` | Tech Debt |

---

## Section 9 — Post-Audit Issues (ISS-051–074)

> Identified via codebase audit on 2026-08-03. All issues filed on GitHub.

---

### ISS-051 · like() and pass() never write to Firestore
**Status:** 🔴 OPEN
**Tags:** `[stub]` `[missing]` `[blocking]` `[firebase]`
**File:** `views/Explore/ExploreViewModel.swift`
**Priority:** High

Both `like()` and `pass()` only call `removeTopCard()`. Every swipe decision is lost on app restart and the mutual-match check is never triggered.

**Breakdown:**
- **ISS-051a** · Write like to `likes/{uid}/liked/{targetUID}` and `likes/{targetUID}/likedBy/{uid}`
- **ISS-051b** · Write pass to `passes/{uid}/passed/{targetUID}`
- **ISS-051c** · Implement `checkForMatch()` — create conversation on mutual like
- **ISS-051d** · Wire `RewardService.onReceivedLike()` and `onMutualMatch()` after writes

---

### ISS-052 · fetchProfiles() excludes no already-seen UIDs
**Status:** 🔴 OPEN
**Tags:** `[stub]` `[missing]` `[firebase]`
**File:** `views/Explore/ExploreViewModel.swift`
**Priority:** High

Query returns the same first 20 users without excluding liked/passed/matched UIDs. Users see the same profiles repeatedly. No pagination cursor.

**Breakdown:**
- **ISS-052a** · Fetch liked/passed UIDs before the profiles query and exclude them
- **ISS-052b** · Add `DocumentSnapshot` cursor and use `startAfter()` for pagination
- **ISS-052c** · Trigger re-fetch when profiles array is nearly empty (within 3 cards)

---

### ISS-053 · LikesViewModel.fetchLikes() is an unconditional empty stub
**Status:** 🔴 OPEN
**Tags:** `[stub]` `[missing]` `[blocking]` `[firebase]`
**File:** `views/Likes/LikesViewModel.swift`
**Priority:** High

`fetchLikes()` sets `profiles = []` and returns immediately. The Likes tab is permanently empty for all users.

**Breakdown:**
- **ISS-053a** · Query `likes/{currentUID}/likedBy` subcollection
- **ISS-053b** · Fetch `users/{uid}` for each result to build `LikedByProfile`
- **ISS-053c** · Handle partial failures gracefully with `compactMap`

---

### ISS-054 · LikesViewModel likeBack() and pass() never write to Firestore
**Status:** 🔴 OPEN
**Tags:** `[stub]` `[missing]` `[firebase]`
**File:** `views/Likes/LikesViewModel.swift`
**Priority:** High

Decisions are lost on next fetch. Match creation and reward triggers are missing.

**Breakdown:**
- **ISS-054a** · Write like-back to Firestore and delete from `likedBy` subcollection atomically
- **ISS-054b** · Implement match creation (shared with `ExploreViewModel.checkForMatch()`)
- **ISS-054c** · Persist pass to passes collection

---

### ISS-055 · All Chat methods are stubs — messaging is entirely non-functional
**Status:** 🔴 OPEN
**Tags:** `[stub]` `[missing]` `[blocking]` `[firebase]`
**File:** `views/Chats/ChatViewModel.swift`
**Priority:** High

`fetchConversations()`, `fetchMessages()`, and `sendMessage()` all return empty or discard data without touching Firestore. No real-time listeners.

**Breakdown:**
- **ISS-055a** · Implement `fetchConversations()` with `whereField('participants', arrayContains:)`
- **ISS-055b** · Implement `fetchMessages()` with ordered subcollection query
- **ISS-055c** · Implement `sendMessage()` — write to messages subcollection and update `lastMessage`
- **ISS-055d** · Replace one-shot queries with `addSnapshotListener`; store handles for cleanup

---

### ISS-056 · RewardService.distributeReward() sends payment from user to themselves
**Status:** 🔴 OPEN
**Tags:** `[bug]` `[stellar]` `[security]` `[blocking]`
**File:** `models/RewardService.swift`
**Priority:** High

`distributeReward()` calls `sendPayment(to: publicKey)` where both sender and recipient are the current user. Architecturally wrong and broken on any account with a trustline. Must not reach production.

**Breakdown:**
- **ISS-056a** · On testnet: provision a funded reserve wallet and sign distributions from it
- **ISS-056b** · On mainnet: replace body with a Cloud Function HTTP call signed server-side
- **ISS-056c** · Add `#if DEBUG` / testnet build flag to gate the placeholder

---

### ISS-057 · MatchAssetConfig.defaultIssuerAccountId is a fake placeholder key
**Status:** 🟢 CLOSED — implemented in branch `fix/iss-057-match-issuer-key`; real testnet issuer key (`GDW6CBZZS7NLC5LTXGWTBBEUIRMEFBWBNT6NLU7ZXG24MMJMLZILSSXZ`) configured in `Config/StellarConfig.swift`
**Tags:** `[bug]` `[stellar]` `[security]` `[blocking]`
**File:** `models/StellarWalletService.swift`
**Priority:** High

`'GBMATCHMEISSUERACCOUNTXLMSTELLARPUBLICKEY1234567890123'` was not a valid Stellar public key. Replaced with real testnet issuer key.

**Breakdown:**
- **ISS-057a** · Create a real testnet issuer account and fund via Friendbot (done, key: `GDW6CBZZS7NLC5LTXGWTBBEUIRMEFBWBNT6NLU7ZXG24MMJMLZILSSXZ`)
- **ISS-057b** · Replace placeholder with real testnet issuer public key
- **ISS-057c** · Store in config file or environment variable — centralized in `Config/StellarConfig.swift`

---

### ISS-058 · StellarWalletView is unreachable — SettingsView never passes publicKey
**Status:** 🔴 OPEN
**Tags:** `[bug]` `[stellar]` `[ui]` `[blocking]`
**File:** `views/Settings/settingsView.swift`
**Priority:** High

`StellarWalletView` requires `publicKey: String` but SettingsView navigates to it without arguments — a compile-time error making the wallet screen inaccessible.

**Breakdown:**
- **ISS-058a** · Read `authViewModel.currentUser?.stellarPublicKey` and pass to `StellarWalletView`
- **ISS-058b** · Handle nil case (no wallet yet) by showing a generate-wallet prompt

---

### ISS-059 · TransactionHistoryView NavigationLink may not work via SwiftfulRouting push
**Status:** 🔴 OPEN
**Tags:** `[missing]` `[stellar]` `[ux]`
**File:** `views/StellarWalletView.swift`
**Priority:** Medium

The `NavigationLink` to `TransactionHistoryView` requires an active `NavigationStack`. When `StellarWalletView` is pushed via SwiftfulRouting from SettingsView, the link may be non-functional.

**Breakdown:**
- **ISS-059a** · Verify `NavigationLink` works when pushed via SwiftfulRouting
- **ISS-059b** · Wrap `StellarWalletView` in `NavigationStack` or use `router.showScreen(.push)` for the history link

---

### ISS-060 · Firestore rules missing /rewardLog rule — de-duplication broken
**Status:** 🔴 OPEN
**Tags:** `[bug]` `[security]` `[firebase]` `[blocking]`
**File:** `firestore.rules`
**Priority:** High

No `match /rewardLog/{docId}` rule exists. The catch-all deny means `alreadyRewarded()` always returns `false` and `recordReward()` silently fails — every reward can be triggered unlimited times.

**Breakdown:**
- **ISS-060a** · Add `/rewardLog/{docId}` rule allowing authenticated users to read their own entries
- **ISS-060b** · Restrict writes to Cloud Functions service account
- **ISS-060c** · Testnet interim: allow write if `request.auth.uid == request.resource.data.userID`

---

### ISS-061 · Settings notification and profile-visibility toggles not persisted
**Status:** 🔴 OPEN
**Tags:** `[stub]` `[ux]` `[firebase]`
**File:** `views/Settings/settingsView.swift`
**Priority:** Medium

Both toggles are `@State` variables that reset on app launch with no Firestore or system integration.

**Breakdown:**
- **ISS-061a** · Wire notifications toggle to `UNUserNotificationCenter.requestAuthorization`
- **ISS-061b** · Persist `profileVisible` to Firestore via `profileViewModel.updateField()`

---

### ISS-062 · Settings Terms and Privacy Policy rows still navigate nowhere
**Status:** 🔴 OPEN
**Tags:** `[stub]` `[ux]`
**File:** `views/Settings/settingsView.swift`
**Priority:** Medium

Both rows have empty action closures — a legal compliance risk as app stores require accessible links to these documents.

**Breakdown:**
- **ISS-062a** · Reuse the `SafariView` wrapper from `OnboardingView` (ISS-044)
- **ISS-062b** · Wire Terms and Privacy Policy rows to open respective URLs

---

### ISS-063 · ProfileView tab labels are hardcoded 'Tab 1' / 'Tab 2' placeholders
**Status:** 🔴 OPEN
**Tags:** `[stub]` `[ux]` `[ui]`
**File:** `views/Profile/profileView.swift`
**Priority:** Medium

Placeholder strings "Tab 1", "Tab 2", and "Feature_1 name" are visible to end users. Second tab content duplicates the first.

**Breakdown:**
- **ISS-063a** · Replace tab labels with real names (e.g. 'About' / 'Premium')
- **ISS-063b** · Replace `cuddleFeature` placeholders with real premium feature definitions
- **ISS-063c** · Resolve content duplication between the two tabs

---

### ISS-064 · deleteAccount() partial failure leaves orphaned Firebase Auth record
**Status:** 🔴 OPEN
**Tags:** `[bug]` `[security]` `[firebase]`
**File:** `models/AuthViewModel.swift`
**Priority:** High

Deletes Firestore document first, then Auth. If Auth deletion fails the user has an Auth account but no Firestore document. No re-authentication prompt before the sensitive operation.

**Breakdown:**
- **ISS-064a** · Reverse order: delete Auth first then Firestore — or use a Cloud Function for atomic cleanup
- **ISS-064b** · Call `user.reauthenticate()` and surface a credential prompt on `requiresRecentLogin`
- **ISS-064c** · Surface error to UI — `SettingsView` uses `try?` which swallows it silently

---

### ISS-065 · fetchUser() silently swallows errors — infinite loading state
**Status:** 🔴 OPEN
**Tags:** `[bug]` `[missing]` `[firebase]`
**File:** `models/AuthViewModel.swift`
**Priority:** Medium

`try?` on both `getDocument()` and `data(as: User.self)` leaves `currentUser` nil with no feedback. `ContentView` stays on `CuddleLoadingView` indefinitely.

**Breakdown:**
- **ISS-065a** · Propagate error from `fetchUser()` and set `errorMessage` for a retry prompt
- **ISS-065b** · Add maximum retry count or timeout to escape infinite loading

---

### ISS-066 · Stellar wallet creation failure silently ignored in createUser()
**Status:** 🔴 OPEN
**Tags:** `[missing]` `[stellar]` `[ux]`
**File:** `models/AuthViewModel.swift`
**Priority:** Medium

`getOrCreateKeypair()` and `fundTestnetAccount()` both use `try?`. Failure leaves `stellarPublicKey` nil in Firestore with no user feedback and no retry path.

**Breakdown:**
- **ISS-066a** · Separate auth-critical from wallet-critical errors in `createUser()`
- **ISS-066b** · Show recoverable banner with 'Retry wallet setup' action
- **ISS-066c** · Add wallet repair entry point in Settings for users with nil `stellarPublicKey`

---

### ISS-067 · signOut() error silently swallowed — ambiguous auth state
**Status:** 🔴 OPEN
**Tags:** `[missing]` `[ux]`
**File:** `models/AuthViewModel.swift`
**Priority:** Low

`catch` block only calls `print()`. On failure the app stays authenticated with no user feedback.

**Breakdown:**
- **ISS-067a** · Set `errorMessage` on failure and surface in `SettingsView`
- **ISS-067b** · Force-clear local state even when Firebase call fails

---

### ISS-068 · getOrCreateKeypair() Keychain failure silently ignored in createUser()
**Status:** 🔴 OPEN
**Tags:** `[bug]` `[arch]` `[stellar]`
**File:** `models/AuthViewModel.swift`
**Priority:** Medium

`try?` wrapper discards specific Keychain error codes (e.g. `errSecDuplicateItem` race) with no diagnostics.

**Breakdown:**
- **ISS-068a** · Make `getOrCreateKeypair()` `async throws` to make actor boundary explicit
- **ISS-068b** · Replace `try?` with `do/catch` that logs or surfaces the specific Keychain error

---

### ISS-069 · StellarWalletServiceTests.tearDown() has a fire-and-forget Task race condition
**Status:** 🔴 OPEN
**Tags:** `[bug]` `[tech-debt]`
**File:** `matchme.mobile_swiftTests/StellarWalletServiceTests.swift`
**Priority:** Medium

`Task { await service.clearKeypair() }` returns immediately — the async Keychain delete may not complete before the next test starts, causing non-deterministic results.

**Breakdown:**
- [ ] Change `tearDown()` to `override func tearDown() async` and call `await service.clearKeypair()` directly

---

### ISS-070 · No tests for RewardService event processing or de-duplication
**Status:** 🔴 OPEN
**Tags:** `[missing]` `[tech-debt]` `[stellar]`
**File:** `matchme.mobile_swiftTests/`
**Priority:** Medium

`RewardService` is the most complex business-logic class in the project and has zero test coverage.

**Breakdown:**
- **ISS-070a** · Add `RewardServiceTests.swift` — `deduplicationKey()` for all `RewardEvent` cases
- **ISS-070b** · Test signed `matchDelta` values for all earn and spend events
- **ISS-070c** · Integration test for `alreadyRewarded()` guard (Firestore emulator or mock)

---

### ISS-071 · No tests for ExploreViewModel, LikesViewModel, or ChatViewModel
**Status:** 🔴 OPEN
**Tags:** `[missing]` `[tech-debt]`
**File:** `matchme.mobile_swiftTests/`
**Priority:** Medium

All three core feature ViewModels have zero test coverage.

**Breakdown:**
- **ISS-071a** · Add `ExploreViewModelTests` — `removeTopCard()`, profile filtering, error states
- **ISS-071b** · Add `LikesViewModelTests` — `likeBack()` / `pass()` state mutations
- **ISS-071c** · Add `ChatViewModelTests` — `sendMessage()` guard, `isLoading` transitions

---

### ISS-072 · ProfileViewModel.updateProfile() is never called — profile edits not persisted
**Status:** 🔴 OPEN
**Tags:** `[missing]` `[firebase]`
**File:** `views/Profile/profileView.swift`
**Priority:** High

`updateProfile()` is fully implemented but no view calls it. `profileView.swift` is read-only with no edit/save flow.

**Breakdown:**
- **ISS-072a** · Add edit mode to `ProfileView` or create a `ProfileEditView`
- **ISS-072b** · Call `vm.updateProfile()` on save and handle errors with alert or banner
- **ISS-072c** · Wire `RewardService.onProfileCompleted()` when bio and photo are both non-empty

---

### ISS-073 · ExploreCardView photo loading has no failure/loading state distinction
**Status:** 🔴 OPEN
**Tags:** `[ux]` `[ui]`
**File:** `views/Explore/ExploreCardView.swift`
**Priority:** Low

`.empty` (loading) and `.failure` (broken URL) both show the same gradient placeholder. No retry mechanism for transient failures.

**Breakdown:**
- **ISS-073a** · Add `.failure` case with a distinct broken-image indicator or retry button
- **ISS-073b** · Add `.empty` case with shimmer animation from `CuddleLoadingView.swift`

---

### ISS-074 · StellarWalletView shows 'Loading...' permanently on Horizon fetch failure
**Status:** 🔴 OPEN
**Tags:** `[ux]` `[missing]` `[stellar]`
**File:** `views/StellarWalletView.swift`
**Priority:** Medium

Balance strings initialised as `'Loading...'` stay that way on network failure. No error state or retry button.

**Breakdown:**
- **ISS-074a** · Replace raw `String` state with a `LoadState` enum (`.loading`, `.loaded`, `.failed`)
- **ISS-074b** · Show 'Failed to load — tap to retry' and wire a retry action