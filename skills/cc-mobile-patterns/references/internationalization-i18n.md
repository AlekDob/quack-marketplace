# Internationalization (i18n) Patterns

All C&C mobile apps support multiple languages with seamless switching and Supabase synchronization.

## Supported Languages

Standard language support across all apps:
- 🇮🇹 **Italian** (`it`) - Primary market, default language
- 🇫🇷 **French** (`fr`) - French market
- 🇬🇧 **English** (`en`) - International fallback

## AppLanguage Enum Pattern

```swift
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
```

## LocalizationManager Pattern

```swift
import Foundation
import Combine

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
```

## Bundle Extension for Language Loading

```swift
import Foundation

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
```

## Type-Safe Localization Keys

```swift
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

    // MARK: - Products
    case productsTitle = "products.title"
    case productsSearchPlaceholder = "products.search.placeholder"
    case productsAvailable = "products.available"
    case productsOutOfStock = "products.outOfStock"
    case productsAddToCart = "products.addToCart"

    // MARK: - Filters
    case filterTitle = "filter.title"
    case filterApply = "filter.apply"
    case filterClear = "filter.clear"
    case filterActiveCount = "filter.activeCount"
    case filterNoResults = "filter.noResults"

    // MARK: - Team
    case teamTitle = "team.title"
    case teamSearchPlaceholder = "team.search.placeholder"
    case teamMemberCount = "team.memberCount"
    case teamNoMembers = "team.noMembers"

    // MARK: - Stores
    case storesTitle = "stores.title"
    case storesSearchPlaceholder = "stores.search.placeholder"
    case storesOpenNow = "stores.openNow"
    case storesClosed = "stores.closed"

    // MARK: - Settings
    case settingsTitle = "settings.title"
    case settingsLanguage = "settings.language"
    case settingsTheme = "settings.theme"
    case settingsNotifications = "settings.notifications"

    // MARK: - Localization
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }

    func localized(with args: CVarArg...) -> String {
        String(format: localized, arguments: args)
    }
}
```

## String Extension for Localization

```swift
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func localized(with args: CVarArg...) -> String {
        String(format: self.localized, arguments: args)
    }
}
```

## Localizable.strings Structure

### it.lproj/Localizable.strings (Italian)

```
/* General */
"app.name" = "C&C Team";
"general.cancel" = "Annulla";
"general.save" = "Salva";
"general.delete" = "Elimina";
"general.confirm" = "Conferma";
"general.error" = "Errore";
"general.success" = "Successo";
"general.loading" = "Caricamento...";

/* Authentication */
"auth.title" = "Benvenuto";
"auth.subtitle" = "Accedi con il tuo account aziendale";
"auth.signIn" = "Accedi";
"auth.signOut" = "Esci";
"auth.error" = "Errore di autenticazione";

/* Products */
"products.title" = "Prodotti";
"products.search.placeholder" = "Cerca prodotti...";
"products.available" = "%d disponibili";
"products.outOfStock" = "Esaurito";
"products.addToCart" = "Aggiungi al carrello";

/* Filters */
"filter.title" = "Filtri";
"filter.apply" = "Applica";
"filter.clear" = "Cancella";
"filter.activeCount" = "%d filtri attivi";
"filter.noResults" = "Nessun risultato";

/* Team */
"team.title" = "Team";
"team.search.placeholder" = "Cerca membri...";
"team.memberCount" = "%d membri";
"team.noMembers" = "Nessun membro trovato";

/* Stores */
"stores.title" = "Negozi";
"stores.search.placeholder" = "Cerca negozi...";
"stores.openNow" = "Aperto ora";
"stores.closed" = "Chiuso";

/* Settings */
"settings.title" = "Impostazioni";
"settings.language" = "Lingua";
"settings.theme" = "Tema";
"settings.notifications" = "Notifiche";
```

### fr.lproj/Localizable.strings (French)

```
/* General */
"app.name" = "C&C Team";
"general.cancel" = "Annuler";
"general.save" = "Enregistrer";
"general.delete" = "Supprimer";
"general.confirm" = "Confirmer";
"general.error" = "Erreur";
"general.success" = "Succès";
"general.loading" = "Chargement...";

/* Authentication */
"auth.title" = "Bienvenue";
"auth.subtitle" = "Connectez-vous avec votre compte professionnel";
"auth.signIn" = "Se connecter";
"auth.signOut" = "Se déconnecter";
"auth.error" = "Erreur d'authentification";

/* Products */
"products.title" = "Produits";
"products.search.placeholder" = "Rechercher des produits...";
"products.available" = "%d disponibles";
"products.outOfStock" = "Épuisé";
"products.addToCart" = "Ajouter au panier";

/* Filters */
"filter.title" = "Filtres";
"filter.apply" = "Appliquer";
"filter.clear" = "Effacer";
"filter.activeCount" = "%d filtres actifs";
"filter.noResults" = "Aucun résultat";

/* Team */
"team.title" = "Équipe";
"team.search.placeholder" = "Rechercher des membres...";
"team.memberCount" = "%d membres";
"team.noMembers" = "Aucun membre trouvé";

/* Stores */
"stores.title" = "Magasins";
"stores.search.placeholder" = "Rechercher des magasins...";
"stores.openNow" = "Ouvert maintenant";
"stores.closed" = "Fermé";

/* Settings */
"settings.title" = "Paramètres";
"settings.language" = "Langue";
"settings.theme" = "Thème";
"settings.notifications" = "Notifications";
```

### en.lproj/Localizable.strings (English)

```
/* General */
"app.name" = "C&C Team";
"general.cancel" = "Cancel";
"general.save" = "Save";
"general.delete" = "Delete";
"general.confirm" = "Confirm";
"general.error" = "Error";
"general.success" = "Success";
"general.loading" = "Loading...";

/* Authentication */
"auth.title" = "Welcome";
"auth.subtitle" = "Sign in with your business account";
"auth.signIn" = "Sign In";
"auth.signOut" = "Sign Out";
"auth.error" = "Authentication error";

/* Products */
"products.title" = "Products";
"products.search.placeholder" = "Search products...";
"products.available" = "%d available";
"products.outOfStock" = "Out of stock";
"products.addToCart" = "Add to cart";

/* Filters */
"filter.title" = "Filters";
"filter.apply" = "Apply";
"filter.clear" = "Clear";
"filter.activeCount" = "%d active filters";
"filter.noResults" = "No results";

/* Team */
"team.title" = "Team";
"team.search.placeholder" = "Search members...";
"team.memberCount" = "%d members";
"team.noMembers" = "No members found";

/* Stores */
"stores.title" = "Stores";
"stores.search.placeholder" = "Search stores...";
"stores.openNow" = "Open now";
"stores.closed" = "Closed";

/* Settings */
"settings.title" = "Settings";
"settings.language" = "Language";
"settings.theme" = "Theme";
"settings.notifications" = "Notifications";
```

## Usage in SwiftUI

### Basic Usage

```swift
struct ProductView: View {
    var body: some View {
        VStack {
            Text(LocalizedKeys.productsTitle.localized)
                .font(.title)

            Text(LocalizedKeys.productsSearchPlaceholder.localized)
                .foregroundStyle(.secondary)
        }
    }
}
```

### With String Interpolation

```swift
struct ProductListView: View {
    let productCount: Int

    var body: some View {
        Text(LocalizedKeys.productsAvailable.localized(with: productCount))
            .font(.caption)
    }
}
```

### Language Picker View

```swift
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
```

## Supabase Language Sync (Optional)

```swift
extension LocalizationManager {
    func syncLanguageToSupabase() async {
        guard let userId = SupabaseAuthManager.shared.currentUser?.id else {
            return
        }

        do {
            try await SupabaseClientManager.shared.client
                .from("profiles")
                .update(["software_language": currentLanguage.rawValue])
                .eq("id", value: userId.uuidString)
                .execute()
        } catch {
            print("Failed to sync language to Supabase: \(error)")
        }
    }

    func loadLanguageFromSupabase() async {
        guard let userId = SupabaseAuthManager.shared.currentUser?.id else {
            return
        }

        do {
            struct LanguageResponse: Codable {
                let softwareLanguage: String?

                enum CodingKeys: String, CodingKey {
                    case softwareLanguage = "software_language"
                }
            }

            let response = try await SupabaseClientManager.shared.client
                .from("profiles")
                .select("software_language")
                .eq("id", value: userId.uuidString)
                .single()
                .execute()

            let languageResponse = try JSONDecoder().decode(LanguageResponse.self, from: response.data)

            if let languageCode = languageResponse.softwareLanguage,
               let language = AppLanguage(rawValue: languageCode) {
                await MainActor.run {
                    self.currentLanguage = language
                }
            }
        } catch {
            print("Failed to load language from Supabase: \(error)")
        }
    }
}
```

## Date and Number Formatting

### Currency Formatting

```swift
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

// Usage
let price = CurrencyFormatter.shared.format(99.99)
// Italian: "99,99 €"
// French: "99,99 €"
// English: "$99.99"
```

### Date Formatting

```swift
class DateFormatter {
    static let shared = DateFormatter()

    private init() {}

    func formatShort(_ date: Date, language: AppLanguage = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = language.locale

        return formatter.string(from: date)
    }

    func formatLong(_ date: Date, language: AppLanguage = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = language.locale

        return formatter.string(from: date)
    }
}

// Usage
let date = Date()
let shortDate = DateFormatter.shared.formatShort(date)
// Italian: "23/11/24"
// French: "23/11/24"
// English: "11/23/24"
```

## Best Practices

### DO:
✅ Use type-safe `LocalizedKeys` enum
✅ Provide all translations before release
✅ Test all languages in UI
✅ Use semantic keys (`products.title`) not hardcoded text
✅ Support string interpolation with `%d`, `%@` format specifiers
✅ Respect device language as default
✅ Persist language preference
✅ Use native language names in picker ("Italiano", not "Italian")
✅ Format dates and numbers according to locale
✅ Test right-to-left languages if supporting Arabic/Hebrew

### DON'T:
❌ Hardcode UI text in views
❌ Use generic keys like `title1`, `label2`
❌ Forget to translate error messages
❌ Skip pluralization rules (use `.stringsdict` for complex plurals)
❌ Mix languages in UI
❌ Use machine translation without native speaker review
❌ Assume all languages have same text length (design for expansion)
❌ Forget to localize accessibility labels

## Testing Localization

```swift
// SwiftUI Preview with different languages
struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProductView()
                .environment(\.locale, Locale(identifier: "it_IT"))
                .previewDisplayName("Italian")

            ProductView()
                .environment(\.locale, Locale(identifier: "fr_FR"))
                .previewDisplayName("French")

            ProductView()
                .environment(\.locale, Locale(identifier: "en_US"))
                .previewDisplayName("English")
        }
    }
}
```

## Adding New Languages

1. Add case to `AppLanguage` enum
2. Create `.lproj` folder (e.g., `de.lproj/`)
3. Copy `Localizable.strings` from `en.lproj/`
4. Translate all strings
5. Test UI with new language
6. Update language picker

Example: Adding German support

```swift
enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case italian = "it"
    case french = "fr"
    case english = "en"
    case german = "de"  // New language

    var flag: String {
        switch self {
        case .italian: return "🇮🇹"
        case .french: return "🇫🇷"
        case .english: return "🇬🇧"
        case .german: return "🇩🇪"  // New flag
        }
    }

    var locale: Locale {
        switch self {
        case .italian: return Locale(identifier: "it_IT")
        case .french: return Locale(identifier: "fr_FR")
        case .english: return Locale(identifier: "en_US")
        case .german: return Locale(identifier: "de_DE")  // New locale
        }
    }
}
```
