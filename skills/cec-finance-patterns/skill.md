---
name: cec-finance-patterns
description: Financial data and multi-currency patterns for C&C applications. Handles EUR + local currency display (SEK, DKK), YoY calculations, margin analytics, and BI API integration. Use this skill when working with currency formatting, revenue data, or financial displays.
trigger: when working with financial data, currency formatting, BI APIs, revenue analytics, or multi-currency display in C&C projects
---

# C&C Finance Patterns - Multi-Currency & Financial Data

## Overview

This skill provides patterns and best practices for handling financial data in C&C applications across 8 European countries, including:
- **Multi-currency display** (EUR as base, SEK/DKK as local)
- **Dual currency formatting** (primary + secondary)
- **BI API integration** with response models
- **YoY (Year-over-Year) calculations**
- **Margin and revenue analytics**

---

## Currency System

### The Golden Rules

1. **API always returns TWO values**: `net_revenue` (EUR) and `net_revenue_local` (local currency)
2. **EUR is the base currency** - all `*_local` fields contain local currency values
3. **User preference determines display order** - which currency is primary vs secondary
4. **Always show both currencies** for non-EUR countries (Sweden, Denmark)

### Currency Codes by Country

| Country | Tenant Code | Currency | Symbol | Has Local? |
|---------|-------------|----------|--------|------------|
| Italy | `it` | EUR | € | No (same) |
| France | `fr` | EUR | € | No (same) |
| Latvia | `lv` | EUR | € | No (same) |
| Estonia | `ee` | EUR | € | No (same) |
| Finland | `fi` | EUR | € | No (same) |
| Lithuania | `lt` | EUR | € | No (same) |
| **Sweden** | `se` | **SEK** | kr | **Yes** |
| **Denmark** | `dk` | **DKK** | kr | **Yes** |

### API Response Field Mapping

```
net_revenue          → Always EUR (base currency)
net_revenue_local    → Local currency (SEK/DKK for Nordic, EUR for others)

total                → Always EUR
total_local          → Local currency

total_gain           → Always EUR
total_gain_local     → Local currency

yoy_absolute         → Always EUR (can be null)
yoy_absolute_local   → Local currency (can be null)
```

### Example: Italy vs Sweden Response

**Italy (EUR country):**
```json
{
    "currency": "EUR",
    "net_revenue": 176325052.3,
    "net_revenue_local": 176325052.3,  // Same as net_revenue
    "total_gain": 20703378.04,
    "total_gain_local": 20703378.04    // Same as total_gain
}
```

**Sweden (SEK country):**
```json
{
    "currency": "SEK",
    "net_revenue": 34604928.12,         // EUR value
    "net_revenue_local": 395484892.71,  // SEK value (~11.4x exchange rate)
    "total_gain": 5565591.84,           // EUR value
    "total_gain_local": 63606764.04     // SEK value
}
```

---

## Display Patterns

### Formatting Rules

**Format: `[SYMBOL] [VALUE][SUFFIX]`**

| Value Range | Format | Example |
|-------------|--------|---------|
| ≥ 1,000,000 | X.XM | € 1,2M |
| ≥ 1,000 | X.XK | € 316K |
| < 1,000 | X | € 850 |

### Dual Currency Display

For non-EUR countries, always show both currencies:

```swift
// Primary currency (larger)
Text("kr 395,5M")
    .font(.title2.weight(.bold))

// Secondary currency (smaller, below)
Text("€ 34,6M")
    .font(.caption)
    .foregroundStyle(.secondary)
```

### User Preference Logic

```swift
enum CurrencyDisplayPreference: String {
    case eurAsPrimary    // € 34,6M (primary) / kr 395,5M (secondary)
    case localAsPrimary  // kr 395,5M (primary) / € 34,6M (secondary)
}

// Default based on user's country:
// - EUR countries → eurAsPrimary (no secondary shown)
// - SEK/DKK countries → localAsPrimary (with EUR as secondary)
```

### Swift Implementation

```swift
/// Format currency pair for display
struct CurrencyPair {
    let primaryValue: String
    let secondaryValue: String?

    static func format(
        eurValue: Double,
        localValue: Double,
        localCurrencyCode: String,
        preference: CurrencyDisplayPreference
    ) -> CurrencyPair {
        let hasLocalCurrency = localCurrencyCode != "EUR"

        if !hasLocalCurrency {
            // EUR country - only show EUR
            return CurrencyPair(
                primaryValue: formatCurrency(eurValue, code: "EUR"),
                secondaryValue: nil
            )
        }

        // Non-EUR country - show both based on preference
        switch preference {
        case .localAsPrimary:
            return CurrencyPair(
                primaryValue: formatCurrency(localValue, code: localCurrencyCode),
                secondaryValue: formatCurrency(eurValue, code: "EUR")
            )
        case .eurAsPrimary:
            return CurrencyPair(
                primaryValue: formatCurrency(eurValue, code: "EUR"),
                secondaryValue: formatCurrency(localValue, code: localCurrencyCode)
            )
        }
    }
}

/// Format single currency value
func formatCurrency(_ value: Double, code: String) -> String {
    let symbol = code == "EUR" ? "€" : "kr"
    let (scaled, suffix) = scaleValue(abs(value))

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = suffix.isEmpty ? 0 : 1
    formatter.decimalSeparator = ","
    formatter.groupingSeparator = "."

    var formatted = formatter.string(from: NSNumber(value: scaled)) ?? "\(Int(scaled))"
    if formatted.hasSuffix(",0") {
        formatted = String(formatted.dropLast(2))
    }

    let sign = value < 0 ? "-" : ""
    return "\(sign)\(symbol) \(formatted)\(suffix)"
}

func scaleValue(_ value: Double) -> (Double, String) {
    if value >= 1_000_000 { return (value / 1_000_000, "M") }
    if value >= 1_000 { return (value / 1_000, "K") }
    return (value, "")
}
```

---

## BI API Reference

### Base URL
```
https://flow.cec.com/erp/stats
```

### Endpoints

| Endpoint | Description |
|----------|-------------|
| `/country-revenue` | Global KPIs by country |
| `/store-revenue` | Revenue by store |
| `/agents-revenue` | Revenue by sales agent |
| `/maker-revenue` | Revenue by brand/maker |
| `/category-revenue` | Revenue by category |
| `/sub-category-revenue` | Revenue by subcategory |

### Request Headers

```swift
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.setValue("application/json", forHTTPHeaderField: "Accept")
request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
request.setValue("EUR", forHTTPHeaderField: "x-currency")
request.setValue(tenantCode, forHTTPHeaderField: "x-tenant")  // "it", "se", "it,fr,se,dk,..."
request.setValue("https://flow.cec.com", forHTTPHeaderField: "Origin")
```

### Request Body

```json
{
    "startDate": "2025-01-01",
    "endDate": "2025-12-31",
    "filters": {
        "numbering": ["STORE001"],
        "agent": ["Agent Name"],
        "makers": ["Apple"],
        "category": ["Smartphones"],
        "subcategory": ["iPhone"]
    }
}
```

### Response Model (Swift)

```swift
/// Main response from country-revenue endpoint
struct CountryRevenueResponse: Codable {
    let documentCount: Int
    let total: Double                    // EUR
    let totalLocal: Double               // Local currency
    let totalPrevYear: Double            // EUR
    let totalPrevYearLocal: Double       // Local currency
    let totalGain: Double                // EUR
    let totalGainLocal: Double           // Local currency
    let margin: Double
    let yoyAbsolute: Double?             // EUR (nullable)
    let yoyAbsoluteLocal: Double?        // Local (nullable)
    let yoyPercentage: Double?           // Percentage (nullable)
    let months: [MonthlyRevenue]
    let countries: [CountryRevenue]
    let lastUpdatedAt: String?

    enum CodingKeys: String, CodingKey {
        case documentCount = "document_count"
        case total, totalLocal = "total_local"
        case totalPrevYear = "total_prev_year"
        case totalPrevYearLocal = "total_prev_year_local"
        case totalGain = "total_gain"
        case totalGainLocal = "total_gain_local"
        case margin
        case yoyAbsolute = "yoy_absolute"
        case yoyAbsoluteLocal = "yoy_absolute_local"
        case yoyPercentage = "yoy_percentage"
        case months, countries
        case lastUpdatedAt = "last_updated_at"
    }
}

/// Monthly breakdown
struct MonthlyRevenue: Codable {
    let year: Int
    let month: Int
    let documentCount: Int
    let netRevenue: Double               // EUR
    let netRevenueLocal: Double          // Local currency
    let netRevenuePrevYear: Double       // EUR
    let netRevenuePrevYearLocal: Double  // Local currency
    let totalGain: Double                // EUR
    let totalGainLocal: Double           // Local currency
    let margin: Double
    let yoyAbsolute: Double?             // EUR (nullable)
    let yoyAbsoluteLocal: Double?        // Local (nullable)
    let yoyPercentage: Double?           // Percentage (nullable)

    enum CodingKeys: String, CodingKey {
        case year, month
        case documentCount = "document_count"
        case netRevenue = "net_revenue"
        case netRevenueLocal = "net_revenue_local"
        case netRevenuePrevYear = "net_revenue_prev_year"
        case netRevenuePrevYearLocal = "net_revenue_prev_year_local"
        case totalGain = "total_gain"
        case totalGainLocal = "total_gain_local"
        case margin
        case yoyAbsolute = "yoy_absolute"
        case yoyAbsoluteLocal = "yoy_absolute_local"
        case yoyPercentage = "yoy_percentage"
    }
}

/// Country breakdown within response
struct CountryRevenue: Codable {
    let currency: String                 // "EUR", "SEK", "DKK"
    let country: String                  // "it", "se", "dk"
    let tenant: String
    let documentCount: Int
    let netRevenue: Double               // EUR
    let netRevenueLocal: Double          // Local currency
    let netRevenuePrevYear: Double       // EUR
    let netRevenuePrevYearLocal: Double  // Local currency
    let totalGain: Double                // EUR
    let totalGainLocal: Double           // Local currency
    let margin: Double
    let yoyAbsolute: Double?
    let yoyAbsoluteLocal: Double?
    let yoyPercentage: Double?
    let months: [MonthlyRevenue]

    enum CodingKeys: String, CodingKey {
        case currency, country, tenant
        case documentCount = "document_count"
        case netRevenue = "net_revenue"
        case netRevenueLocal = "net_revenue_local"
        case netRevenuePrevYear = "net_revenue_prev_year"
        case netRevenuePrevYearLocal = "net_revenue_prev_year_local"
        case totalGain = "total_gain"
        case totalGainLocal = "total_gain_local"
        case margin
        case yoyAbsolute = "yoy_absolute"
        case yoyAbsoluteLocal = "yoy_absolute_local"
        case yoyPercentage = "yoy_percentage"
        case months
    }
}
```

---

## YoY Calculations

### Important Notes

- **YoY fields can be `null`** - especially for new countries without previous year data (e.g., Sweden)
- Always handle nil gracefully in UI

### Formula
```
YoY % = ((Current - Previous) / Previous) × 100
```

### Display Rules
- **Positive**: Green, arrow up ↗️
- **Negative**: Red, arrow down ↘️
- **Null**: Show "—" or hide the badge

```swift
func formatYoY(_ percentage: Double?) -> String? {
    guard let pct = percentage else { return nil }
    let sign = pct >= 0 ? "+" : ""
    return "\(sign)\(String(format: "%.1f", pct))%"
}
```

---

## User Preference Storage

### Database (Supabase)

Table: `members` / `member_details_api`

| Field | Type | Description |
|-------|------|-------------|
| `country` | text | User's country (IT, SE, DK, etc.) |
| `setting_country` | text | Selected view country |
| `setting_currency_primary` | text | Currency preference (new field) |

### Default Logic

```swift
func defaultCurrencyPreference(for userCountry: String) -> CurrencyDisplayPreference {
    switch userCountry.uppercased() {
    case "SE", "DK":
        return .localAsPrimary  // kr as primary, € as secondary
    default:
        return .eurAsPrimary    // € only (no secondary for EUR countries)
    }
}
```

---

## SwiftUI Component Pattern

```swift
struct DualCurrencyText: View {
    let eurValue: Double
    let localValue: Double
    let localCurrencyCode: String
    @ObservedObject var preferences: CurrencyPreferenceManager

    var body: some View {
        let pair = CurrencyPair.format(
            eurValue: eurValue,
            localValue: localValue,
            localCurrencyCode: localCurrencyCode,
            preference: preferences.displayPreference
        )

        VStack(alignment: .leading, spacing: 2) {
            // Primary
            Text(pair.primaryValue)
                .font(.headline.weight(.bold))

            // Secondary (if exists)
            if let secondary = pair.secondaryValue {
                Text(secondary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

---

## Tenant Codes Reference

| Display Name | API Code | Currency |
|--------------|----------|----------|
| Global | `it,fr,lv,ee,fi,se,dk,lt` | Mixed |
| Italia | `it` | EUR |
| France | `fr` | EUR |
| Sverige | `se` | SEK |
| Danmark | `dk` | DKK |
| Suomi | `fi` | EUR |
| Eesti | `ee` | EUR |
| Lietuva | `lt` | EUR |
| Latvija | `lv` | EUR |

---

**Last Updated**: 2025-12-18
**Author**: C&C Development Team
