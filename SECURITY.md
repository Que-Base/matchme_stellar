# Security Policy

## Reporting a Vulnerability

Security is paramount to the MatchMe platform, particularly concerning non-custodial Stellar wallet management, iOS Keychain security, and Firebase access controls.

If you discover a security vulnerability, please report it by opening an issue or contacting the core maintainers directly. We take all security reports seriously and will investigate immediately.

### Critical Vulnerabilities
For critical security vulnerabilities—especially those involving private seed exposure, Keychain access controls, or unauthorized authentication bypasses—please **do not disclose them publicly**. Grant us time to triage, address, and release a fix before public disclosure.

## Security Practices

- **Non-Custodial Keys**: Private keys and seed phrases are generated on-device and stored exclusively in the iOS Keychain. MatchMe servers never receive or store private keys.
- **Firebase Security Rules**: Firestore access rules enforce document-level ownership checks (`request.auth.uid == userId`).
