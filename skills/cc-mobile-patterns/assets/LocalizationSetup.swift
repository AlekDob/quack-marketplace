import Foundation
import Combine

/// Complete Internationalization (i18n) Setup
///
/// This file contains all components needed for multi-language support in C&C mobile apps.
///
/// Usage:
/// 1. Copy this file to your project
/// 2. Create .lproj folders for each language (it.lproj, fr.lproj, en.lproj)
/// 3. Add Localizable.strings files to each folder
/// 4. Update LocalizedKeys enum with your app's keys
/// 5. Inject LocalizationManager as EnvironmentObject in your app

// MARK: - AppLanguage Enum

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case italian = "it"
    case french = "fr"
    case english = "en"

    var id: String { rawValue }

    var nativeName: String {
        switch self {
        case .italian: return "Italiano"
        case .french: return "Français"
        case .english: return "English"
        }
    }

    var flag: String {
        switch self {
        case .italian: return "🇮🇹"
        case .french: return "🇫🇷"
        case .english: return "🇬🇧"
        }
    }

    var locale: Locale {
        switch self {
        case .italian: return Locale(identifier: "it_IT")
        case .french: return Locale(identifier: "fr_FR")
        case .english: return Locale(identifier: "en_US")
        }
    }

    static var deviceLanguage: AppLanguage {
        let preferredLanguages = Locale.preferredLanguages

        for language in preferredLanguages {
            let languageCode = language.prefix(2).lowercased()
            if let appLanguage = AppLanguage(rawValue: String(languageCode)) {
                return appLanguage
            }
        }

        // Default to Italian for C&C (Italian market focus)
        return .italian
    }
}

// MARK: - LocalizationManager

@MainActor
class LocalizationManager: ObservableObject {
    // MARK: - Singleton
    static let shared = LocalizationManager()

    // MARK: - Published Properties
    @Published var currentLanguage: AppLanguage {
        didSet {
            saveLanguagePreference()
            updateLocale()
            notifyLanguageChange()
        }
    }

    // MARK: - Private Properties
    private let languageKey = "AppLanguagePreference"
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private init() {
        // Load preference: UserDefaults → Device Language → Italian
        if let savedLanguage = loadLanguagePreference() {
            self.currentLanguage = savedLanguage
        } else {
            self.currentLanguage = AppLanguage.deviceLanguage
        }

        updateLocale()
    }

    // MARK: - Public Methods
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }

    // MARK: - Private Methods
    private func saveLanguagePreference() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
    }

    private func loadLanguagePreference() -> AppLanguage? {
        guard let rawValue = UserDefaults.standard.string(forKey: languageKey) else {
            return nil
        }
        return AppLanguage(rawValue: rawValue)
    }

    private func updateLocale() {
        Bundle.setLanguage(currentLanguage.rawValue)
    }

    private func notifyLanguageChange() {
        NotificationCenter.default.post(
            name: .languageDidChange,
            object: currentLanguage
        )
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let languageDidChange = Notification.Name("LanguageDidChangeNotification")
}

// MARK: - Bundle Extension

private var bundleKey: UInt8 = 0

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, PrivateBundle.self)
        }

        objc_setAssociatedObject(
            Bundle.main,
            &bundleKey,
            Bundle.main.path(forResource: language, ofType: "lproj"),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}

private class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

// MARK: - Type-Safe Localization Keys

enum LocalizedKeys: String {
    // MARK: - General
    case appName = "app.name"
    case cancel = "general.cancel"
    case save = "general.save"
    case delete = "general.delete"
    case confirm = "general.confirm"
    case error = "general.error"
    case success = "general.success"
    case loading = "general.loading"

    // MARK: - Authentication
    case authTitle = "auth.title"
    case authSubtitle = "auth.subtitle"
    case authSignIn = "auth.signIn"
    case authSignOut = "auth.signOut"
    case authError = "auth.error"

    // MARK: - Settings
    case settingsTitle = "settings.title"
    case settingsLanguage = "settings.language"
    case settingsTheme = "settings.theme"

    // TODO: Add your app-specific keys here

    // MARK: - Localization
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }

    func localized(with args: CVarArg...) -> String {
        String(format: localized, arguments: args)
    }
}

// MARK: - String Extension

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func localized(with args: CVarArg...) -> String {
        String(format: self.localized, arguments: args)
    }
}

// MARK: - Formatters

class CurrencyFormatter {
    static let shared = CurrencyFormatter()

    private init() {}

    func format(_ value: Double, language: AppLanguage = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = language.locale

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

class DateFormatterHelper {
    static let shared = DateFormatterHelper()

    private init() {}

    func formatShort(_ date: Date, language: AppLanguage = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = language.locale

        return formatter.string(from: date)
    }

    func formatLong(_ date: Date, language: AppLanguage = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = language.locale

        return formatter.string(from: date)
    }
}

// MARK: - SwiftUI Usage Example

/*
 // In your App entry point:
 @main
 struct YourApp: App {
     @StateObject private var localizationManager = LocalizationManager.shared

     var body: some Scene {
         WindowGroup {
             ContentView()
                 .environmentObject(localizationManager)
         }
     }
 }

 // In your views:
 struct ContentView: View {
     @EnvironmentObject var localizationManager: LocalizationManager

     var body: some View {
         VStack {
             Text(LocalizedKeys.appName.localized)
                 .font(.title)

             Text(LocalizedKeys.authSubtitle.localized)
                 .font(.body)
         }
     }
 }

 // Language picker:
 struct LanguagePickerView: View {
     @EnvironmentObject var localizationManager: LocalizationManager

     var body: some View {
         List {
             ForEach(AppLanguage.allCases) { language in
                 Button {
                     withAnimation {
                         localizationManager.setLanguage(language)
                     }
                 } label: {
                     HStack {
                         Text(language.flag)
                             .font(.title2)

                         Text(language.nativeName)
                             .font(.body)

                         Spacer()

                         if localizationManager.currentLanguage == language {
                             Image(systemName: "checkmark")
                                 .foregroundStyle(.blue)
                         }
                     }
                 }
             }
         }
         .navigationTitle(LocalizedKeys.settingsLanguage.localized)
     }
 }
 */

// MARK: - Localizable.strings File Templates

/*
 Create these files in your project:

 it.lproj/Localizable.strings:
 ```
 "app.name" = "La Tua App";
 "general.cancel" = "Annulla";
 "general.save" = "Salva";
 "auth.title" = "Benvenuto";
 ```

 fr.lproj/Localizable.strings:
 ```
 "app.name" = "Votre App";
 "general.cancel" = "Annuler";
 "general.save" = "Enregistrer";
 "auth.title" = "Bienvenue";
 ```

 en.lproj/Localizable.strings:
 ```
 "app.name" = "Your App";
 "general.cancel" = "Cancel";
 "general.save" = "Save";
 "auth.title" = "Welcome";
 ```
 */
