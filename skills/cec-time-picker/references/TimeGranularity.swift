//
//  TimeGranularity.swift
//  CEC Time Picker Pattern
//
//  Complete model layer for Apple-style time filtering
//  Supports: Day, Week, Month, Quarter, Year
//

import Foundation
import SwiftUI

// MARK: - Time Granularity Enum

/// Time granularity options for display
enum TimeGranularity: String, CaseIterable, Identifiable {
    case day = "day"
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"

    var id: String { rawValue }

    // MARK: - Display Properties

    /// Short label for segmented control (single letter - Italian)
    var shortLabel: String {
        switch self {
        case .day: return "G"       // Giorno
        case .week: return "S"      // Settimana
        case .month: return "M"     // Mese
        case .quarter: return "T"   // Trimestre
        case .year: return "A"      // Anno
        }
    }

    /// Full localized name - customize with your localization system
    var localizedName: String {
        switch self {
        case .day: return NSLocalizedString("time.granularity_day", comment: "Day")
        case .week: return NSLocalizedString("time.granularity_week", comment: "Week")
        case .month: return NSLocalizedString("time.granularity_month", comment: "Month")
        case .quarter: return NSLocalizedString("time.granularity_quarter", comment: "Quarter")
        case .year: return NSLocalizedString("time.granularity_year", comment: "Year")
        }
    }

    /// SF Symbol icon for this granularity
    var icon: String {
        switch self {
        case .day: return "sun.max"
        case .week: return "calendar.badge.clock"
        case .month: return "calendar"
        case .quarter: return "chart.bar.xaxis"
        case .year: return "chart.line.uptrend.xyaxis"
        }
    }

    /// Color for this granularity (C&C brand-aligned)
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

// MARK: - Quarter Enum

/// Quarter representation (Q1, Q2, Q3, Q4) - Apple fiscal style
enum Quarter: Int, CaseIterable, Identifiable {
    case q1 = 1
    case q2 = 2
    case q3 = 3
    case q4 = 4

    var id: Int { rawValue }

    /// Display name (Q1, Q2, etc.)
    var displayName: String {
        "Q\(rawValue)"
    }

    /// Full localized name - customize with your localization system
    var localizedName: String {
        switch self {
        case .q1: return NSLocalizedString("time.quarter_q1", comment: "Q1")
        case .q2: return NSLocalizedString("time.quarter_q2", comment: "Q2")
        case .q3: return NSLocalizedString("time.quarter_q3", comment: "Q3")
        case .q4: return NSLocalizedString("time.quarter_q4", comment: "Q4")
        }
    }

    /// Starting month (1-based)
    var startMonth: Int {
        switch self {
        case .q1: return 1
        case .q2: return 4
        case .q3: return 7
        case .q4: return 10
        }
    }

    /// Ending month (1-based)
    var endMonth: Int {
        switch self {
        case .q1: return 3
        case .q2: return 6
        case .q3: return 9
        case .q4: return 12
        }
    }

    /// Get quarter for a given month (1-12)
    static func from(month: Int) -> Quarter {
        switch month {
        case 1...3: return .q1
        case 4...6: return .q2
        case 7...9: return .q3
        default: return .q4
        }
    }

    /// Get current quarter
    static var current: Quarter {
        let month = Calendar.current.component(.month, from: Date())
        return from(month: month)
    }
}

// MARK: - Time Period

/// Represents a specific time period for filtering
struct TimePeriod: Equatable {
    let granularity: TimeGranularity
    let startDate: Date
    let endDate: Date

    // Optional specifics for display
    let day: Int?           // For day granularity
    let week: Int?          // For week granularity (week of year)
    let month: Int?         // For month/quarter granularity
    let quarter: Quarter?   // For quarter granularity
    let year: Int

    // MARK: - Initialization

    init(
        granularity: TimeGranularity,
        startDate: Date,
        endDate: Date,
        day: Int? = nil,
        week: Int? = nil,
        month: Int? = nil,
        quarter: Quarter? = nil,
        year: Int
    ) {
        self.granularity = granularity
        self.startDate = startDate
        self.endDate = endDate
        self.day = day
        self.week = week
        self.month = month
        self.quarter = quarter
        self.year = year
    }

    // MARK: - Display Properties

    /// Formatted display label for the period
    var displayLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT") // Change as needed

        switch granularity {
        case .day:
            formatter.dateFormat = "d MMMM yyyy"
            return formatter.string(from: startDate).capitalized

        case .week:
            formatter.dateFormat = "d MMM"
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            return "\(start) - \(end)"

        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: startDate).capitalized

        case .quarter:
            if let q = quarter {
                return "\(q.displayName) \(year)"
            }
            return "\(year)"

        case .year:
            return String(year)
        }
    }

    /// Short label for compact display
    var shortLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")

        switch granularity {
        case .day:
            formatter.dateFormat = "d MMM"
            return formatter.string(from: startDate)

        case .week:
            formatter.dateFormat = "d"
            let start = formatter.string(from: startDate)
            formatter.dateFormat = "d MMM"
            let end = formatter.string(from: endDate)
            return "\(start)-\(end)"

        case .month:
            formatter.dateFormat = "MMM yy"
            return formatter.string(from: startDate).capitalized

        case .quarter:
            if let q = quarter {
                return "\(q.displayName)"
            }
            return "\(year)"

        case .year:
            return String(year)
        }
    }

    // MARK: - Date String Formatting (for API)

    /// Start date as string (YYYY-MM-DD) - ready for API calls
    var startDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: startDate)
    }

    /// End date as string (YYYY-MM-DD) - ready for API calls
    var endDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: endDate)
    }
}
