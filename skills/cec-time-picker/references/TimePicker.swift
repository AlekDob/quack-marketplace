//
//  TimePicker.swift
//  CEC Time Picker Pattern
//
//  Apple-style time picker with segmented control + navigation
//  Pattern: [G][S][M][T][A] + <- Period ->
//

import SwiftUI

struct TimePicker: View {
    @Binding var selectedGranularity: TimeGranularity
    @Binding var selectedPeriod: TimePeriod
    @Binding var selectedYear: Int  // For year mode year picker

    let availableYears: [Int]
    let onPeriodChange: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private let dateRangeManager = DateRangeManager()

    var body: some View {
        VStack(spacing: 12) {
            // Segmented control: G S M T A
            granularitySegmentedControl

            // Period navigation: <- Period ->
            periodNavigationRow
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.white))
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 6, x: 0, y: 2)
        }
    }

    // MARK: - Granularity Segmented Control

    private var granularitySegmentedControl: some View {
        HStack(spacing: 4) {
            ForEach(TimeGranularity.allCases) { granularity in
                granularityButton(granularity)
            }
        }
        .padding(4)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func granularityButton(_ granularity: TimeGranularity) -> some View {
        let isSelected = selectedGranularity == granularity

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedGranularity = granularity
                selectedPeriod = dateRangeManager.currentPeriod(for: granularity)
                if granularity == .year {
                    selectedYear = selectedPeriod.year
                }
                onPeriodChange()
            }
        } label: {
            Text(granularity.shortLabel)
                .font(.subheadline.weight(isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(granularity.color)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(granularity.localizedName)
    }

    // MARK: - Period Navigation Row

    private var periodNavigationRow: some View {
        HStack(spacing: 16) {
            // Previous button
            Button {
                navigatePrevious()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(canNavigatePrevious ? .primary : .tertiary)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .disabled(!canNavigatePrevious)

            Spacer()

            // Period label (or year picker for year mode)
            periodLabel

            Spacer()

            // Next button
            Button {
                navigateNext()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(canNavigateNext ? .primary : .tertiary)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .disabled(!canNavigateNext)
        }
    }

    // MARK: - Period Label

    @ViewBuilder
    private var periodLabel: some View {
        if selectedGranularity == .year {
            // Year mode: show year picker dropdown
            Menu {
                ForEach(availableYears, id: \.self) { year in
                    Button {
                        selectedYear = year
                        selectedPeriod = dateRangeManager.yearPeriod(year: year)
                        onPeriodChange()
                    } label: {
                        HStack {
                            Text(String(year))
                            if year == selectedYear {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: selectedGranularity.icon)
                        .font(.body)
                        .foregroundStyle(selectedGranularity.color)

                    Text(selectedPeriod.displayLabel)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
        } else {
            // Other modes: show period label with icon
            HStack(spacing: 8) {
                Image(systemName: selectedGranularity.icon)
                    .font(.body)
                    .foregroundStyle(selectedGranularity.color)

                Text(selectedPeriod.displayLabel)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }

    // MARK: - Navigation Helpers

    private var canNavigatePrevious: Bool {
        dateRangeManager.canNavigatePrevious(from: selectedPeriod)
    }

    private var canNavigateNext: Bool {
        dateRangeManager.canNavigateNext(from: selectedPeriod)
    }

    private func navigatePrevious() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedPeriod = dateRangeManager.previousPeriod(from: selectedPeriod)
            if selectedGranularity == .year {
                selectedYear = selectedPeriod.year
            }
            onPeriodChange()
        }
    }

    private func navigateNext() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedPeriod = dateRangeManager.nextPeriod(from: selectedPeriod)
            if selectedGranularity == .year {
                selectedYear = selectedPeriod.year
            }
            onPeriodChange()
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var granularity: TimeGranularity = .month
        @State private var period: TimePeriod = DateRangeManager().currentPeriod(for: .month)
        @State private var year: Int = 2025

        var body: some View {
            VStack(spacing: 20) {
                TimePicker(
                    selectedGranularity: $granularity,
                    selectedPeriod: $period,
                    selectedYear: $year,
                    availableYears: [2025, 2024, 2023, 2022, 2021],
                    onPeriodChange: {
                        print("Period changed: \(period.displayLabel)")
                    }
                )

                // Debug info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Granularity: \(granularity.localizedName)")
                    Text("Period: \(period.displayLabel)")
                    Text("Start: \(period.startDateString)")
                    Text("End: \(period.endDateString)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
