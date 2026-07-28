# matchme.mobile_swiftTests

Unit tests for MatchMe Stellar — ISS-041.

## Adding the test target in Xcode

The test files are committed here but the Xcode test target must be
added manually (the `.xcodeproj` is a binary file):

1. Open `matchme.mobile_swift.xcodeproj` in Xcode
2. **File → New → Target → Unit Testing Bundle**
3. Name it exactly: `matchme.mobile_swiftTests`
4. Set "Target to be Tested" to `matchme.mobile_swift`
5. In the target's Build Phases → Compile Sources, add:
   - `AuthViewModelTests.swift`
   - `StellarWalletServiceTests.swift`
   - `ProfileViewModelTests.swift`
6. Run all tests with **Cmd + U**

## Test files

| File | Covers |
|---|---|
| `AuthViewModelTests.swift` | Initial state, signOut resets session |
| `StellarWalletServiceTests.swift` | Keypair generation, Keychain clear, balance parsing |
| `ProfileViewModelTests.swift` | `init(from user:)` field mapping, completion score |

## Running from CI

The CI workflow (`swift.yml`) already runs `xcodebuild test` — once
the test target is added in Xcode and committed, tests will run
automatically on every PR.
