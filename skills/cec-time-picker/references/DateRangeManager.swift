//
//  DateRangeManager.swift
//  CEC Time Picker Pattern
//
//  Manager for calculating date ranges based on granularity
//  Handles period navigation and boundary checking
//

import Foundation

// MARK: - Date Range Manager

/// Manager for calculating date ranges based on granularity
class DateRangeManager {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    // MARK: - Current Period

    /// Get current period for a granularity
    func currentPeriod(for granularity: TimeGranularity) -> TimePeriod {
        let now = Date()

        switch granularity {
        case .day:
            return dayPeriod(for: now)
        case .week:
            return weekPeriod(for: now)
        case .month:
            return monthPeriod(for: now)
        case .quarter:
            return quarterPeriod(for: now)
        case .year:
            return yearPeriod(for: now)
        }
    }

    // MARK: - Navigation

    /// Get previous period
    func previousPeriod(from period: TimePeriod) -> TimePeriod {
        let referenceDate: Date

        switch period.granularity {
        case .day:
            referenceDate = calendar.date(byAdding: .day, value: -1, to: period.startDate) ?? period.startDate
            return dayPeriod(for: referenceDate)

        case .week:
            referenceDate = calendar.date(byAdding: .weekOfYear, value: -1, to: period.startDate) ?? period.startDate
            return weekPeriod(for: referenceDate)

        case .month:
            referenceDate = calendar.date(byAdding: .month, value: -1, to: period.startDate) ?? period.startDate
            return monthPeriod(for: referenceDate)

        case .quarter:
            referenceDate = calendar.date(byAdding: .month, value: -3, to: period.startDate) ?? period.startDate
            return quarterPeriod(for: referenceDate)

        case .year:
            referenceDate = calendar.date(byAdding: .year, value: -1, to: period.startDate) ?? period.startDate
            return yearPeriod(for: referenceDate)
        }
    }

    /// Get next period
    func nextPeriod(from period: TimePeriod) -> TimePeriod {
        let referenceDate: Date

        switch period.granularity {
        case .day:
            referenceDate = calendar.date(byAdding: .day, value: 1, to: period.startDate) ?? period.startDate
            return dayPeriod(for: referenceDate)

        case .week:
            referenceDate = calendar.date(byAdding: .weekOfYear, value: 1, to: period.startDate) ?? period.startDate
            return weekPeriod(for: referenceDate)

        case .month:
            referenceDate = calendar.date(byAdding: .month, value: 1, to: period.startDate) ?? period.startDate
            return monthPeriod(for: referenceDate)

        case .quarter:
            referenceDate = calendar.date(byAdding: .month, value: 3, to: period.startDate) ?? period.startDate
            return quarterPeriod(for: referenceDate)

        case .year:
            referenceDate = calendar.date(byAdding: .year, value: 1, to: period.startDate) ?? period.startDate
            return yearPeriod(for: referenceDate)
        }
    }

    /// Check if can navigate to next period (not in the future)
    func canNavigateNext(from period: TimePeriod) -> Bool {
        let nextPeriod = self.nextPeriod(from: period)
        return nextPeriod.startDate <= Date()
    }

    /// Check if can navigate to previous period (within 2 years limit)
    func canNavigatePrevious(from period: TimePeriod) -> Bool {
        let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: Date()) ?? Date()
        return period.startDate > twoYearsAgo
    }

    // MARK: - Period Builders

    /// Build day period
    func dayPeriod(for date: Date) -> TimePeriod {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? startOfDay

        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        return TimePeriod(
            granularity: .day,
            startDate: startOfDay,
            endDate: endOfDay,
            day: day,
            month: month,
            year: year
        )
    }

    /// Build week period (Monday to Sunday - ISO standard)
    func weekPeriod(for date: Date) -> TimePeriod {
        var cal = calendar
        cal.firstWeekday = 2 // Monday

        let weekday = cal.component(.weekday, from: date)
        let daysToSubtract = (weekday - cal.firstWeekday + 7) % 7
        let startOfWeek = cal.date(byAdding: .day, value: -daysToSubtract, to: cal.startOfDay(for: date)) ?? date
        let endOfWeek = cal.date(byAdding: .day, value: 6, to: startOfWeek) ?? date

        let week = cal.component(.weekOfYear, from: date)
        let year = cal.component(.yearForWeekOfYear, from: date)

        return TimePeriod(
            granularity: .week,
            startDate: startOfWeek,
            endDate: endOfWeek,
            week: week,
            year: year
        )
    }

    /// Build month period
    func monthPeriod(for date: Date) -> TimePeriod {
        let components = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components) ?? date
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? date

        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        return TimePeriod(
            granularity: .month,
            startDate: startOfMonth,
            endDate: endOfMonth,
            month: month,
            year: year
        )
    }

    /// Build quarter period (Q1, Q2, Q3, Q4)
    func quarterPeriod(for date: Date) -> TimePeriod {
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let quarter = Quarter.from(month: month)

        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = quarter.startMonth
        startComponents.day = 1

        var endComponents = DateComponents()
        endComponents.year = year
        endComponents.month = quarter.endMonth + 1
        endComponents.day = 0 // Last day of previous month

        let startOfQuarter = calendar.date(from: startComponents) ?? date
        let endOfQuarter = calendar.date(from: endComponents) ?? date

        return TimePeriod(
            granularity: .quarter,
            startDate: startOfQuarter,
            endDate: endOfQuarter,
            month: quarter.startMonth,
            quarter: quarter,
            year: year
        )
    }

    /// Build year period
    func yearPeriod(for date: Date) -> TimePeriod {
        let year = calendar.component(.year, from: date)

        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = 1
        startComponents.day = 1

        var endComponents = DateComponents()
        endComponents.year = year
        endComponents.month = 12
        endComponents.day = 31

        let startOfYear = calendar.date(from: startComponents) ?? date
        let endOfYear = calendar.date(from: endComponents) ?? date

        return TimePeriod(
            granularity: .year,
            startDate: startOfYear,
            endDate: endOfYear,
            year: year
        )
    }

    /// Build period for specific year (useful for year picker)
    func yearPeriod(year: Int) -> TimePeriod {
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = 1
        startComponents.day = 1

        var endComponents = DateComponents()
        endComponents.year = year
        endComponents.month = 12
        endComponents.day = 31

        let startOfYear = calendar.date(from: startComponents) ?? Date()
        let endOfYear = calendar.date(from: endComponents) ?? Date()

        return TimePeriod(
            granularity: .year,
            startDate: startOfYear,
            endDate: endOfYear,
            year: year
        )
    }
}
