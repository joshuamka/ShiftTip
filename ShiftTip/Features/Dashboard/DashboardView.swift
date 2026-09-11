//
//  DashboardView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import SwiftUI

struct DashboardView: View {

    @Environment(ShiftStore.self)
    private var shiftStore

    @AppStorage("weeklyEarningsGoal")
    private var weeklyEarningsGoal = ""

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    // MARK: - Weekly Data

    private var weeklyShifts: [Shift] {

        guard let interval =
            Calendar.current.dateInterval(
                of: .weekOfYear,
                for: Date()
            )
        else {
            return []
        }

        return shiftStore.shifts.filter {
            $0.date >= interval.start &&
            $0.date < interval.end
        }
    }

    private var weeklySummaryData: EarningsSummary { EarningsSummary(shifts: weeklyShifts) }

    private var weeklyTipTotal: Double { weeklySummaryData.tips }

    private var weeklyTips: Double { weeklySummaryData.tips }

    private var weeklyHours: Double { weeklySummaryData.hours }

    private var averagePerHour: Double { weeklySummaryData.averageTipsPerHour }

    // MARK: - Weekly Goal

    private var weeklyGoal: Double {
        Double(weeklyEarningsGoal) ?? 0
    }

    private var weeklyGoalProgress: Double {

        guard weeklyGoal > 0 else {
            return 0
        }

        return min(
            weeklyTipTotal / weeklyGoal,
            1.0
        )
    }

    private var weeklyGoalPercentage: Int {

        guard weeklyGoal > 0 else {
            return 0
        }

        return Int(
            weeklyTipTotal /
            weeklyGoal *
            100
        )
    }

    private var amountRemaining: Double {

        max(
            weeklyGoal - weeklyTipTotal,
            0
        )
    }

    private var amountOverGoal: Double {

        max(
            weeklyTipTotal - weeklyGoal,
            0
        )
    }

    private var goalReached: Bool {

        weeklyGoal > 0 &&
        weeklyTipTotal >= weeklyGoal
    }

    // MARK: - Recent Shifts

    private var recentShifts: [Shift] {

        Array(
            shiftStore.shifts
                .sorted {
                    $0.date > $1.date
                }
                .prefix(3)
        )
    }

    // MARK: - All Time

    private var allTimeTipTotal: Double { EarningsSummary(shifts: shiftStore.shifts).tips }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    header

                    earningsHero

                    EstimatedWagesCard(amount: weeklySummaryData.hourlyPay)

                    if weeklyGoal > 0 {
                        weeklyGoalCard
                    }

                    weeklySummary

                    addShiftButton

                    recentShiftsSection

                    if !shiftStore.shifts.isEmpty {
                        allTimeSection
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .background(
                Color(.systemGroupedBackground)
            )
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var header: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text("ShiftTip")
                    .font(.title)
                    .fontWeight(.heavy)

                Text("Your tips at a glance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ZStack {

                Circle()
                    .fill(
                        accentColor.opacity(0.12)
                    )
                    .frame(
                        width: 46,
                        height: 46
                    )

                Image(
                    systemName:
                        "dollarsign.circle.fill"
                )
                .font(.title2)
                .foregroundStyle(accentColor)
            }
        }
    }

    // MARK: - Earnings Hero

    private var earningsHero: some View {

        VStack(
            alignment: .leading,
            spacing: 20
        ) {

            HStack {

                Label(
                    "THIS WEEK",
                    systemImage:
                        "calendar.badge.clock"
                )
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(
                    .white.opacity(0.7)
                )

                Spacer()

                Text(
                    "\(weeklyShifts.count) shifts"
                )
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(
                    .white.opacity(0.7)
                )
            }

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text("Total Tips")
                    .font(.subheadline)
                    .foregroundStyle(
                        .white.opacity(0.7)
                    )

                Text(
                    weeklyTipTotal,
                    format:
                        .currency(
                            code: "USD"
                        )
                )
                .font(
                    .system(
                        size: 42,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            }

            HStack(spacing: 20) {

                heroMiniStat(
                    title: "Tips",
                    value:
                        weeklyTips.formatted(
                            .currency(
                                code: "USD"
                            )
                        ),
                    icon: "banknote.fill"
                )

                Divider()
                    .overlay(
                        .white.opacity(0.2)
                    )

                heroMiniStat(
                    title: "Hours",
                    value:
                        weeklyHours.formatted(
                            .number.precision(
                                .fractionLength(1)
                            )
                        ),
                    icon: "clock.fill"
                )

                Divider()
                    .overlay(
                        .white.opacity(0.2)
                    )

                heroMiniStat(
                    title: "Tips / Hr",
                    value:
                        averagePerHour.formatted(
                            .currency(
                                code: "USD"
                            )
                        ),
                    icon: "speedometer"
                )
            }
            .frame(height: 45)
        }
        .padding(22)
        .background {

            RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
            .fill(
                LinearGradient(
                    colors: [
                        Color(
                            red: 0.10,
                            green: 0.10,
                            blue: 0.12
                        ),
                        Color(
                            red: 0.18,
                            green: 0.07,
                            blue: 0.12
                        )
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .overlay(
            alignment: .topTrailing
        ) {

            Circle()
                .fill(
                    accentColor.opacity(0.16)
                )
                .frame(
                    width: 130,
                    height: 130
                )
                .offset(
                    x: 35,
                    y: -45
                )
                .allowsHitTesting(false)
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.12),
            radius: 12,
            x: 0,
            y: 6
        )
    }

    private func heroMiniStat(
        title: String,
        value: String,
        icon: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            Label(
                title,
                systemImage: icon
            )
            .font(.caption2)
            .foregroundStyle(
                .white.opacity(0.65)
            )

            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Weekly Goal

    private var weeklyGoalCard: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            HStack {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 12
                    )
                    .fill(
                        accentColor.opacity(0.12)
                    )
                    .frame(
                        width: 42,
                        height: 42
                    )

                    Image(
                        systemName:
                            goalReached
                            ? "checkmark.circle.fill"
                            : "target"
                    )
                    .foregroundStyle(accentColor)
                    .font(.title3)
                }

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    Text("Weekly Tip Goal")
                        .font(.headline)

                    Text(
                        goalReached
                        ? "Goal reached — great week!"
                        : "Keep building toward your goal"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Text(
                    "\(weeklyGoalPercentage)%"
                )
                .font(.headline)
                .foregroundStyle(accentColor)
            }

            HStack(
                alignment: .firstTextBaseline
            ) {

                Text(
                    weeklyTipTotal,
                    format:
                        .currency(
                            code: "USD"
                        )
                )
                .font(.title3)
                .fontWeight(.bold)

                Text("of")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    weeklyGoal,
                    format:
                        .currency(
                            code: "USD"
                        )
                )
                .font(.subheadline)
                .fontWeight(.semibold)

                Spacer()
            }

            ProgressView(
                value: weeklyGoalProgress
            )
            .tint(accentColor)
            .scaleEffect(
                x: 1,
                y: 1.5,
                anchor: .center
            )

            if goalReached {

                Text(
                    "\(amountOverGoal.formatted(.currency(code: "USD"))) over your weekly tip goal"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

            } else {

                Text(
                    "\(amountRemaining.formatted(.currency(code: "USD"))) remaining"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(
                Color(.secondarySystemGroupedBackground)
            )
        )
    }

    // MARK: - Weekly Summary

    private var weeklySummary: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            sectionTitle(
                "Weekly Summary"
            )

            HStack(spacing: 12) {

                DashboardStatCard(
                    title: "Tips",
                    value:
                        weeklyTips.formatted(
                            .currency(
                                code: "USD"
                            )
                        ),
                    icon: "banknote.fill"
                )

                DashboardStatCard(
                    title: "Hours",
                    value:
                        weeklyHours.formatted(
                            .number.precision(
                                .fractionLength(1)
                            )
                        ),
                    icon: "clock.fill"
                )
            }

            HStack(spacing: 12) {

                DashboardStatCard(
                    title: "Tips / Hour",
                    value:
                        averagePerHour.formatted(
                            .currency(
                                code: "USD"
                            )
                        ),
                    icon: "chart.line.uptrend.xyaxis"
                )

                DashboardStatCard(
                    title: "Shifts",
                    value:
                        "\(weeklyShifts.count)",
                    icon: "calendar"
                )
            }
        }
    }

    // MARK: - Add Shift

    private var addShiftButton: some View {

        NavigationLink {

            AddShiftView()

        } label: {

            HStack(spacing: 12) {

                Image(
                    systemName:
                        "plus.circle.fill"
                )
                .font(.title2)

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    Text("Add New Shift")
                        .fontWeight(.bold)

                    Text(
                        "Track hours, tips & earnings"
                    )
                    .font(.caption)
                    .opacity(0.8)
                }

                Spacer()

                Image(
                    systemName:
                        "arrow.right"
                )
                .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(height: 66)
            .background(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .fill(accentColor)
            )
            .shadow(
                color:
                    accentColor.opacity(0.22),
                radius: 8,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent Shifts

    private var recentShiftsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                sectionTitle(
                    "Recent Shifts"
                )

                Spacer()

                if !recentShifts.isEmpty {

                    Text(
                        "\(shiftStore.shifts.count) total"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            if recentShifts.isEmpty {

                VStack(spacing: 12) {

                    Image(
                        systemName:
                            "clock.badge.questionmark"
                    )
                    .font(.system(size: 32))
                    .foregroundStyle(accentColor)

                    Text("No Shifts Yet")
                        .font(.headline)

                    Text(
                        "Add your first shift to start tracking your tips."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(
                        .center
                    )
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding(.vertical, 35)
                .background(
                    RoundedRectangle(
                        cornerRadius: 20
                    )
                    .fill(
                        Color(
                            .secondarySystemGroupedBackground
                        )
                    )
                )

            } else {

                VStack(spacing: 0) {

                    ForEach(
                        Array(
                            recentShifts.enumerated()
                        ),
                        id: \.element.id
                    ) { index, shift in

                        NavigationLink {

                            ShiftDetailView(
                                shift: shift
                            )

                        } label: {

                            DashboardShiftRow(
                                shift: shift
                            )
                        }
                        .buttonStyle(.plain)

                        if index <
                            recentShifts.count - 1 {

                            Divider()
                                .padding(
                                    .leading,
                                    50
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .fill(
                        Color(
                            .secondarySystemGroupedBackground
                        )
                    )
                )
            }
        }
    }

    // MARK: - All Time

    private var allTimeSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            sectionTitle(
                "All-Time"
            )

            HStack(spacing: 14) {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 14
                    )
                    .fill(
                        accentColor.opacity(0.12)
                    )
                    .frame(
                        width: 48,
                        height: 48
                    )

                    Image(
                        systemName:
                            "chart.bar.fill"
                    )
                    .foregroundStyle(accentColor)
                }

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text("Total Tips")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        allTimeTipTotal,
                        format:
                            .currency(
                                code: "USD"
                            )
                    )
                    .font(.title2)
                    .fontWeight(.bold)
                }

                Spacer()

                VStack(
                    alignment: .trailing,
                    spacing: 3
                ) {

                    Text("Shifts")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        "\(shiftStore.shifts.count)"
                    )
                    .font(.title2)
                    .fontWeight(.bold)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .fill(
                    Color(
                        .secondarySystemGroupedBackground
                    )
                )
            )
        }
    }

    private func sectionTitle(
        _ title: String
    ) -> some View {

        Text(title)
            .font(.title3)
            .fontWeight(.bold)
    }
}


// MARK: - Dashboard Stat Card

struct DashboardStatCard: View {

    let title: String
    let value: String
    let icon: String

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 10
                    )
                    .fill(
                        accentColor.opacity(0.10)
                    )
                    .frame(
                        width: 36,
                        height: 36
                    )

                    Image(
                        systemName: icon
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        accentColor
                    )
                }

                Spacer()
            }

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(16)
        .background(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .fill(
                Color(
                    .secondarySystemGroupedBackground
                )
            )
        )
    }
}


// MARK: - Dashboard Shift Row

struct DashboardShiftRow: View {

    let shift: Shift

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    private var tipsPerHour: Double {

        guard shift.hoursWorked > 0 else {
            return 0
        }

        return
            shift.totalTips /
            shift.hoursWorked
    }

    private var hoursText: String {

        shift.hoursWorked.formatted(
            .number.precision(
                .fractionLength(1)
            )
        )
    }

    private var tipsPerHourText: String {

        tipsPerHour.formatted(
            .currency(
                code: "USD"
            )
        )
    }

    var body: some View {

        HStack(spacing: 12) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 11
                )
                .fill(
                    accentColor.opacity(0.10)
                )
                .frame(
                    width: 40,
                    height: 40
                )

                Image(
                    systemName:
                        shiftTypeIcon
                )
                .foregroundStyle(
                    accentColor
                )
            }

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                HStack(spacing: 5) {

                    Text(
                        shift.date,
                        format:
                            .dateTime
                            .month(.abbreviated)
                            .day()
                    )
                    .fontWeight(.semibold)

                    if !shift.workplace.isEmpty {

                        Text("•")
                            .foregroundStyle(
                                .secondary
                            )

                        Text(
                            shift.workplace
                        )
                        .lineLimit(1)
                        .foregroundStyle(
                            .secondary
                        )
                    }
                }

                Text(
                    "\(shift.shiftType.rawValue) • \(hoursText) hrs • \(tipsPerHourText)/hr"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: 4
            ) {

                Text(
                    shift.totalTips,
                    format:
                        .currency(
                            code: "USD"
                        )
                )
                .fontWeight(.bold)

                Image(
                    systemName:
                        "chevron.right"
                )
                .font(.caption2)
                .foregroundStyle(
                    .tertiary
                )
            }
        }
        .padding(.vertical, 13)
    }

    private var shiftTypeIcon: String {

        switch shift.shiftType {

        case .brunch:
            return "sunrise.fill"

        case .day:
            return "sun.max.fill"

        case .night:
            return "moon.stars.fill"

        case .other:
            return "dollarsign.circle.fill"
        }
    }
}


#Preview {

    DashboardView()
        .environment(
            ShiftStore()
        )
}
