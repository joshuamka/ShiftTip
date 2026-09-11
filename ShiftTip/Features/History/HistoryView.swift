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
    @State private var isExporting = false
    @State private var preparedReport: PreparedReport?
    @State private var reportDirectory: URL?
    @State private var exportError: String?
    @State private var exportTask: Task<Void, Never>?


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

    private var summary: EarningsSummary { EarningsSummary(shifts: filteredShifts) }

    private var filteredEarnings: Double { summary.earnings }

    private var filteredTips: Double { summary.tips }

    private var filteredHours: Double { summary.hours }

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
            .sheet(item: $preparedReport, onDismiss: {
                if let reportDirectory {
                    try? FileManager.default.removeItem(at: reportDirectory)
                }
                reportDirectory = nil
            }) { report in
                ReportShareSheet(url: report.url)
            }
            .alert("Export Failed", isPresented: Binding(
                get: { exportError != nil },
                set: { if !$0 { exportError = nil } }
            )) {
                Button("OK") { exportError = nil }
            } message: {
                Text(exportError ?? "Please try again.")
            }
            .onDisappear {
                exportTask?.cancel()
            }


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

                        "\(filteredShifts.count)"

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
            Button("All Shifts - CSV", systemImage: "tablecells") {
                export(.csv, filtered: false)
            }
            Button("All Shifts - PDF", systemImage: "doc.richtext") {
                export(.pdf, filtered: false)
            }
            if filtersAreActive && !filteredShifts.isEmpty {
                Divider()
                Button("Filtered Shifts - CSV", systemImage: "line.3.horizontal.decrease.circle") {
                    export(.csv, filtered: true)
                }
                Button("Filtered Shifts - PDF", systemImage: "doc.text") {
                    export(.pdf, filtered: true)
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

                    Text(isExporting ? "Preparing Report…" : "Export")

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
        .disabled(isExporting)
        .overlay(alignment: .trailing) {
            if isExporting { ProgressView().padding(.trailing, 36) }
        }

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

                            "\(filteredShifts.count) found"

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

    private func export(_ format: ReportFormat, filtered: Bool) {
        guard !isExporting else { return }
        let shifts = filtered ? filteredShifts : shiftStore.shifts
        isExporting = true
        exportError = nil
        exportTask = Task { @MainActor in
            defer { isExporting = false }
            do {
                let report = try await ReportExportService.create(
                    shifts: shifts, format: format, filtered: filtered
                )
                if Task.isCancelled {
                    try? FileManager.default.removeItem(at: report.url.deletingLastPathComponent())
                    return
                }
                reportDirectory = report.url.deletingLastPathComponent()
                preparedReport = report
            } catch {
                if !Task.isCancelled { exportError = error.localizedDescription }
            }
        }
    }

}

#Preview {

    HistoryView()
        .environment(ShiftStore())
        .environment(ShiftTypeStore())
}
