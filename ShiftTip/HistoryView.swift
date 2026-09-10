//
//  HistoryView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import SwiftUI

struct HistoryView: View {

    @Environment(ShiftStore.self)

    private var shiftStore

    @Environment(ShiftTypeStore.self)

    private var shiftTypeStore

    @State private var searchText = ""

    @State private var selectedShiftType = "All"

    @State private var selectedWorkplace = "All"

    @State private var showingCalendar = false

    private let accentColor = Color(

        red: 1.0,

        green: 0.176,

        blue: 0.333

    )

    // MARK: - Shift Types

    private var shiftTypeNames: [String] {

        let savedNames = shiftTypeStore.shiftTypes.map { $0.name }
        let usedNames = shiftStore.shifts.map { $0.shiftTypeName }

        let names = Array(Set(savedNames + usedNames))
            .filter { !$0.isEmpty }
            .sorted()

        return ["All"] + names
    }

    // MARK: - Workplaces

    private var workplaces: [String] {

        let names = shiftStore.shifts

            .map {

                $0.workplace.trimmingCharacters(

                    in: .whitespacesAndNewlines

                )

            }

            .filter {

                !$0.isEmpty

            }

        return ["All"] + Array(Set(names)).sorted()

    }

    // MARK: - Filtered Shifts

    private var filteredShifts: [Shift] {

        shiftStore.shifts

            .filter { shift in

                let matchesSearch =

                    searchText.isEmpty ||

                    shift.workplace

                        .localizedCaseInsensitiveContains(

                            searchText

                        ) ||

                    shift.shiftTypeName

                        .localizedCaseInsensitiveContains(

                            searchText

                        )

                let matchesType =
                    selectedShiftType == "All" ||
                    shift.shiftTypeName == selectedShiftType

                let matchesWorkplace =

                    selectedWorkplace == "All" ||

                    shift.workplace == selectedWorkplace

                return

                    matchesSearch &&

                    matchesType &&

                    matchesWorkplace

            }

            .sorted {

                $0.date > $1.date

            }

    }

    // MARK: - Summary

    private var filteredEarnings: Double {

        filteredShifts.reduce(0) {

            $0 + $1.totalEarnings

        }

    }

    private var filteredTips: Double {

        filteredShifts.reduce(0) {

            $0 + $1.totalTips

        }

    }

    private var filteredHours: Double {

        filteredShifts.reduce(0) {

            $0 + $1.hoursWorked

        }

    }

    // MARK: - Export Files

    private var allCSVURL: URL? {

        CSVExporter.createCSV(

            from: shiftStore.shifts,

            fileName: exportFileName(

                prefix: "ShiftTip-All-Shifts",

                extensionName: "csv"

            )

        )

    }

    private var filteredCSVURL: URL? {

        CSVExporter.createCSV(

            from: filteredShifts,

            fileName: exportFileName(

                prefix: "ShiftTip-Filtered-Shifts",

                extensionName: "csv"

            )

        )

    }

    private var allPDFURL: URL? {

        PDFExporter.createPDF(

            from: shiftStore.shifts,

            fileName: exportFileName(

                prefix: "ShiftTip-Earnings-Report",

                extensionName: "pdf"

            )

        )

    }

    private var filteredPDFURL: URL? {

        PDFExporter.createPDF(

            from: filteredShifts,

            fileName: exportFileName(

                prefix: "ShiftTip-Filtered-Report",

                extensionName: "pdf"

            )

        )

    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 20) {

                    header

                    if !shiftStore.shifts.isEmpty {

                        summaryCard

                        searchBar

                        filterSection

                        exportMenu

                    }

                    historySection

                }

                .padding(.horizontal, 18)

                .padding(.top, 8)

                .padding(.bottom, 30)

            }

            .background(

                Color(.systemGroupedBackground)

            )

            .navigationBarHidden(true)

            .sheet(

                isPresented: $showingCalendar

            ) {

                CalendarHistoryView()

            }

        }

    }

    // MARK: - Header

    private var header: some View {

        HStack {

            VStack(

                alignment: .leading,

                spacing: 3

            ) {

                Text("History")

                    .font(.title)

                    .fontWeight(.heavy)

                Text(

                    "Review and manage your shifts"

                )

                .font(.subheadline)

                .foregroundStyle(.secondary)

            }

            Spacer()

            Button {

                showingCalendar = true

            } label: {

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

                        systemName: "calendar"

                    )

                    .font(.title3)

                    .foregroundStyle(

                        accentColor

                    )

                }

            }

            .buttonStyle(.plain)

        }

    }

    // MARK: - Summary

    private var summaryCard: some View {

        VStack(

            alignment: .leading,

            spacing: 18

        ) {

            HStack {

                VStack(

                    alignment: .leading,

                    spacing: 5

                ) {

                    Text(

                        filtersAreActive

                        ? "FILTERED EARNINGS"

                        : "TOTAL EARNINGS"

                    )

                    .font(.caption)

                    .fontWeight(.bold)

                    .foregroundStyle(

                        .white.opacity(0.65)

                    )

                    Text(

                        filteredEarnings,

                        format:

                            .currency(

                                code: "USD"

                            )

                    )

                    .font(

                        .system(

                            size: 34,

                            weight: .bold,

                            design: .rounded

                        )

                    )

                    .foregroundStyle(.white)

                    .minimumScaleFactor(0.7)

                    .lineLimit(1)

                }

                Spacer()

                VStack(

                    alignment: .trailing,

                    spacing: 4

                ) {

                    Text(

                        "\\(filteredShifts.count)"

                    )

                    .font(.title2)

                    .fontWeight(.bold)

                    .foregroundStyle(.white)

                    Text(

                        filteredShifts.count == 1

                        ? "Shift"

                        : "Shifts"

                    )

                    .font(.caption)

                    .foregroundStyle(

                        .white.opacity(0.65)

                    )

                }

            }

            HStack {

                historyMiniStat(

                    title: "Tips",

                    value:

                        filteredTips.formatted(

                            .currency(

                                code: "USD"

                            )

                        )

                )

                Divider()

                    .overlay(

                        .white.opacity(0.2)

                    )

                historyMiniStat(

                    title: "Hours",

                    value:

                        filteredHours.formatted(

                            .number.precision(

                                .fractionLength(1)

                            )

                        )

                )

            }

            .frame(height: 40)

        }

        .padding(22)

        .background {

            RoundedRectangle(

                cornerRadius: 24,

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

                    width: 120,

                    height: 120

                )

                .offset(

                    x: 35,

                    y: -45

                )

                .allowsHitTesting(false)

        }

        .clipShape(

            RoundedRectangle(

                cornerRadius: 24,

                style: .continuous

            )

        )

    }

    private func historyMiniStat(

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

        }

        .frame(

            maxWidth: .infinity,

            alignment: .leading

        )

    }

    // MARK: - Search

    private var searchBar: some View {

        HStack(spacing: 10) {

            Image(

                systemName:

                    "magnifyingglass"

            )

            .foregroundStyle(.secondary)

            TextField(

                "Search workplace or shift type",

                text: $searchText

            )

            if !searchText.isEmpty {

                Button {

                    searchText = ""

                } label: {

                    Image(

                        systemName:

                            "xmark.circle.fill"

                    )

                    .foregroundStyle(

                        .secondary

                    )

                }

                .buttonStyle(.plain)

            }

        }

        .padding(.horizontal, 15)

        .frame(height: 48)

        .background(

            RoundedRectangle(

                cornerRadius: 16,

                style: .continuous

            )

            .fill(

                Color(

                    .secondarySystemGroupedBackground

                )

            )

        )

    }

    // MARK: - Filters

    private var filterSection: some View {

        VStack(spacing: 12) {

            Menu {

                Picker(
                    "Shift Type",
                    selection: $selectedShiftType
                ) {

                    ForEach(shiftTypeNames, id: \.self) { typeName in

                        Text(typeName == "All" ? "All Shift Types" : typeName)
                            .tag(typeName)
                    }
                }

            } label: {

                HStack(spacing: 10) {

                    ZStack {

                        RoundedRectangle(cornerRadius: 8)
                            .fill(accentColor.opacity(0.10))
                            .frame(width: 32, height: 32)

                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(accentColor)
                    }

                    Text(selectedShiftType == "All" ? "All Shift Types" : selectedShiftType)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {

                Menu {

                    Picker(

                        "Workplace",

                        selection:

                            $selectedWorkplace

                    ) {

                        ForEach(

                            workplaces,

                            id: \.self

                        ) { workplace in

                            Text(workplace)

                                .tag(workplace)

                        }

                    }

                } label: {

                    HStack(spacing: 10) {

                        ZStack {

                            RoundedRectangle(

                                cornerRadius: 8

                            )

                            .fill(

                                accentColor

                                    .opacity(0.10)

                            )

                            .frame(

                                width: 32,

                                height: 32

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

                        Text(

                            selectedWorkplace == "All"

                            ? "All Workplaces"

                            : selectedWorkplace

                        )

                        .lineLimit(1)

                        Spacer()

                        Image(

                            systemName:

                                "chevron.down"

                        )

                        .font(.caption)

                        .foregroundStyle(

                            .secondary

                        )

                    }

                    .padding(.horizontal, 12)

                    .frame(height: 52)

                    .background(

                        RoundedRectangle(

                            cornerRadius: 16

                        )

                        .fill(

                            Color(

                                .secondarySystemGroupedBackground

                            )

                        )

                    )

                }

                .buttonStyle(.plain)

                if filtersAreActive {

                    Button {

                        clearFilters()

                    } label: {

                        ZStack {

                            RoundedRectangle(

                                cornerRadius: 14

                            )

                            .fill(

                                accentColor

                                    .opacity(0.10)

                            )

                            .frame(

                                width: 52,

                                height: 52

                            )

                            Image(

                                systemName:

                                    "xmark"

                            )

                            .fontWeight(

                                .semibold

                            )

                            .foregroundStyle(

                                accentColor

                            )

                        }

                    }

                    .buttonStyle(.plain)

                }

            }

        }

    }

    // MARK: - Export Menu

    @ViewBuilder

    private var exportMenu: some View {

        Menu {

            if let allCSVURL {

                ShareLink(

                    item: allCSVURL

                ) {

                    Label(

                        "All Shifts - CSV",

                        systemImage:

                            "tablecells"

                    )

                }

            }

            if let allPDFURL {

                ShareLink(

                    item: allPDFURL

                ) {

                    Label(

                        "All Shifts - PDF",

                        systemImage:

                            "doc.richtext"

                    )

                }

            }

            if filtersAreActive &&

                !filteredShifts.isEmpty {

                Divider()

                if let filteredCSVURL {

                    ShareLink(

                        item:

                            filteredCSVURL

                    ) {

                        Label(

                            "Filtered Shifts - CSV",

                            systemImage:

                                "line.3.horizontal.decrease.circle"

                        )

                    }

                }

                if let filteredPDFURL {

                    ShareLink(

                        item:

                            filteredPDFURL

                    ) {

                        Label(

                            "Filtered Shifts - PDF",

                            systemImage:

                                "doc.text"

                        )

                    }

                }

            }

        } label: {

            HStack(spacing: 12) {

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

                        width: 38,

                        height: 38

                    )

                    Image(

                        systemName:

                            "square.and.arrow.up"

                    )

                    .foregroundStyle(

                        accentColor

                    )

                }

                VStack(

                    alignment: .leading,

                    spacing: 2

                ) {

                    Text("Export")

                        .fontWeight(.semibold)

                    Text(

                        "CSV or PDF report"

                    )

                    .font(.caption)

                    .foregroundStyle(

                        .secondary

                    )

                }

                Spacer()

                Image(

                    systemName:

                        "chevron.down"

                )

                .font(.caption)

                .foregroundStyle(

                    .secondary

                )

            }

            .padding(.horizontal, 14)

            .frame(height: 60)

            .background(

                RoundedRectangle(

                    cornerRadius: 16,

                    style: .continuous

                )

                .fill(

                    Color(

                        .secondarySystemGroupedBackground

                    )

                )

            )

        }

        .buttonStyle(.plain)

    }

    // MARK: - History

    private var historySection: some View {

        VStack(

            alignment: .leading,

            spacing: 14

        ) {

            if !shiftStore.shifts.isEmpty {

                HStack {

                    Text("Shifts")

                        .font(.title3)

                        .fontWeight(.bold)

                    Spacer()

                    if filtersAreActive {

                        Text(

                            "\\(filteredShifts.count) found"

                        )

                        .font(.caption)

                        .foregroundStyle(

                            .secondary

                        )

                    }

                }

            }

            if shiftStore.shifts.isEmpty {

                emptyState

            } else if filteredShifts.isEmpty {

                noResultsState

            } else {

                VStack(spacing: 0) {

                    ForEach(

                        Array(

                            filteredShifts.enumerated()

                        ),

                        id: \.element.id

                    ) { index, shift in

                        NavigationLink {

                            ShiftDetailView(

                                shift: shift

                            )

                        } label: {

                            ShiftRow(

                                shift: shift

                            )

                        }

                        .buttonStyle(.plain)

                        .contextMenu {

                            Button(

                                role: .destructive

                            ) {

                                shiftStore.deleteShift(

                                    shift

                                )

                            } label: {

                                Label(

                                    "Delete Shift",

                                    systemImage:

                                        "trash"

                                )

                            }

                        }

                        if index <

                            filteredShifts.count - 1 {

                            Divider()

                                .padding(

                                    .leading,

                                    58

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

    // MARK: - Empty States

    private var emptyState: some View {

        VStack(spacing: 14) {

            ZStack {

                Circle()

                    .fill(

                        accentColor.opacity(0.10)

                    )

                    .frame(

                        width: 70,

                        height: 70

                    )

                Image(

                    systemName:

                        "clock.badge.questionmark"

                )

                .font(.system(size: 28))

                .foregroundStyle(

                    accentColor

                )

            }

            Text("No Shifts Yet")

                .font(.headline)

            Text(

                "Your saved shifts will appear here."

            )

            .font(.subheadline)

            .foregroundStyle(.secondary)

        }

        .frame(

            maxWidth: .infinity

        )

        .padding(.vertical, 45)

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

    }

    private var noResultsState: some View {

        VStack(spacing: 14) {

            Image(

                systemName:

                    "magnifyingglass"

            )

            .font(.system(size: 30))

            .foregroundStyle(

                accentColor

            )

            Text("No Matching Shifts")

                .font(.headline)

            Text(

                "Try changing your search or filters."

            )

            .font(.subheadline)

            .foregroundStyle(.secondary)

            Button("Clear Filters") {

                clearFilters()

            }

            .fontWeight(.semibold)

            .foregroundStyle(

                accentColor

            )

        }

        .frame(

            maxWidth: .infinity

        )

        .padding(.vertical, 40)

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

    }

    // MARK: - Helpers

    private var filtersAreActive: Bool {

        !searchText.isEmpty ||

        selectedShiftType != "All" ||

        selectedWorkplace != "All"

    }

    private func clearFilters() {

        searchText = ""

        selectedShiftType = "All"

        selectedWorkplace = "All"

    }

    private func exportFileName(

        prefix: String,

        extensionName: String

    ) -> String {

        let formatter =

            DateFormatter()

        formatter.dateFormat =

            "yyyy-MM-dd"


        return "\\(prefix)-\\(date).\\(extensionName)"

    }

}



// MARK: - Shift Row

struct ShiftRow: View {

    let shift: Shift

    private let accentColor = Color(

        red: 1.0,

        green: 0.176,

        blue: 0.333

    )

    private var earningsPerHour: Double {

        guard shift.hoursWorked > 0 else {

            return 0

        }

        return

            shift.totalEarnings /

            shift.hoursWorked

    }

    private var hoursText: String {

        shift.hoursWorked.formatted(

            .number.precision(

                .fractionLength(1)

            )

        )

    }

    private var earningsPerHourText: String {

        earningsPerHour.formatted(

            .currency(

                code: "USD"

            )

        )

    }

    var body: some View {

        HStack(spacing: 13) {

            ZStack {

                RoundedRectangle(

                    cornerRadius: 11

                )

                .fill(

                    accentColor.opacity(

                        0.10

                    )

                )

                .frame(

                    width: 42,

                    height: 42

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

                spacing: 5

            ) {

                HStack(spacing: 5) {

                    Text(

                        shift.date,

                        format:

                            .dateTime

                            .month(

                                .abbreviated

                            )

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

                        .foregroundStyle(

                            .secondary

                        )

                        .lineLimit(1)

                    }

                }

                Text(

                    "\\(shift.shiftTypeName) • \\(hoursText) hrs • \\(earningsPerHourText)/hr"

                )

                .font(.caption)

                .foregroundStyle(

                    .secondary

                )

                .lineLimit(1)

            }

            Spacer()

            VStack(

                alignment: .trailing,

                spacing: 5

            ) {

                Text(

                    shift.totalEarnings,

                    format:

                        .currency(

                            code: "USD"

                        )

                )

                .fontWeight(.bold)

                Text(

                    shift.totalTips,

                    format:

                        .currency(

                            code: "USD"

                        )

                )

                .font(.caption)

                .foregroundStyle(

                    .secondary

                )

            }

            Image(

                systemName:

                    "chevron.right"

            )

            .font(.caption2)

            .foregroundStyle(

                .tertiary

            )

        }

        .padding(.vertical, 14)

    }

    private var shiftTypeIcon: String {

        switch shift.shiftTypeName.lowercased() {

        case "morning", "brunch":
            return "sunrise.fill"

        case "day":
            return "sun.max.fill"

        case "evening":
            return "sunset.fill"

        case "night":
            return "moon.stars.fill"

        default:
            return "calendar"
        }
    }

}

// MARK: - Shift Detail

struct ShiftDetailView: View {

    let shift: Shift

    private let accentColor = Color(

        red: 1.0,

        green: 0.176,

        blue: 0.333

    )

    private var earningsPerHour: Double {

        guard shift.hoursWorked > 0 else {

            return 0

        }

        return

            shift.totalEarnings /

            shift.hoursWorked

    }

    private var hoursText: String {

        shift.hoursWorked.formatted(

            .number.precision(

                .fractionLength(1)

            )

        )

    }

    var body: some View {

        ScrollView {

            VStack(spacing: 22) {

                earningsHero

                shiftInformationCard

                tipsCard

                earningsCard

                editButton

            }

            .padding(.horizontal, 18)

            .padding(.top, 10)

            .padding(.bottom, 35)

        }

        .background(

            Color(.systemGroupedBackground)

        )

        .navigationTitle("Shift Details")

        .navigationBarTitleDisplayMode(.inline)

    }

    // MARK: - Earnings Hero

    private var earningsHero: some View {

        VStack(

            alignment: .leading,

            spacing: 18

        ) {

            HStack {

                Label(

                    "SHIFT EARNINGS",

                    systemImage:

                        shiftTypeIcon

                )

                .font(.caption)

                .fontWeight(.bold)

                .foregroundStyle(

                    .white.opacity(0.7)

                )

                Spacer()

                Text(

                    shift.shiftTypeName

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

                Text("Total Earnings")

                    .font(.subheadline)

                    .foregroundStyle(

                        .white.opacity(0.65)

                    )

                Text(

                    shift.totalEarnings,

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

                        shift.totalTips.formatted(

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

                    value: hoursText

                )

                Divider()

                    .overlay(

                        .white.opacity(0.2)

                    )

                heroStat(

                    title: "Avg / Hr",

                    value:

                        earningsPerHour.formatted(

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

    // MARK: - Shift Information

    private var shiftInformationCard: some View {

        detailCard(

            title: "Shift Information",

            icon: "briefcase.fill"

        ) {

            if !shift.workplace.isEmpty {

                detailRow(

                    title: "Workplace",

                    value: shift.workplace,

                    icon: "building.2.fill"

                )

                Divider()

            }

            detailRow(

                title: "Shift Type",

                value:

                    shift.shiftTypeName,

                icon: shiftTypeIcon

            )

            Divider()

            detailRow(

                title: "Date",

                value:

                    shift.date.formatted(

                        .dateTime

                            .month(.wide)

                            .day()

                            .year()

                    ),

                icon: "calendar"

            )

            Divider()

            detailRow(

                title: "Hours Worked",

                value: "\\(hoursText) hrs",

                icon: "clock.fill"

            )

            Divider()

            detailRow(

                title: "Hourly Rate",

                value:

                    shift.hourlyRate.formatted(

                        .currency(

                            code: "USD"

                        )

                    ),

                icon:

                    "dollarsign.circle.fill"

            )

        }

    }

    // MARK: - Tips

    private var tipsCard: some View {

        detailCard(

            title: "Tips",

            icon: "banknote.fill"

        ) {

            detailRow(

                title: "Cash Tips",

                value:

                    shift.cashTips.formatted(

                        .currency(

                            code: "USD"

                        )

                    ),

                icon: "banknote.fill"

            )

            Divider()

            detailRow(

                title:

                    "Credit Card Tips",

                value:

                    shift.cardTips.formatted(

                        .currency(

                            code: "USD"

                        )

                    ),

                icon: "creditcard.fill"

            )

            Divider()

            detailRow(

                title: "Tip Out",

                value:

                    shift.tipOut.formatted(

                        .currency(

                            code: "USD"

                        )

                    ),

                icon:

                    "arrow.up.right.circle.fill"

            )

            Divider()

            detailRow(

                title: "Total Tips",

                value:

                    shift.totalTips.formatted(

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

    // MARK: - Earnings

    private var earningsCard: some View {

        detailCard(

            title: "Earnings",

            icon: "chart.bar.fill"

        ) {

            detailRow(

                title: "Hourly Pay",

                value:

                    shift.hourlyEarnings

                        .formatted(

                            .currency(

                                code: "USD"

                            )

                        ),

                icon: "clock.fill"

            )

            Divider()

            detailRow(

                title:

                    "Earnings Per Hour",

                value:

                    earningsPerHour

                        .formatted(

                            .currency(

                                code: "USD"

                            )

                        ),

                icon: "speedometer"

            )

            Divider()

            HStack(spacing: 12) {

                detailIcon(

                    "dollarsign.circle.fill"

                )

                Text("Total Earnings")

                    .fontWeight(.bold)

                Spacer()

                Text(

                    shift.totalEarnings,

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

        }

    }

    // MARK: - Edit Button

    private var editButton: some View {

        NavigationLink {

            EditShiftView(

                shift: shift

            )

        } label: {

            HStack {

                Image(

                    systemName:

                        "pencil.circle.fill"

                )

                .font(.title3)

                Text("Edit Shift")

                    .fontWeight(.bold)

                Spacer()

                Image(

                    systemName:

                        "arrow.right"

                )

                .fontWeight(.semibold)

            }

            .foregroundStyle(.white)

            .padding(.horizontal, 20)

            .frame(height: 60)

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

    // MARK: - Helpers

    private func detailCard<Content: View>(

        title: String,

        icon: String,

        @ViewBuilder content:

            () -> Content

    ) -> some View {

        VStack(

            alignment: .leading,

            spacing: 15

        ) {

            HStack(spacing: 10) {

                Image(

                    systemName: icon

                )

                .foregroundStyle(

                    accentColor

                )

                Text(title)

                    .font(.headline)

            }

            Divider()

            content()

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

    private func detailRow(

        title: String,

        value: String,

        icon: String,

        bold: Bool = false

    ) -> some View {

        HStack(spacing: 12) {

            detailIcon(icon)

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

                .foregroundStyle(

                    bold

                    ? AnyShapeStyle(

                        accentColor

                    )

                    : AnyShapeStyle(

                        Color.secondary

                    )

                )

                .multilineTextAlignment(

                    .trailing

                )

        }

    }

    private func detailIcon(

        _ icon: String

    ) -> some View {

        ZStack {

            RoundedRectangle(

                cornerRadius: 8

            )

            .fill(

                accentColor.opacity(0.09)

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

    }

    private var shiftTypeIcon: String {

        switch shift.shiftTypeName.lowercased() {

        case "morning", "brunch":
            return "sunrise.fill"

        case "day":
            return "sun.max.fill"

        case "evening":
            return "sunset.fill"

        case "night":
            return "moon.stars.fill"

        default:
            return "calendar"
        }
    }

}



// MARK: - Calendar

struct CalendarHistoryView: View {

    @Environment(ShiftStore.self)

    private var shiftStore

    @Environment(\.dismiss)

    private var dismiss

    @State private var selectedDate = Date()

    private let accentColor = Color(

        red: 1.0,

        green: 0.176,

        blue: 0.333

    )

    // MARK: - Selected Day

    private var selectedDayShifts: [Shift] {

        shiftStore.shifts

            .filter {

                Calendar.current.isDate(

                    $0.date,

                    inSameDayAs: selectedDate

                )

            }

            .sorted {

                $0.date < $1.date

            }

    }

    private var selectedDayEarnings: Double {

        selectedDayShifts.reduce(0) {

            $0 + $1.totalEarnings

        }

    }

    private var selectedDayTips: Double {

        selectedDayShifts.reduce(0) {

            $0 + $1.totalTips

        }

    }

    private var selectedDayHours: Double {

        selectedDayShifts.reduce(0) {

            $0 + $1.hoursWorked

        }

    }

    private var selectedDayAverage: Double {

        guard selectedDayHours > 0 else {

            return 0

        }

        return

            selectedDayEarnings /

            selectedDayHours

    }

    // MARK: - Selected Month

    private var monthShifts: [Shift] {

        guard let interval =

            Calendar.current.dateInterval(

                of: .month,

                for: selectedDate

            )

        else {

            return []

        }

        return shiftStore.shifts

            .filter {

                $0.date >= interval.start &&

                $0.date < interval.end

            }

    }

    private var monthlyEarnings: Double {

        monthShifts.reduce(0) {

            $0 + $1.totalEarnings

        }

    }

    private var monthlyTips: Double {

        monthShifts.reduce(0) {

            $0 + $1.totalTips

        }

    }

    private var monthlyHours: Double {

        monthShifts.reduce(0) {

            $0 + $1.hoursWorked

        }

    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 22) {

                    monthHero

                    calendarCard

                    selectedDaySection

                }

                .padding(.horizontal, 18)

                .padding(.top, 8)

                .padding(.bottom, 35)

            }

            .background(

                Color(.systemGroupedBackground)

            )

            .navigationTitle("Calendar")

            .navigationBarTitleDisplayMode(

                .inline

            )

            .toolbar {

                ToolbarItem(

                    placement: .topBarTrailing

                ) {

                    Button("Done") {

                        dismiss()

                    }

                    .fontWeight(.semibold)

                    .foregroundStyle(

                        accentColor

                    )

                }

            }

        }

    }

    // MARK: - Month Hero

    private var monthHero: some View {

        VStack(

            alignment: .leading,

            spacing: 18

        ) {

            HStack {

                VStack(

                    alignment: .leading,

                    spacing: 4

                ) {

                    Text("MONTH SUMMARY")

                        .font(.caption)

                        .fontWeight(.bold)

                        .foregroundStyle(

                            .white.opacity(0.65)

                        )

                    Text(

                        selectedDate,

                        format:

                            .dateTime

                                .month(.wide)

                                .year()

                    )

                    .font(.title3)

                    .fontWeight(.bold)

                    .foregroundStyle(.white)

                }

                Spacer()

                ZStack {

                    Circle()

                        .fill(

                            .white.opacity(0.10)

                        )

                        .frame(

                            width: 44,

                            height: 44

                        )

                    Image(

                        systemName:

                            "calendar"

                    )

                    .foregroundStyle(

                        accentColor

                    )

                }

            }

            Text(

                monthlyEarnings,

                format:

                    .currency(

                        code: "USD"

                    )

            )

            .font(

                .system(

                    size: 38,

                    weight: .bold,

                    design: .rounded

                )

            )

            .foregroundStyle(.white)

            .lineLimit(1)

            .minimumScaleFactor(0.7)

            HStack {

                monthStat(

                    title: "Shifts",

                    value:

                        "\\(monthShifts.count)"

                )

                Divider()

                    .overlay(

                        .white.opacity(0.2)

                    )

                monthStat(

                    title: "Tips",

                    value:

                        monthlyTips.formatted(

                            .currency(

                                code: "USD"

                            )

                        )

                )

                Divider()

                    .overlay(

                        .white.opacity(0.2)

                    )

                monthStat(

                    title: "Hours",

                    value:

                        monthlyHours.formatted(

                            .number.precision(

                                .fractionLength(1)

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

                    y: -50

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

    private func monthStat(

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

                .minimumScaleFactor(0.65)

        }

        .frame(

            maxWidth: .infinity,

            alignment: .leading

        )

    }

    // MARK: - Calendar Card

    private var calendarCard: some View {

        VStack(

            alignment: .leading,

            spacing: 12

        ) {

            HStack(spacing: 10) {

                Image(

                    systemName:

                        "calendar.badge.clock"

                )

                .foregroundStyle(

                    accentColor

                )

                Text("Select a Date")

                    .font(.headline)

            }

            DatePicker(

                "Select Date",

                selection: $selectedDate,

                displayedComponents: .date

            )

            .datePickerStyle(.graphical)

            .labelsHidden()

            .tint(accentColor)

        }

        .padding(18)

        .background(

            RoundedRectangle(

                cornerRadius: 22,

                style: .continuous

            )

            .fill(

                Color(

                    .secondarySystemGroupedBackground

                )

            )

        )

    }

    // MARK: - Selected Day

    private var selectedDaySection: some View {

        VStack(

            alignment: .leading,

            spacing: 16

        ) {

            HStack {

                VStack(

                    alignment: .leading,

                    spacing: 4

                ) {

                    Text("SELECTED DAY")

                        .font(.caption)

                        .fontWeight(.bold)

                        .foregroundStyle(

                            accentColor

                        )

                    Text(

                        selectedDate,

                        format:

                            .dateTime

                                .weekday(.wide)

                                .month(.wide)

                                .day()

                    )

                    .font(.title2)

                    .fontWeight(.bold)

                }

                Spacer()

                if !selectedDayShifts.isEmpty {

                    Text(

                        selectedDayShifts.count == 1

                        ? "1 Shift"

                        : "\\(selectedDayShifts.count) Shifts"

                    )

                    .font(.caption)

                    .fontWeight(.semibold)

                    .padding(

                        .horizontal,

                        10

                    )

                    .padding(

                        .vertical,

                        6

                    )

                    .background(

                        Capsule()

                            .fill(

                                accentColor.opacity(

                                    0.10

                                )

                            )

                    )

                    .foregroundStyle(

                        accentColor

                    )

                }

            }

            if selectedDayShifts.isEmpty {

                emptyDayCard

            } else {

                dailyStats

                VStack(spacing: 12) {

                    ForEach(

                        selectedDayShifts

                    ) { shift in

                        NavigationLink {

                            ShiftDetailView(

                                shift: shift

                            )

                        } label: {

                            CalendarShiftRow(

                                shift: shift

                            )

                        }

                        .buttonStyle(.plain)

                    }

                }

            }

        }

    }

    // MARK: - Daily Stats

    private var dailyStats: some View {

        VStack(spacing: 12) {

            HStack(spacing: 12) {

                CalendarStatCard(

                    title: "Earnings",

                    value:

                        selectedDayEarnings

                            .formatted(

                                .currency(

                                    code: "USD"

                                )

                            ),

                    icon:

                        "dollarsign.circle.fill"

                )

                CalendarStatCard(

                    title: "Tips",

                    value:

                        selectedDayTips

                            .formatted(

                                .currency(

                                    code: "USD"

                                )

                            ),

                    icon: "banknote.fill"

                )

            }

            HStack(spacing: 12) {

                CalendarStatCard(

                    title: "Hours",

                    value:

                        selectedDayHours

                            .formatted(

                                .number.precision(

                                    .fractionLength(1)

                                )

                            ),

                    icon: "clock.fill"

                )

                CalendarStatCard(

                    title: "Avg / Hr",

                    value:

                        selectedDayAverage

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

    // MARK: - Empty Day

    private var emptyDayCard: some View {

        VStack(spacing: 12) {

            ZStack {

                Circle()

                    .fill(

                        accentColor.opacity(0.10)

                    )

                    .frame(

                        width: 58,

                        height: 58

                    )

                Image(

                    systemName:

                        "calendar.badge.exclamationmark"

                )

                .font(.title2)

                .foregroundStyle(

                    accentColor

                )

            }

            Text("No Shifts")

                .font(.headline)

            Text(

                "There are no saved shifts for this date."

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

        .padding(.vertical, 35)

        .padding(.horizontal, 20)

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



// MARK: - Calendar Stat Card

struct CalendarStatCard: View {

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

            ZStack {

                RoundedRectangle(

                    cornerRadius: 9

                )

                .fill(

                    accentColor.opacity(0.09)

                )

                .frame(

                    width: 34,

                    height: 34

                )

                Image(

                    systemName: icon

                )

                .font(.caption)

                .foregroundStyle(

                    accentColor

                )

            }

            Text(value)

                .font(.headline)

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



// MARK: - Calendar Shift Row

struct CalendarShiftRow: View {

    let shift: Shift

    private let accentColor = Color(

        red: 1.0,

        green: 0.176,

        blue: 0.333

    )

    private var hoursText: String {

        shift.hoursWorked.formatted(

            .number.precision(

                .fractionLength(1)

            )

        )

    }

    var body: some View {

        HStack(spacing: 14) {

            ZStack {

                RoundedRectangle(

                    cornerRadius: 12,

                    style: .continuous

                )

                .fill(

                    accentColor.opacity(0.10)

                )

                .frame(

                    width: 46,

                    height: 46

                )

                Image(

                    systemName: shiftIcon

                )

                .font(.title3)

                .foregroundStyle(

                    accentColor

                )

            }

            VStack(

                alignment: .leading,

                spacing: 5

            ) {

                Text(

                    shift.workplace.isEmpty

                    ? "Shift"

                    : shift.workplace

                )

                .font(.headline)

                .lineLimit(1)

                HStack(spacing: 6) {

                    Text(

                        shift.shiftTypeName

                    )

                    Text("•")

                    Text(

                        "\\(hoursText) hrs"

                    )

                }

                .font(.caption)

                .foregroundStyle(

                    .secondary

                )

            }

            Spacer()

            VStack(

                alignment: .trailing,

                spacing: 5

            ) {

                Text(

                    shift.totalEarnings,

                    format:

                        .currency(

                            code: "USD"

                        )

                )

                .fontWeight(.bold)

                Text(
                    "Tips \(shift.totalTips.formatted(.currency(code: "USD")))"
                )
                .font(.caption2)

                .foregroundStyle(

                    .secondary

                )

            }

            Image(

                systemName:

                    "chevron.right"

            )

            .font(.caption)

            .fontWeight(.semibold)

            .foregroundStyle(

                .tertiary

            )

        }

        .padding(16)

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

    private var shiftIcon: String {

        switch shift.shiftTypeName.lowercased() {

        case "morning", "brunch":
            return "sunrise.fill"

        case "day":
            return "sun.max.fill"

        case "evening":
            return "sunset.fill"

        case "night":
            return "moon.stars.fill"

        default:
            return "calendar"
        }
    }

}



#Preview {

    HistoryView()
        .environment(ShiftStore())
        .environment(ShiftTypeStore())
}
