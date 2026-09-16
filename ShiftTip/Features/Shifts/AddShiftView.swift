//
//  AddShiftView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/3/26.
//

import SwiftUI

struct AddShiftView: View {

    @Environment(ShiftStore.self)

    private var shiftStore

    @Environment(WorkplaceStore.self)

    private var workplaceStore

    @Environment(ShiftTypeStore.self)

    private var shiftTypeStore

    @AppStorage("defaultWorkplace")

    private var defaultWorkplace = ""

    @AppStorage("defaultHourlyRate")

    private var defaultHourlyRate = ""

    @AppStorage("defaultShiftType")

    private var defaultShiftType = "Night"

    @State private var date = Date()

    @State private var workplace = ""

    @State private var selectedWorkplaceID: UUID?

    @State private var showingAddWorkplace = false

    @State private var shiftTypeName = "Night"

    @State private var hoursWorked = ""

    @State private var hourlyRate = ""

    @State private var cashTips = ""

    @State private var cardTips = ""

    @State private var tipOut = ""

    @State private var showingSavedMessage = false

    private let accentColor = Color(

        red: 1.0,

        green: 0.176,

        blue: 0.333

    )

    @State private var validationError: String?

    // MARK: - Calculations

    private var draft: ShiftDraft {
        ShiftDraft(date: date, workplace: workplace, shiftTypeName: shiftTypeName,
                   hoursWorked: hoursWorked, hourlyRate: hourlyRate,
                   cashTips: cashTips, cardTips: cardTips, tipOut: tipOut)
    }

    var totalTips: Double { draft.preview.totalTips }
    var hourlyEarnings: Double { draft.preview.hourlyEarnings }
    var primaryTipTotal: Double { draft.preview.totalTips }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 22) {

                    header

                    earningsPreview

                    EstimatedWagesCard(amount: hourlyEarnings)

                    shiftInformationCard

                    tipsCard

                    earningsBreakdown

                    saveButton

                }

                .padding(.horizontal, 18)

                .padding(.top, 8)

                .padding(.bottom, 35)

            }

            .background(

                Color(.systemGroupedBackground)

            )

            .navigationTitle("Add Shift")

            .navigationBarTitleDisplayMode(.inline)
            .shiftKeyboardToolbar()
            .alert("Check Shift Details", isPresented: Binding(
                get: { validationError != nil },
                set: { if !$0 { validationError = nil } }
            )) {
                Button("OK") { validationError = nil }
            } message: {
                Text(validationError ?? "")
            }


            .onAppear {

                loadDefaults()

            }

            .sheet(

                isPresented: $showingAddWorkplace

            ) {

                AddWorkplaceView()

            }

            .alert(

                "Shift Saved!",

                isPresented: $showingSavedMessage

            ) {

                Button("OK") { }

            } message: {

                Text(

                    "Your shift has been added to your history."

                )

            }

        }

        .storageStatus(message: shiftStore.errorMessage,
                       canReload: shiftStore.loadFailed,
                       reload: { shiftStore.reload() })
    }

    // MARK: - Header

    private var header: some View {

        HStack {

            VStack(

                alignment: .leading,

                spacing: 4

            ) {

                Text("New Shift")

                    .font(.title2)

                    .fontWeight(.bold)

                Text(

                    "Track your hours, tips and earnings."

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

                        "plus.circle.fill"

                )

                .font(.title2)

                .foregroundStyle(

                    accentColor

                )

            }

        }

    }

    // MARK: - Earnings Preview

    private var earningsPreview: some View {

        VStack(

            alignment: .leading,

            spacing: 14

        ) {

            HStack {

                Label(

                    "SHIFT TIPS",

                    systemImage:

                        "dollarsign.circle.fill"

                )

                .font(.caption)

                .fontWeight(.bold)

                .foregroundStyle(

                    .white.opacity(0.7)

                )

                Spacer()

                Text(

                    shiftTypeName

                )

                .font(.caption)

                .fontWeight(.semibold)

                .foregroundStyle(

                    .white.opacity(0.7)

                )

            }

            Text(

                primaryTipTotal,

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

            .minimumScaleFactor(0.7)

            .lineLimit(1)

            HStack {

                VStack(

                    alignment: .leading,

                    spacing: 3

                ) {

                    Text("Tips")

                        .font(.caption)

                        .foregroundStyle(

                            .white.opacity(0.65)

                        )

                    Text(

                        totalTips,

                        format:

                            .currency(

                                code: "USD"

                            )

                    )

                    .fontWeight(.bold)

                    .foregroundStyle(.white)

                }

                Spacer()

                VStack(

                    alignment: .trailing,

                    spacing: 3

                ) {

                    Text("Estimated Gross Wages")

                        .font(.caption)

                        .foregroundStyle(

                            .white.opacity(0.65)

                        )

                    Text(

                        hourlyEarnings,

                        format:

                            .currency(

                                code: "USD"

                            )

                    )

                    .fontWeight(.bold)

                    .foregroundStyle(.white)

                }

            }

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

    // MARK: - Shift Information

    private var shiftInformationCard: some View {

        VStack(

            alignment: .leading,

            spacing: 16

        ) {

            sectionHeader(

                title: "Shift Information",

                icon: "briefcase.fill"

            )

            Divider()

            VStack(spacing: 0) {

                VStack(spacing: 10) {

                    HStack(spacing: 12) {

                        inputIcon(

                            "building.2.fill"

                        )

                        Text("Workplace")

                        Spacer()

                        if workplaceStore.workplaces.isEmpty {

                            Text("None Added")

                                .foregroundStyle(.secondary)

                        } else {

                            Picker(

                                "Workplace",

                                selection: $selectedWorkplaceID

                            ) {

                                Text("Select")

                                    .tag(nil as UUID?)

                                ForEach(

                                    workplaceStore.workplaces

                                ) { savedWorkplace in

                                    Text(savedWorkplace.name)

                                        .tag(

                                            savedWorkplace.id as UUID?

                                        )

                                }

                            }

                            .labelsHidden()

                            .onChange(

                                of: selectedWorkplaceID

                            ) { _, newValue in

                                selectWorkplace(

                                    id: newValue

                                )

                            }

                        }

                    }

                    .padding(.vertical, 14)

                    Button {

                        showingAddWorkplace = true

                    } label: {

                        HStack {

                            Image(

                                systemName: "plus.circle.fill"

                            )

                            Text("Add New Workplace")

                                .fontWeight(.semibold)

                            Spacer()

                        }

                        .foregroundStyle(

                            accentColor

                        )

                        .padding(.leading, 42)

                        .padding(.bottom, 8)

                    }

                    .buttonStyle(.plain)

                }

                Divider()

                    .padding(.leading, 42)

                HStack(spacing: 12) {

                    inputIcon(

                        "calendar.badge.clock"

                    )

                    Text("Shift Type")

                    Spacer()

                    Picker(

                        "Shift Type",

                        selection: $shiftTypeName

                    ) {

                        ForEach(

                            shiftTypeStore.shiftTypes

                        ) { type in

                            Text(type.name)

                                .tag(type.name)

                        }

                    }

                    .labelsHidden()

                }

                .padding(.vertical, 14)

                Divider()

                    .padding(.leading, 42)

                HStack(spacing: 12) {

                    inputIcon(

                        "calendar"

                    )

                    Text("Date")

                    Spacer()

                    DatePicker(

                        "",

                        selection: $date,

                        displayedComponents:

                            .date

                    )

                    .labelsHidden()

                }

                .padding(.vertical, 14)

                Divider()

                    .padding(.leading, 42)

                inputRow(

                    icon: "clock.fill",

                    title: "Hours Worked"

                ) {

                    TextField(

                        "0",

                        text: $hoursWorked

                    )

                    .keyboardType(.decimalPad)

                    .multilineTextAlignment(

                        .trailing

                    )

                }

                Divider()

                    .padding(.leading, 42)

                inputRow(

                    icon:

                        "dollarsign.circle.fill",

                    title: "Hourly Rate"

                ) {

                    TextField(

                        "0.00",

                        text: $hourlyRate

                    )

                    .keyboardType(.decimalPad)

                    .multilineTextAlignment(

                        .trailing

                    )

                }

            }

        }

        .padding(18)

        .background(

            cardBackground

        )

    }

    // MARK: - Tips

    private var tipsCard: some View {
        ShiftTipsSection(cashTips: $cashTips, cardTips: $cardTips, tipOut: $tipOut)
    }

    // MARK: - Tips and Wages

    private var earningsBreakdown: some View {

        VStack(

            alignment: .leading,

            spacing: 16

        ) {

            sectionHeader(

                title: "Tips and Wages",

                icon:

                    "chart.bar.fill"

            )

            Divider()

            earningsRow(

                title: "Tips",

                value: totalTips,

                icon: "banknote.fill"

            )

            Divider()

            earningsRow(

                title: "Estimated Gross Wages",

                value: hourlyEarnings,

                icon: "clock.fill"

            )

            Divider()

            HStack {

                HStack(spacing: 10) {

                    ZStack {

                        RoundedRectangle(

                            cornerRadius: 9

                        )

                        .fill(

                            accentColor.opacity(

                                0.12

                            )

                        )

                        .frame(

                            width: 34,

                            height: 34

                        )

                        Image(

                            systemName:

                                "dollarsign.circle.fill"

                        )

                        .foregroundStyle(

                            accentColor

                        )

                    }

                    Text(

                        "Total Tips"

                    )

                    .fontWeight(.bold)

                }

                Spacer()

                Text(

                    primaryTipTotal,

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

        .padding(18)

        .background(

            cardBackground

        )

    }

    // MARK: - Save Button

    private var saveButton: some View {

        Button {

            saveShift()

        } label: {

            HStack {

                Image(

                    systemName:

                        "checkmark.circle.fill"

                )

                .font(.title3)

                Text("Save Shift")

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

    // MARK: - UI Helpers

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

    private func sectionHeader(

        title: String,

        icon: String

    ) -> some View {

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

    }

    private func inputIcon(

        _ icon: String

    ) -> some View {

        ZStack {

            RoundedRectangle(

                cornerRadius: 8

            )

            .fill(

                accentColor.opacity(0.10)

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

    private func inputRow<Content: View>(

        icon: String,

        title: String,

        @ViewBuilder content:

            () -> Content

    ) -> some View {

        HStack(spacing: 12) {

            inputIcon(icon)

            Text(title)

            Spacer()

            content()

                .frame(maxWidth: 140)

        }

        .padding(.vertical, 14)

    }

    private func earningsRow(

        title: String,

        value: Double,

        icon: String

    ) -> some View {

        HStack {

            HStack(spacing: 10) {

                Image(

                    systemName: icon

                )

                .foregroundStyle(

                    accentColor

                )

                Text(title)

            }

            Spacer()

            Text(

                value,

                format:

                    .currency(

                        code: "USD"

                    )

            )

            .fontWeight(.semibold)

        }

    }

    // MARK: - Defaults

    private func loadDefaults() {

        if workplace.isEmpty {

            workplace =

                defaultWorkplace

        }

        if hourlyRate.isEmpty {

            hourlyRate =

                defaultHourlyRate

        }

        let availableNames = shiftTypeStore.shiftTypes.map { $0.name }

        if availableNames.contains(defaultShiftType) {
            shiftTypeName = defaultShiftType
        } else if availableNames.contains("Night") {
            shiftTypeName = "Night"
        } else if let firstShiftType = availableNames.first {
            shiftTypeName = firstShiftType
        } else {
            shiftTypeName = "Other"
        }

    }

    // MARK: - Workplace Selection

    private func selectWorkplace(

        id: UUID?

    ) {

        guard

            let id,

            let selectedWorkplace =

                workplaceStore.workplaces.first(

                    where: {

                        $0.id == id

                    }

                )

        else {

            workplace = ""

            return

        }

        workplace = selectedWorkplace.name

        if selectedWorkplace.hourlyRate > 0 {

            hourlyRate = String(

                selectedWorkplace.hourlyRate

            )

        }

    }

    // MARK: - Save Shift

    private func saveShift() {

        let shift: Shift
        do {
            shift = try draft.makeShift()
        } catch {
            validationError = error.localizedDescription
            return
        }

        guard shiftStore.addShift(

            shift

        ) else { return }

        date = Date()

        workplace =

            defaultWorkplace

        let availableNames = shiftTypeStore.shiftTypes.map { $0.name }

        if availableNames.contains(defaultShiftType) {
            shiftTypeName = defaultShiftType
        } else if availableNames.contains("Night") {
            shiftTypeName = "Night"
        } else if let firstShiftType = availableNames.first {
            shiftTypeName = firstShiftType
        } else {
            shiftTypeName = "Other"
        }

        hoursWorked = ""

        hourlyRate =

            defaultHourlyRate

        cashTips = ""

        cardTips = ""

        tipOut = ""

        showingSavedMessage =

            true

    }

}



#Preview {

    AddShiftView()

        .environment(

            ShiftStore()

        )

        .environment(

            WorkplaceStore()

        )

        .environment(

            ShiftTypeStore()

        )

}
