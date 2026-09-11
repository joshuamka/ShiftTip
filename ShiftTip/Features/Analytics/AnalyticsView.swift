//
//  AnalyticsView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import SwiftUI

import Charts

enum AnalyticsPeriod: String, CaseIterable, Identifiable {

    case week = "Week"

    case month = "Month"

    case allTime = "All Time"

    var id: String { rawValue }

}

enum ChartMetric: String, CaseIterable, Identifiable {

    case earnings = "Earnings"

    case tips = "Tips"

    var id: String { rawValue }

}

struct AnalyticsView: View {

    @Environment(ShiftStore.self)

    private var shiftStore

    @State private var selectedPeriod: AnalyticsPeriod = .week

    @State private var selectedMetric: ChartMetric = .earnings

    private let accentColor = Color(

        red: 1.0,

        green: 0.176,

        blue: 0.333

    )

    // MARK: - Filtered Shifts

    private var filteredShifts: [Shift] {

        let calendar = Calendar.current

        let now = Date()

        switch selectedPeriod {

        case .week:

            guard let interval =

                calendar.dateInterval(

                    of: .weekOfYear,

                    for: now

                )

            else {

                return []

            }

            return shiftStore.shifts.filter {

                $0.date >= interval.start &&

                $0.date < interval.end

            }

        case .month:

            guard let interval =

                calendar.dateInterval(

                    of: .month,

                    for: now

                )

            else {

                return []

            }

            return shiftStore.shifts.filter {

                $0.date >= interval.start &&

                $0.date < interval.end

            }

        case .allTime:

            return shiftStore.shifts

        }

    }

    private var sortedShifts: [Shift] {

        filteredShifts.sorted {

            $0.date < $1.date

        }

    }

    private var summary: EarningsSummary { EarningsSummary(shifts: filteredShifts) }

    private var totalEarnings: Double { summary.earnings }
    private var totalTips: Double { summary.tips }
    private var totalHourlyPay: Double { summary.hourlyPay }
    private var totalHours: Double { summary.hours }
    private var averagePerShift: Double { summary.averagePerShift }
    private var averagePerHour: Double { summary.averagePerHour }
    private var averageTipsPerShift: Double { summary.averageTipsPerShift }

    // MARK: - Best / Lowest Shift

    private var bestShift: Shift? {

        filteredShifts.max {

            $0.totalEarnings < $1.totalEarnings

        }

    }

    private var lowestShift: Shift? {

        filteredShifts.min {

            $0.totalEarnings < $1.totalEarnings

        }

    }

    // MARK: - Workplace Analytics

    private var workplaceAnalytics: [WorkplaceAnalytics] {

        let grouped = Dictionary(

            grouping: filteredShifts

        ) { shift in

            shift.workplace

                .trimmingCharacters(

                    in: .whitespacesAndNewlines

                )

                .isEmpty

            ? "Not Specified"

            : shift.workplace

        }

        return grouped.map {

            workplace,

            shifts in

            let summary = EarningsSummary(shifts: shifts)
            let earnings = summary.earnings
            let tips = summary.tips
            let hours = summary.hours

            return WorkplaceAnalytics(

                workplace: workplace,

                earnings: earnings,

                tips: tips,

                hours: hours,

                shiftCount: shifts.count

            )

        }

        .sorted {

            $0.earnings > $1.earnings

        }

    }

    private var bestWorkplace: WorkplaceAnalytics? {

        workplaceAnalytics.first

    }

    // MARK: - Shift Type Analytics

    private var shiftTypeAnalytics: [ShiftTypeAnalytics] {

        let grouped = Dictionary(
            grouping: filteredShifts
        ) { shift in

            let cleanedName = shift.shiftTypeName.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            return cleanedName.isEmpty ? "Other" : cleanedName
        }

        return grouped.map { typeName, shifts in

            let summary = EarningsSummary(shifts: shifts)
            let earnings = summary.earnings
            let tips = summary.tips
            let hours = summary.hours

            return ShiftTypeAnalytics(
                typeName: typeName,
                earnings: earnings,
                tips: tips,
                hours: hours,
                shiftCount: shifts.count
            )
        }
        .sorted {
            $0.earnings > $1.earnings
        }
    }

    private var bestShiftType: ShiftTypeAnalytics? {

        shiftTypeAnalytics.first

    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 22) {

                    header

                    periodPicker

                    if filteredShifts.isEmpty {

                        emptyState

                    } else {

                        earningsHero

                        chartSection

                        quickStatsSection

                        earningsBreakdownSection

                        performanceSection

                        workplaceSection

                        shiftTypeSection

                        bestShiftSection

                    }

                }

                .padding(.horizontal, 18)

                .padding(.top, 8)

                .padding(.bottom, 35)

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

                Text("Analytics")

                    .font(.title)

                    .fontWeight(.heavy)

                Text(

                    "Understand how your shifts perform"

                )

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

                        "chart.xyaxis.line"

                )

                .font(.title3)

                .foregroundStyle(

                    accentColor

                )

            }

        }

    }

    // MARK: - Period Picker

    private var periodPicker: some View {

        Picker(

            "Period",

            selection: $selectedPeriod

        ) {

            ForEach(

                AnalyticsPeriod.allCases

            ) { period in

                Text(period.rawValue)

                    .tag(period)

            }

        }

        .pickerStyle(.segmented)

    }

    // MARK: - Earnings Hero

    private var earningsHero: some View {

        VStack(

            alignment: .leading,

            spacing: 18

        ) {

            HStack {

                Label(

                    periodTitle.uppercased(),

                    systemImage:

                        "chart.bar.fill"

                )

                .font(.caption)

                .fontWeight(.bold)

                .foregroundStyle(

                    .white.opacity(0.65)

                )

                Spacer()

                Text(

                    "\(filteredShifts.count) shifts"

                )

                .font(.caption)

                .fontWeight(.semibold)

                .foregroundStyle(

                    .white.opacity(0.65)

                )

            }

            VStack(

                alignment: .leading,

                spacing: 5

            ) {

                Text("Total Earnings")

                    .font(.subheadline)

                    .foregroundStyle(

                        .white.opacity(0.65)

                    )

                Text(

                    totalEarnings,

                    format:

                        .currency(

                            code: "USD"

                        )

                )

                .font(

                    .system(

                        size: 40,

                        weight: .bold,

                        design: .rounded

                    )

                )

                .foregroundStyle(.white)

                .lineLimit(1)

                .minimumScaleFactor(0.7)

            }

            HStack {

                heroStat(

                    title: "Tips",

                    value:

                        totalTips.formatted(

                            .currency(

                                code: "USD"

                            )

                        )

                )

                Divider()

                    .overlay(

                        .white.opacity(0.2)

                    )

                heroStat(

                    title: "Hours",

                    value:

                        hoursText(totalHours)

                )

                Divider()

                    .overlay(

                        .white.opacity(0.2)

                    )

                heroStat(

                    title: "Avg / Hr",

                    value:

                        averagePerHour.formatted(

                            .currency(

                                code: "USD"

                            )

                        )

                )

            }

            .frame(height: 42)

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

    }

    private func heroStat(

        title: String,

        value: String

    ) -> some View {

        VStack(

            alignment: .leading,

            spacing: 3

        ) {

            Text(title)

                .font(.caption2)

                .foregroundStyle(

                    .white.opacity(0.6)

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

    // MARK: - Chart

    private var chartSection: some View {

        VStack(

            alignment: .leading,

            spacing: 16

        ) {

            HStack {

                sectionTitle(

                    "Performance"

                )

                Spacer()

                Image(

                    systemName:

                        "chart.bar.xaxis"

                )

                .foregroundStyle(

                    accentColor

                )

            }

            Picker(

                "Chart",

                selection:

                    $selectedMetric

            ) {

                ForEach(

                    ChartMetric.allCases

                ) { metric in

                    Text(metric.rawValue)

                        .tag(metric)

                }

            }

            .pickerStyle(.segmented)

            Chart(sortedShifts) { shift in

                BarMark(

                    x: .value(

                        "Date",

                        shift.date,

                        unit: .day

                    ),

                    y: .value(

                        selectedMetric.rawValue,

                        chartValue(

                            for: shift

                        )

                    )

                )

                .foregroundStyle(

                    accentColor.gradient

                )

                .cornerRadius(5)

            }

            .chartYAxis {

                AxisMarks(

                    position: .leading

                ) { value in

                    AxisGridLine()

                        .foregroundStyle(

                            Color.secondary

                                .opacity(0.15)

                        )

                    AxisValueLabel()

                }

            }

            .chartXAxis {

                AxisMarks(

                    values:

                        .automatic(

                            desiredCount: 5

                        )

                )

            }

            .frame(height: 230)

        }

        .padding(18)

        .background(

            cardBackground

        )

    }

    // MARK: - Quick Stats

    private var quickStatsSection: some View {

        VStack(

            alignment: .leading,

            spacing: 14

        ) {

            sectionTitle("Quick Stats")

            HStack(spacing: 12) {

                AnalyticsStatCard(

                    title: "Best Shift",

                    value:

                        bestShift?

                        .totalEarnings

                        .formatted(

                            .currency(

                                code: "USD"

                            )

                        ) ?? "$0.00",

                    icon: "trophy.fill"

                )

                AnalyticsStatCard(

                    title: "Lowest Shift",

                    value:

                        lowestShift?

                        .totalEarnings

                        .formatted(

                            .currency(

                                code: "USD"

                            )

                        ) ?? "$0.00",

                    icon:

                        "arrow.down.circle.fill"

                )

            }

            HStack(spacing: 12) {

                AnalyticsStatCard(

                    title: "Avg Tips",

                    value:

                        averageTipsPerShift

                        .formatted(

                            .currency(

                                code: "USD"

                            )

                        ),

                    icon:

                        "banknote.fill"

                )

                AnalyticsStatCard(

                    title: "Avg / Hour",

                    value:

                        averagePerHour

                        .formatted(

                            .currency(

                                code: "USD"

                            )

                        ),

                    icon: "speedometer"

                )

            }

        }

    }

    // MARK: - Earnings Breakdown

    private var earningsBreakdownSection: some View {

        analyticsCard(

            title: "Earnings Breakdown",

            icon: "dollarsign.circle.fill"

        ) {

            AnalyticsRow(

                title: "Tips",

                value:

                    totalTips.formatted(

                        .currency(

                            code: "USD"

                        )

                    ),

                icon: "banknote.fill"

            )

            Divider()

            AnalyticsRow(

                title: "Hourly Pay",

                value:

                    totalHourlyPay.formatted(

                        .currency(

                            code: "USD"

                        )

                    ),

                icon: "clock.fill"

            )

            Divider()

            AnalyticsRow(

                title: "Total Earnings",

                value:

                    totalEarnings.formatted(

                        .currency(

                            code: "USD"

                        )

                    ),

                icon:

                    "dollarsign.circle.fill",

                bold: true

            )

        }

    }

    // MARK: - Performance

    private var performanceSection: some View {

        analyticsCard(

            title: "Performance",

            icon:

                "chart.line.uptrend.xyaxis"

        ) {

            AnalyticsRow(

                title:

                    "Average Per Shift",

                value:

                    averagePerShift

                    .formatted(

                        .currency(

                            code: "USD"

                        )

                    ),

                icon:

                    "chart.line.uptrend.xyaxis"

            )

            Divider()

            AnalyticsRow(

                title:

                    "Average Per Hour",

                value:

                    averagePerHour

                    .formatted(

                        .currency(

                            code: "USD"

                        )

                    ),

                icon: "speedometer"

            )

            Divider()

            AnalyticsRow(

                title: "Total Hours",

                value:

                    "\(hoursText(totalHours)) hrs",

                icon: "clock"

            )

        }

    }

    // MARK: - Workplace

    private var workplaceSection: some View {

        VStack(

            alignment: .leading,

            spacing: 14

        ) {

            HStack {

                sectionTitle(

                    "By Workplace"

                )

                Spacer()

                Image(

                    systemName:

                        "building.2.fill"

                )

                .foregroundStyle(

                    accentColor

                )

            }

            if let bestWorkplace {

                HStack(spacing: 12) {

                    ZStack {

                        RoundedRectangle(

                            cornerRadius: 11

                        )

                        .fill(

                            accentColor

                                .opacity(0.10)

                        )

                        .frame(

                            width: 42,

                            height: 42

                        )

                        Image(

                            systemName:

                                "star.fill"

                        )

                        .foregroundStyle(

                            accentColor

                        )

                    }

                    VStack(

                        alignment: .leading,

                        spacing: 3

                    ) {

                        Text("Top Workplace")

                            .font(.caption)

                            .foregroundStyle(

                                .secondary

                            )

                        Text(

                            bestWorkplace.workplace

                        )

                        .fontWeight(

                            .semibold

                        )

                    }

                    Spacer()

                    Text(

                        bestWorkplace.earnings,

                        format:

                            .currency(

                                code: "USD"

                            )

                    )

                    .fontWeight(.bold)

                }

                .padding(16)

                .background(

                    cardBackground

                )

            }

            VStack(spacing: 0) {

                ForEach(

                    Array(

                        workplaceAnalytics.enumerated()

                    ),

                    id: \.element.id

                ) { index, item in

                    workplaceRow(item)

                    if index <

                        workplaceAnalytics.count - 1 {

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

                cardBackground

            )

        }

    }

    private func workplaceRow(

        _ item: WorkplaceAnalytics

    ) -> some View {

        VStack(spacing: 10) {

            HStack(spacing: 12) {

                ZStack {

                    RoundedRectangle(

                        cornerRadius: 10

                    )

                    .fill(

                        accentColor

                            .opacity(0.10)

                    )

                    .frame(

                        width: 38,

                        height: 38

                    )

                    Image(

                        systemName:

                            "building.2.fill"

                    )

                    .font(.caption)

                    .foregroundStyle(

                        accentColor

                    )

                }

                VStack(

                    alignment: .leading,

                    spacing: 3

                ) {

                    Text(item.workplace)

                        .fontWeight(

                            .semibold

                        )

                    Text(

                        "\(item.shiftCount) shifts • \(hoursText(item.hours)) hrs"

                    )

                    .font(.caption)

                    .foregroundStyle(

                        .secondary

                    )

                }

                Spacer()

                Text(

                    item.earnings,

                    format:

                        .currency(

                            code: "USD"

                        )

                )

                .fontWeight(.bold)

            }

            HStack {

                Text(

                    "Tips \(item.tips.formatted(.currency(code: "USD")))"

                )

                Spacer()

                Text(

                    "\(item.earningsPerHour.formatted(.currency(code: "USD")))/hr"

                )

            }

            .font(.caption)

            .foregroundStyle(.secondary)

        }

        .padding(.vertical, 14)

    }

    // MARK: - Shift Type

    private var shiftTypeSection: some View {

        VStack(

            alignment: .leading,

            spacing: 14

        ) {

            HStack {

                sectionTitle(

                    "By Shift Type"

                )

                Spacer()

                Image(

                    systemName:

                        "calendar.badge.clock"

                )

                .foregroundStyle(

                    accentColor

                )

            }

            if let bestShiftType {

                HStack(spacing: 12) {

                    ZStack {

                        RoundedRectangle(

                            cornerRadius: 11

                        )

                        .fill(

                            accentColor

                                .opacity(0.10)

                        )

                        .frame(

                            width: 42,

                            height: 42

                        )

                        Image(

                            systemName:

                                icon(

                                    for:

                                        bestShiftType.typeName

                                )

                        )

                        .foregroundStyle(

                            accentColor

                        )

                    }

                    VStack(

                        alignment: .leading,

                        spacing: 3

                    ) {

                        Text("Top Shift Type")

                            .font(.caption)

                            .foregroundStyle(

                                .secondary

                            )

                        Text(

                            bestShiftType.typeName

                        )

                        .fontWeight(

                            .semibold

                        )

                    }

                    Spacer()

                    Text(

                        bestShiftType.earnings,

                        format:

                            .currency(

                                code: "USD"

                            )

                    )

                    .fontWeight(.bold)

                }

                .padding(16)

                .background(

                    cardBackground

                )

            }

            VStack(spacing: 0) {

                ForEach(

                    Array(

                        shiftTypeAnalytics.enumerated()

                    ),

                    id: \.element.id

                ) { index, item in

                    shiftTypeRow(item)

                    if index <

                        shiftTypeAnalytics.count - 1 {

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

                cardBackground

            )

        }

    }

    private func shiftTypeRow(

        _ item: ShiftTypeAnalytics

    ) -> some View {

        VStack(spacing: 10) {

            HStack(spacing: 12) {

                ZStack {

                    RoundedRectangle(

                        cornerRadius: 10

                    )

                    .fill(

                        accentColor

                            .opacity(0.10)

                    )

                    .frame(

                        width: 38,

                        height: 38

                    )

                    Image(

                        systemName:

                            icon(

                                for: item.typeName

                            )

                    )

                    .foregroundStyle(

                        accentColor

                    )

                }

                VStack(

                    alignment: .leading,

                    spacing: 3

                ) {

                    Text(

                        item.typeName

                    )

                    .fontWeight(

                        .semibold

                    )

                    Text(

                        "\(item.shiftCount) shifts • \(hoursText(item.hours)) hrs"

                    )

                    .font(.caption)

                    .foregroundStyle(

                        .secondary

                    )

                }

                Spacer()

                Text(

                    item.earnings,

                    format:

                        .currency(

                            code: "USD"

                        )

                )

                .fontWeight(.bold)

            }

            HStack {

                Text(

                    "Avg \(item.averagePerShift.formatted(.currency(code: "USD")))/shift"

                )

                Spacer()

                Text(

                    "\(item.earningsPerHour.formatted(.currency(code: "USD")))/hr"

                )

            }

            .font(.caption)

            .foregroundStyle(.secondary)

        }

        .padding(.vertical, 14)

    }

    // MARK: - Best Shift

    private var bestShiftSection: some View {

        Group {

            if let bestShift {

                VStack(

                    alignment: .leading,

                    spacing: 14

                ) {

                    HStack {

                        sectionTitle(

                            "Best Shift"

                        )

                        Spacer()

                        Image(

                            systemName:

                                "trophy.fill"

                        )

                        .foregroundStyle(

                            accentColor

                        )

                    }

                    VStack(

                        alignment: .leading,

                        spacing: 14

                    ) {

                        HStack(spacing: 12) {

                            ZStack {

                                RoundedRectangle(

                                    cornerRadius: 12

                                )

                                .fill(

                                    accentColor

                                        .opacity(0.10)

                                )

                                .frame(

                                    width: 46,

                                    height: 46

                                )

                                Image(

                                    systemName:

                                        "trophy.fill"

                                )

                                .foregroundStyle(

                                    accentColor

                                )

                            }

                            VStack(

                                alignment: .leading,

                                spacing: 3

                            ) {

                                Text(

                                    bestShift.workplace.isEmpty

                                    ? "Shift"

                                    : bestShift.workplace

                                )
                                .fontWeight(
                                    .bold
                                )

                                Label(
                                    bestShift.shiftTypeName,
                                    systemImage: icon(for: bestShift.shiftTypeName)
                                )
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )

                            }

                            Spacer()

                            Text(

                                bestShift.date,

                                format:

                                    .dateTime

                                    .month(

                                        .abbreviated

                                    )

                                    .day()

                                    .year()

                            )

                            .font(.caption)

                            .foregroundStyle(

                                .secondary

                            )

                        }

                        Divider()

                        HStack {

                            Text("Total Earnings")

                            Spacer()

                            Text(

                                bestShift

                                    .totalEarnings,

                                format:

                                    .currency(

                                        code: "USD"

                                    )

                            )

                            .font(.title3)

                            .fontWeight(.bold)

                            .foregroundStyle(

                                accentColor

                            )

                        }

                        HStack {

                            Text("Tips")

                                .foregroundStyle(

                                    .secondary

                                )

                            Spacer()

                            Text(

                                bestShift.totalTips,

                                format:

                                    .currency(

                                        code: "USD"

                                    )

                            )

                            .foregroundStyle(

                                .secondary

                            )

                        }

                    }

                    .padding(18)

                    .background(

                        cardBackground

                    )

                }

            }

        }

    }

    // MARK: - Empty State

    private var emptyState: some View {

        VStack(spacing: 16) {

            ZStack {

                Circle()

                    .fill(

                        accentColor.opacity(

                            0.10

                        )

                    )

                    .frame(

                        width: 76,

                        height: 76

                    )

                Image(

                    systemName:

                        "chart.bar.xaxis"

                )

                .font(

                    .system(size: 30)

                )

                .foregroundStyle(

                    accentColor

                )

            }

            Text("No Analytics Yet")

                .font(.headline)

            Text(

                "Add shifts for this period to see your earnings analytics."

            )

            .font(.subheadline)

            .foregroundStyle(.secondary)

            .multilineTextAlignment(

                .center

            )

        }

        .frame(

            maxWidth: .infinity

        )

        .padding(.vertical, 55)

        .padding(.horizontal, 20)

        .background(

            cardBackground

        )

    }

    // MARK: - Helpers

    private var periodTitle: String {

        switch selectedPeriod {

        case .week:

            return "This Week"

        case .month:

            return "This Month"

        case .allTime:

            return "All Time"

        }

    }

    private var cardBackground: some View {

        RoundedRectangle(

            cornerRadius: 20,

            style: .continuous

        )

        .fill(

            Color(

                .secondarySystemGroupedBackground

            )

        )

    }

    private func sectionTitle(

        _ title: String

    ) -> some View {

        Text(title)

            .font(.title3)

            .fontWeight(.bold)

    }

    @ViewBuilder

    private func analyticsCard<Content: View>(

        title: String,

        icon: String,

        @ViewBuilder content:

            () -> Content

    ) -> some View {

        VStack(

            alignment: .leading,

            spacing: 15

        ) {

            HStack {

                sectionTitle(title)

                Spacer()

                Image(

                    systemName: icon

                )

                .foregroundStyle(

                    accentColor

                )

            }

            content()

        }

        .padding(18)

        .background(

            cardBackground

        )

    }

    private func chartValue(

        for shift: Shift

    ) -> Double {

        switch selectedMetric {

        case .earnings:

            return shift.totalEarnings

        case .tips:

            return shift.totalTips

        }

    }

    private func hoursText(

        _ value: Double

    ) -> String {

        value.formatted(

            .number.precision(

                .fractionLength(1)

            )

        )

    }

    private func icon(
        for typeName: String
    ) -> String {

        let value = typeName.lowercased()

        if value.contains("morning") || value.contains("brunch") {
            return "sunrise.fill"
        }

        if value.contains("day") || value.contains("lunch") {
            return "sun.max.fill"
        }

        if value.contains("evening") || value.contains("dinner") {
            return "sunset.fill"
        }

        if value.contains("night") || value.contains("bottle") || value.contains("club") {
            return "moon.stars.fill"
        }

        return "calendar"
    }

}



// MARK: - Workplace Analytics Model

struct WorkplaceAnalytics: Identifiable {

    let workplace: String

    let earnings: Double

    let tips: Double

    let hours: Double

    let shiftCount: Int

    var id: String {

        workplace

    }

    var earningsPerHour: Double {

        guard hours > 0 else {

            return 0

        }

        return earnings / hours

    }

}



// MARK: - Shift Type Analytics Model

struct ShiftTypeAnalytics: Identifiable {

    let typeName: String
    let earnings: Double
    let tips: Double
    let hours: Double
    let shiftCount: Int

    var id: String {
        typeName
    }

    var averagePerShift: Double {

        guard shiftCount > 0 else {
            return 0
        }

        return earnings / Double(shiftCount)
    }

    var earningsPerHour: Double {

        guard hours > 0 else {
            return 0
        }

        return earnings / hours
    }
}



// MARK: - Stat Card

struct AnalyticsStatCard: View {

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

            spacing: 11

        ) {

            ZStack {

                RoundedRectangle(

                    cornerRadius: 10

                )

                .fill(

                    accentColor.opacity(

                        0.10

                    )

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

            Text(value)

                .font(.title3)

                .fontWeight(.bold)

                .lineLimit(1)

                .minimumScaleFactor(0.7)

            Text(title)

                .font(.caption)

                .foregroundStyle(

                    .secondary

                )

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



// MARK: - Analytics Row

struct AnalyticsRow: View {

    let title: String

    let value: String

    let icon: String

    var bold: Bool = false

    private let accentColor = Color(

        red: 1.0,

        green: 0.176,

        blue: 0.333

    )

    var body: some View {

        HStack(spacing: 12) {

            ZStack {

                RoundedRectangle(

                    cornerRadius: 8

                )

                .fill(

                    accentColor.opacity(

                        0.08

                    )

                )

                .frame(

                    width: 32,

                    height: 32

                )

                Image(

                    systemName: icon

                )

                .font(.caption)

                .foregroundStyle(

                    accentColor

                )

            }

            Text(title)

                .fontWeight(

                    bold

                    ? .semibold

                    : .regular

                )

            Spacer()

            Text(value)

                .fontWeight(

                    bold

                    ? .bold

                    : .semibold

                )

        }

    }

}



#Preview {

    AnalyticsView()

        .environment(

            ShiftStore()

        )

}
