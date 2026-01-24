# Authentication & Security Patterns

## Authentication State Machine

All C&C mobile apps use a state machine for authentication flow:

```swift
enum AuthenticationState: Equatable {
    case checking              // Initial state, verifying session
    case unauthenticated       // No valid session
    case authenticating        // OAuth in progress
    case setupRequired         // First login, needs additional setup
    case biometricRequired     // App locked, needs biometric unlock
    case authenticated         // Active session with valid user
}
```

## Supabase Auth Manager Pattern

### Standard Implementation

```swift
import Supabase
import LocalAuthentication
import Combine

@MainActor
class SupabaseAuthManager: ObservableObject {
    // MARK: - Singleton
    static let shared = SupabaseAuthManager()

    // MARK: - Published Properties
    @Published var authenticationState: AuthenticationState = .checking
    @Published var currentUser: User?
    @Published var session: Session?

    // MARK: - Private Properties
    private let supabaseClient: SupabaseClient
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private init() {
        self.supabaseClient = SupabaseClientManager.shared.client
        setupAuthObserver()
    }

    // MARK: - Setup
    private func setupAuthObserver() {
        Task {
            for await state in await supabaseClient.auth.authStateChanges {
                switch state {
                case .signedIn(let session):
                    self.session = session
                    self.currentUser = session.user
                    self.authenticationState = .authenticated
                case .signedOut:
                    self.session = nil
                    self.currentUser = nil
                    self.authenticationState = .unauthenticated
                default:
                    break
                }
            }
        }
    }

    // MARK: - Public Methods
    func checkAuthentication() async {
        authenticationState = .checking

        do {
            let session = try await supabaseClient.auth.session
            self.session = session
            self.currentUser = session.user
            authenticationState = .authenticated
        } catch {
            authenticationState = .unauthenticated
        }
    }

    func signInWithOAuth(provider: Provider) async throws {
        authenticationState = .authenticating

        try await supabaseClient.auth.signInWithOAuth(
            provider: provider,
            redirectTo: URL(string: "\(SupabaseConfig.urlScheme)://login-callback")
        )

        // State will be updated by authStateChanges observer
    }

    func handleOAuthCallback(_ url: URL) async throws {
        try await supabaseClient.auth.session(from: url)
        // Session established, state will be updated by observer
    }

    func signOut() async throws {
        try await supabaseClient.auth.signOut()
        SecureTokenManager.shared.clearAll()
        BiometricAuthManager.shared.disableBiometric()
        // State will be updated by observer
    }

    func refreshSession() async throws {
        guard let session = session else {
            authenticationState = .unauthenticated
            return
        }

        let newSession = try await supabaseClient.auth.refreshSession()
        self.session = newSession
    }
}
```

## OAuth Flow

### Configuration in Info.plist

```xml
<!-- Info.plist -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>io.supabase.yourapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.yourapp</string>
        </array>
    </dict>
</array>
```

### Handle URL Callback

```swift
@main
struct YourApp: App {
    @StateObject private var authManager = SupabaseAuthManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Task {
                        try? await authManager.handleOAuthCallback(url)
                    }
                }
        }
    }
}
```

### OAuth Sign-In View

```swift
struct AuthenticationView: View {
    @EnvironmentObject var authManager: SupabaseAuthManager
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            // Logo and branding
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            Text("Welcome to C&C Team")
                .font(.title)
                .fontWeight(.bold)

            Text("Sign in with your business account")
                .font(.body)
                .foregroundStyle(.secondary)

            // OAuth buttons
            GlassButton(
                title: "Sign in with Google",
                icon: "g.circle.fill",
                style: .primary
            ) {
                signIn(with: .google)
            }
            .disabled(isLoading)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private func signIn(with provider: Provider) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await authManager.signInWithOAuth(provider: provider)
            } catch {
                errorMessage = "Sign in failed. Please try again."
                isLoading = false
            }
        }
    }
}
```

## Biometric Authentication

### BiometricAuthManager Pattern

```swift
import LocalAuthentication

@MainActor
class BiometricAuthManager: ObservableObject {
    // MARK: - Singleton
    static let shared = BiometricAuthManager()

    // MARK: - Published Properties
    @Published var isBiometricEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBiometricEnabled, forKey: biometricEnabledKey)
        }
    }

    @Published var biometricType: LABiometryType = .none
    @Published var isAuthenticating = false

    // MARK: - Private Properties
    private let context = LAContext()
    private let biometricEnabledKey = "BiometricAuthEnabled"

    // MARK: - Computed Properties
    var isBiometricAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    var biometricTypeDescription: String {
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometric Authentication"
        }
    }

    // MARK: - Initialization
    private init() {
        self.isBiometricEnabled = UserDefaults.standard.bool(forKey: biometricEnabledKey)
        self.biometricType = context.biometryType
    }

    // MARK: - Public Methods
    func enableBiometric() {
        isBiometricEnabled = true
    }

    func disableBiometric() {
        isBiometricEnabled = false
    }

    func authenticate(reason: String) async throws -> Bool {
        guard isBiometricAvailable else {
            throw BiometricError.notAvailable
        }

        isAuthenticating = true
        defer { isAuthenticating = false }

        let context = LAContext()
        context.localizedReason = reason
        context.localizedFallbackTitle = "Use Passcode"
        context.localizedCancelTitle = "Cancel"

        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }
}

enum BiometricError: LocalizedError {
    case notAvailable
    case authenticationFailed
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device"
        case .authenticationFailed:
            return "Biometric authentication failed"
        case .userCancelled:
            return "Authentication was cancelled"
        }
    }
}
```

### Biometric Setup View

```swift
struct BiometricSetupView: View {
    @EnvironmentObject var biometricManager: BiometricAuthManager
    @State private var isLoading = false
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: biometricIcon)
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("Enable \(biometricManager.biometricTypeDescription)")
                .font(.title2)
                .fontWeight(.bold)

            Text("Use \(biometricManager.biometricTypeDescription) to quickly access your account")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                GlassButton(
                    title: "Enable \(biometricManager.biometricTypeDescription)",
                    icon: "checkmark.circle.fill",
                    style: .primary
                ) {
                    enableBiometric()
                }
                .disabled(isLoading)

                Button("Skip for now") {
                    onComplete()
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    private var biometricIcon: String {
        switch biometricManager.biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.shield"
        }
    }

    private func enableBiometric() {
        isLoading = true

        Task {
            do {
                let success = try await biometricManager.authenticate(
                    reason: "Enable \(biometricManager.biometricTypeDescription) for quick access"
                )

                if success {
                    biometricManager.enableBiometric()
                    onComplete()
                }
            } catch {
                // Handle error
            }

            isLoading = false
        }
    }
}
```

## Secure Storage (Keychain)

### SecureTokenManager Pattern

```swift
import Security
import Foundation

class SecureTokenManager {
    static let shared = SecureTokenManager()

    private init() {}

    // MARK: - Public Methods
    func storeToken(_ token: String, for key: String) throws {
        let data = token.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status)
        }
    }

    func retrieveToken(for key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.retrieveFailed(status)
        }

        return token
    }

    func deleteToken(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    func clearAll() {
        let secClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]

        for secClass in secClasses {
            let query: [String: Any] = [kSecClass as String: secClass]
            SecItemDelete(query as CFDictionary)
        }
    }
}

enum KeychainError: LocalizedError {
    case storeFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .storeFailed(let status):
            return "Failed to store item in Keychain (status: \(status))"
        case .retrieveFailed(let status):
            return "Failed to retrieve item from Keychain (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete item from Keychain (status: \(status))"
        }
    }
}
```

### Token Storage Keys

```swift
enum KeychainKey {
    static let accessToken = "com.yourapp.accessToken"
    static let refreshToken = "com.yourapp.refreshToken"
    static let userID = "com.yourapp.userID"

    // ❌ NEVER store these in Keychain or UserDefaults:
    // - Passwords (use OAuth only)
    // - Credit card numbers
    // - Social security numbers
}
```

## Session Management

### Automatic Token Refresh

```swift
extension SupabaseAuthManager {
    func setupTokenRefresh() {
        // Refresh token 5 minutes before expiration
        Timer.scheduledTimer(withTimeInterval: 3300, repeats: true) { [weak self] _ in
            Task {
                try? await self?.refreshSession()
            }
        }
    }

    func refreshTokenIfNeeded() async {
        guard let session = session else {
            authenticationState = .unauthenticated
            return
        }

        // Check if token expires in next 5 minutes
        let expiresAt = session.expiresAt
        let fiveMinutesFromNow = Date().addingTimeInterval(300)

        if expiresAt <= fiveMinutesFromNow {
            try? await refreshSession()
        }
    }
}
```

### App Lifecycle Integration

```swift
@main
struct YourApp: App {
    @StateObject private var authManager = SupabaseAuthManager.shared
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        Task {
                            await authManager.refreshTokenIfNeeded()
                        }
                    case .background:
                        // Lock app if biometric is enabled
                        if BiometricAuthManager.shared.isBiometricEnabled {
                            authManager.authenticationState = .biometricRequired
                        }
                    default:
                        break
                    }
                }
        }
    }
}
```

## Security Best Practices

### DO:
✅ Use OAuth for authentication (Google, Apple, etc.)
✅ Store tokens in Keychain with `.whenUnlockedThisDeviceOnly`
✅ Implement automatic token refresh
✅ Validate user email domains for internal apps
✅ Use biometric authentication as enhancement, not requirement
✅ Clear all sensitive data on logout
✅ Lock app when entering background (if biometric enabled)
✅ Handle token expiration gracefully
✅ Use HTTPS for all API calls
✅ Implement certificate pinning for sensitive apps

### DON'T:
❌ Store passwords in plain text
❌ Use UserDefaults for tokens or sensitive data
❌ Hardcode API keys in source code
❌ Skip session validation
❌ Trust client-side data without server validation
❌ Store sensitive data in app group containers
❌ Use weak encryption algorithms
❌ Ignore certificate validation errors
❌ Allow screenshots of sensitive screens
❌ Log sensitive information to console

### Domain Validation for Internal Apps

```swift
extension SupabaseAuthManager {
    func validateBusinessDomain(_ email: String) -> Bool {
        let allowedDomains = ["@yourcompany.com", "@partner.com"]
        return allowedDomains.contains { email.hasSuffix($0) }
    }

    func signInWithValidation(provider: Provider) async throws {
        try await signInWithOAuth(provider: provider)

        guard let email = currentUser?.email,
              validateBusinessDomain(email) else {
            try await signOut()
            throw AuthError.unauthorizedDomain
        }
    }
}
```

## Encryption for Sensitive Data

```swift
import CryptoKit

class EncryptionManager {
    static let shared = EncryptionManager()

    private init() {}

    func encrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    func decrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    func generateKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }

    // Store encryption key in Keychain
    func storeKey(_ key: SymmetricKey, for identifier: String) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        try SecureTokenManager.shared.storeToken(
            keyData.base64EncodedString(),
            for: identifier
        )
    }

    func retrieveKey(for identifier: String) throws -> SymmetricKey? {
        guard let keyString = try SecureTokenManager.shared.retrieveToken(for: identifier),
              let keyData = Data(base64Encoded: keyString) else {
            return nil
        }

        return SymmetricKey(data: keyData)
    }
}
```

## Testing Authentication

```swift
// Mock Auth Manager for testing
class MockAuthManager: ObservableObject {
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var currentUser: User?

    func signIn() {
        authenticationState = .authenticated
        currentUser = User(id: UUID(), email: "test@example.com")
    }

    func signOut() {
        authenticationState = .unauthenticated
        currentUser = nil
    }
}

// Use in SwiftUI previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MockAuthManager())
    }
}
```
