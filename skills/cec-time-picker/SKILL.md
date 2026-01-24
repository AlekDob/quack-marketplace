---
name: cec-time-picker
description: This skill provides the C&C Apple-style time picker pattern for SwiftUI iOS apps. Use this skill when implementing time/date range filtering with granularity options (Day, Week, Month, Quarter, Year) in any C&C iOS application. It includes the segmented control UI pattern, date range calculation logic, and ViewModel integration best practices.
---

# CEC Time Picker

## Overview

Apple-style time picker pattern for SwiftUI iOS applications featuring a segmented control for granularity selection (Day/Week/Month/Quarter/Year) with navigation arrows for period traversal. This pattern is used across C&C apps for consistent UX in stats, analytics, and reporting views.

## When to Use

- Implementing time-based filtering for statistics, analytics, or reports
- Adding period selection to dashboards
- Creating date range pickers with multiple granularity options
- Building views that need Day/Week/Month/Quarter/Year navigation

## Architecture Pattern

The pattern consists of 3 core components:

### 1. Time Granularity Enum
Defines the available granularity options with display properties.

### 2. Time Period Struct
Represents a specific period with start/end dates and display labels.

### 3. Date Range Manager
Handles date calculations, period navigation, and boundary checking.

## Implementation Guide

### Step 1: Create the Model Layer

Create a file named `TimeGranularity.swift` with these components:

```swift
// Time granularity options
enum TimeGranularity: String, CaseIterable, Identifiable {
    case day = "day"
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"

    var id: String { rawValue }

    // Short labels for segmented control
    var shortLabel: String {
        switch self {
        case .day: return "G"       // Giorno
        case .week: return "S"      // Settimana
        case .month: return "M"     // Mese
        case .quarter: return "T"   // Trimestre
        case .year: return "A"      // Anno
        }
    }

    // SF Symbol icons
    var icon: String {
        switch self {
        case .day: return "sun.max"
        case .week: return "calendar.badge.clock"
        case .month: return "calendar"
        case .quarter: return "chart.bar.xaxis"
        case .year: return "chart.line.uptrend.xyaxis"
        }
    }

    // Brand colors per granularity
    var color: Color {
        switch self {
        case .day: return .orange
        case .week: return .purple
        case .month: return .blue
        case .quarter: return .green
        case .year: return .indigo
        }
    }
}
```

### Step 2: Create Quarter Enum

```swift
enum Quarter: Int, CaseIterable, Identifiable {
    case q1 = 1, q2 = 2, q3 = 3, q4 = 4

    var id: Int { rawValue }
    var displayName: String { "Q\(rawValue)" }

    var startMonth: Int {
        switch self {
        case .q1: return 1
        case .q2: return 4
        case .q3: return 7
        case .q4: return 10
        }
    }

    var endMonth: Int {
        switch self {
        case .q1: return 3
        case .q2: return 6
        case .q3: return 9
        case .q4: return 12
        }
    }

    static func from(month: Int) -> Quarter {
        switch month {
        case 1...3: return .q1
        case 4...6: return .q2
        case 7...9: return .q3
        default: return .q4
        }
    }

    static var current: Quarter {
        from(month: Calendar.current.component(.month, from: Date()))
    }
}
```

### Step 3: Create Time Period Struct

```swift
struct TimePeriod: Equatable {
    let granularity: TimeGranularity
    let startDate: Date
    let endDate: Date
    let day: Int?
    let week: Int?
    let month: Int?
    let quarter: Quarter?
    let year: Int

    // API-ready date strings (YYYY-MM-DD)
    var startDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: startDate)
    }

    var endDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: endDate)
    }

    // Display label based on granularity
    var displayLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")

        switch granularity {
        case .day:
            formatter.dateFormat = "d MMMM yyyy"
            return formatter.string(from: startDate).capitalized
        case .week:
            formatter.dateFormat = "d MMM"
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: startDate).capitalized
        case .quarter:
            return quarter.map { "\($0.displayName) \(year)" } ?? "\(year)"
        case .year:
            return String(year)
        }
    }
}
```

### Step 4: Create Date Range Manager

See `references/DateRangeManager.swift` for the complete implementation with:
- `currentPeriod(for:)` - Get current period for granularity
- `previousPeriod(from:)` - Navigate backwards
- `nextPeriod(from:)` - Navigate forwards
- `canNavigateNext(from:)` - Check future boundary
- `canNavigatePrevious(from:)` - Check past boundary (2 years default)
- Period builders: `dayPeriod`, `weekPeriod`, `monthPeriod`, `quarterPeriod`, `yearPeriod`

### Step 5: Create the SwiftUI Component

See `references/TimePicker.swift` for the complete UI component featuring:
- Segmented control with 5 granularity buttons
- Navigation row with ← Period → arrows
- Year picker dropdown when in year mode
- Smooth animations on navigation
- Dark/light mode support with materials

### Step 6: Integrate with ViewModel

Add these properties to your ViewModel:

```swift
@MainActor
class MyViewModel: ObservableObject {
    // Time filtering properties
    @Published var selectedGranularity: TimeGranularity = .month
    @Published var selectedPeriod: TimePeriod
    @Published var selectedYear: Int

    private let dateRangeManager = DateRangeManager()

    init() {
        let now = Date()
        self.selectedYear = Calendar.current.component(.year, from: now)
        self.selectedPeriod = DateRangeManager().currentPeriod(for: .month)
    }

    // Call this when period changes
    func onPeriodChange() {
        Task {
            await loadData()
        }
    }

    func loadData() async {
        // Use selectedPeriod.startDateString and endDateString for API calls
        let startDate = selectedPeriod.startDateString
        let endDate = selectedPeriod.endDateString
        // ... fetch data
    }
}
```

### Step 7: Use in View

```swift
struct MyStatsView: View {
    @StateObject private var viewModel = MyViewModel()

    private var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 4)...currentYear).reversed()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time Picker
                TimePicker(
                    selectedGranularity: $viewModel.selectedGranularity,
                    selectedPeriod: $viewModel.selectedPeriod,
                    selectedYear: $viewModel.selectedYear,
                    availableYears: availableYears,
                    onPeriodChange: viewModel.onPeriodChange
                )

                // Your content here
            }
            .padding(20)
        }
    }
}
```

## Localization

Add these keys to your Localizable.strings:

```
// Italian (it.lproj)
"time.granularity_day" = "Giorno";
"time.granularity_week" = "Settimana";
"time.granularity_month" = "Mese";
"time.granularity_quarter" = "Trimestre";
"time.granularity_year" = "Anno";
"time.quarter_q1" = "1° Trimestre";
"time.quarter_q2" = "2° Trimestre";
"time.quarter_q3" = "3° Trimestre";
"time.quarter_q4" = "4° Trimestre";

// English (en.lproj)
"time.granularity_day" = "Day";
"time.granularity_week" = "Week";
"time.granularity_month" = "Month";
"time.granularity_quarter" = "Quarter";
"time.granularity_year" = "Year";
"time.quarter_q1" = "Q1";
"time.quarter_q2" = "Q2";
"time.quarter_q3" = "Q3";
"time.quarter_q4" = "Q4";

// French (fr.lproj)
"time.granularity_day" = "Jour";
"time.granularity_week" = "Semaine";
"time.granularity_month" = "Mois";
"time.granularity_quarter" = "Trimestre";
"time.granularity_year" = "Année";
"time.quarter_q1" = "T1";
"time.quarter_q2" = "T2";
"time.quarter_q3" = "T3";
"time.quarter_q4" = "T4";
```

## Design Guidelines

### UI Best Practices
- Use `.ultraThinMaterial` for backgrounds (Apple Liquid Glass style)
- Apply `.lineLimit(1).fixedSize(horizontal: true, vertical: false)` to prevent text wrapping
- Use `RoundedRectangle(cornerRadius: 16)` for cards
- Add subtle shadows: `.shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)`

### Week Calculation
Weeks are calculated Monday-to-Sunday (ISO standard):
```swift
var cal = calendar
cal.firstWeekday = 2 // Monday
```

### Navigation Limits
- **Past**: 2 years maximum
- **Future**: Cannot navigate beyond current date

## Resources

- `references/DateRangeManager.swift` - Complete date calculation logic
- `references/TimePicker.swift` - Complete SwiftUI component
- `references/TimeGranularity.swift` - Complete model layer
