# MatchMe Stellar Mobile (Swift, Stellar)

MatchMe is a modern, visually rich social networking application built with SwiftUI. It features a seamless onboarding experience, profile management, discovery (Explore), and real-time interactions (Chats/Likes). The application follows a modern MVVM architecture and integrates with Firebase for authentication and backend services.

## 🚀 Features

- **Onboarding & Authentication**: Smooth user onboarding flow with secure Firebase-backed sign-up and profile setup.
- **Discovery (Explore)**: An intuitive interface to discover other users/pets.
- **Interactions**: Like and connect with others, supported by a dedicated "Likes" view and real-time chat.
- **Rich Profiles**: Comprehensive profile management including bios, interests, and photo uploads.
- **Modern UI**: Custom-designed components with a focus on aesthetics, utilizing custom typography and gradients.
- **Dynamic Routing**: Powered by `SwiftfulRouting` for a decoupled and flexible navigation experience.

## 🛠 Tech Stack

- **Language**: Swift 5.10+
- **UI Framework**: SwiftUI
- **Navigation**: [SwiftfulRouting](https://github.com/SwiftfulThinking/SwiftfulRouting)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, etc.)
- **Architecture**: MVVM (using the latest `@Observable` macro)
- **Design Assets**: Custom icons (Linear & Misc), Custom Fonts (Athletics, General Sans, SF Pro Rounded).

## 📁 Project Structure

```text
matchme.mobile_swift/
├── App/
│   ├── matchme_mobile_swiftApp.swift  # Application Entry Point
│   └── ContentView.swift               # Root View (Auth Logic)
├── Views/
│   ├── Auth_view/                      # Authentication (SignUp, etc.)
│   ├── Onboarding_flow_view/           # Profile Setup & Onboarding
│   ├── dashboardView.swift             # Main Tab Navigation
│   ├── Explore/                        # Discovery Views
│   ├── Likes/                          # User Interest/Like Views
│   ├── Chats/                          # Messaging Interface
│   ├── Profile/                        # User Profile & Bio Management
│   └── reusable_views/                 # Custom UI Components (Buttons, Input Fields)
├── Models/
│   ├── AuthViewModel.swift             # Authentication & User State
│   ├── userModel.swift                 # User Data Structure
│   └── profileViewModel.swift          # Profile Logic
├── Helpers/
│   ├── cuddleColor.swift               # Custom Color Extensions
│   ├── customScrollView.swift          # UI Enhancements
│   └── Fonts/                          # Custom Font Assets
└── Assets.xcassets/                    # Icons, Logos, and Colors
```

## ⚙️ Setup Instructions

### Prerequisites
- macOS with **Xcode 15.0+** installed.
- A Firebase project set up in the [Firebase Console](https://console.firebase.google.com/).

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/matchme.mobile_swift.git
   cd matchme.mobile_swift
   ```

2. **Open the project**:
   Open `matchme.mobile_swift.xcodeproj` in Xcode.

3. **Firebase Configuration**:
   - Download your `GoogleService-Info.plist` from the Firebase Console.
   - Add the file to the `matchme.mobile_swift/` directory in Xcode, ensuring it's added to the app target.

4. **Dependencies**:
   Xcode will automatically resolve the Swift Package Manager (SPM) dependencies:
   - `Firebase`
   - `SwiftfulRouting`
   - `SwiftfulRecursiveUI`

5. **Run**:
   Select a simulator (e.g., iPhone 15) and press `Cmd + R` to build and run.

## 🎨 Design System

The app uses a custom design system defined in `Assets.xcassets` and `Helpers/`:
- **Typography**: Uses `Athletics`, `General Sans`, and `SF Pro Rounded`.
- **Colors**: Defined in `cuddleColor.swift`, including primary gradients (`gradientLight`, `gradientDark`) and secondary status colors.
