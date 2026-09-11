//
//  EditShiftView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import SwiftUI

struct EditShiftView: View {

    @Environment(ShiftStore.self)
    private var shiftStore

    @Environment(ShiftTypeStore.self)
    private var shiftTypeStore

    @Environment(\.dismiss)
    private var dismiss

    let shift: Shift

    @State private var date: Date
    @State private var workplace: String
    @State private var shiftTypeName: String
    @State private var hoursWorked: String
    @State private var hourlyRate: String
    @State private var cashTips: String
    @State private var cardTips: String
    @State private var tipOut: String
    @State private var showDeleteConfirmation = false

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    init(shift: Shift) {

        self.shift = shift

        _date = State(
            initialValue: shift.date
        )

        _workplace = State(
            initialValue: shift.workplace
        )

        _shiftTypeName = State(
            initialValue: shift.shiftTypeName
        )

        _hoursWorked = State(
            initialValue: String(shift.hoursWorked)
        )

        _hourlyRate = State(
            initialValue: String(shift.hourlyRate)
        )

        _cashTips = State(
            initialValue: String(shift.cashTips)
        )

        _cardTips = State(
            initialValue: String(shift.cardTips)
        )

        _tipOut = State(
            initialValue: String(shift.tipOut)
        )
    }

    @State private var validationError: String?

    // MARK: - Calculations

    private var draft: ShiftDraft {
        ShiftDraft(date: date, workplace: workplace, shiftTypeName: shiftTypeName,
                   hoursWorked: hoursWorked, hourlyRate: hourlyRate,
                   cashTips: cashTips, cardTips: cardTips, tipOut: tipOut)
    }

    var totalTips: Double { draft.preview.totalTips }
    var hourlyEarnings: Double { draft.preview.hourlyEarnings }
    var totalEarnings: Double { draft.preview.totalEarnings }

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(spacing: 22) {

                earningsPreview

                shiftInformationCard

                tipsCard

                earningsBreakdown

                saveButton

                deleteButton
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 35)
        }
        .background(
            Color(.systemGroupedBackground)
        )
        .navigationTitle("Edit Shift")
        .navigationBarTitleDisplayMode(.inline)
            .alert("Check Shift Details", isPresented: Binding(
                get: { validationError != nil },
                set: { if !$0 { validationError = nil } }
            )) {
                Button("OK") { validationError = nil }
            } message: {
                Text(validationError ?? "")
            }

        .onAppear {
            ensureShiftTypeExists()
        }
        .storageStatus(message: shiftStore.errorMessage,
                       canReload: shiftStore.loadFailed,
                       reload: { shiftStore.reload() })
    }

    // MARK: - Earnings Preview

    private var earningsPreview: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                Label(
                    "SHIFT EARNINGS",
                    systemImage: "pencil.circle.fill"
                )
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(
                    .white.opacity(0.7)
                )

                Spacer()

                Text(shiftTypeName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        .white.opacity(0.7)
                    )
            }

            Text(
                totalEarnings,
                format: .currency(
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
                        format: .currency(
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

                    Text("Hourly Pay")
                        .font(.caption)
                        .foregroundStyle(
                            .white.opacity(0.65)
                        )

                    Text(
                        hourlyEarnings,
                        format: .currency(
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

            inputRow(
                icon: "building.2.fill",
                title: "Workplace"
            ) {

                TextField(
                    "Workplace",
                    text: $workplace
                )
                .multilineTextAlignment(
                    .trailing
                )
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

                inputIcon("calendar")

                Text("Date")

                Spacer()

                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
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
                icon: "dollarsign.circle.fill",
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
        .padding(18)
        .background(
            cardBackground
        )
    }

    // MARK: - Tips

    private var tipsCard: some View {
        ShiftTipsSection(cashTips: $cashTips, cardTips: $cardTips, tipOut: $tipOut)
    }

    // MARK: - Earnings Breakdown

    private var earningsBreakdown: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                title: "Earnings Breakdown",
                icon: "chart.bar.fill"
            )

            Divider()

            earningsRow(
                title: "Tips",
                value: totalTips,
                icon: "banknote.fill"
            )

            Divider()

            earningsRow(
                title: "Hourly Pay",
                value: hourlyEarnings,
                icon: "clock.fill"
            )

            Divider()

            HStack {

                HStack(spacing: 10) {

                    inputIcon(
                        "dollarsign.circle.fill"
                    )

                    Text("Total Earnings")
                        .fontWeight(.bold)
                }

                Spacer()

                Text(
                    totalEarnings,
                    format: .currency(
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

    // MARK: - Save

    private var saveButton: some View {

        Button {

            saveChanges()

        } label: {

            HStack {

                Image(
                    systemName: "checkmark.circle.fill"
                )
                .font(.title3)

                Text("Save Changes")
                    .fontWeight(.bold)

                Spacer()

                Image(
                    systemName: "arrow.right"
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
                color: accentColor.opacity(0.22),
                radius: 8,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Delete

    private var deleteButton: some View {

        Button {

            showDeleteConfirmation = true

        } label: {

            HStack {

                Image(
                    systemName: "trash.fill"
                )
                .font(.title3)

                Text("Delete Shift")
                    .fontWeight(.bold)

                Spacer()
            }
            .foregroundStyle(.red)
            .padding(.horizontal, 20)
            .frame(height: 58)
            .background(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .fill(
                    Color.red.opacity(0.10)
                )
            )
        }
        .buttonStyle(.plain)
        .confirmationDialog(
            "Delete this shift?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {

            Button(
                "Delete Shift",
                role: .destructive
            ) {

                guard shiftStore.deleteShift(shift) else { return }

                dismiss()
            }

            Button(
                "Cancel",
                role: .cancel
            ) {
            }

        } message: {

            Text(
                "This action cannot be undone."
            )
        }
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
        @ViewBuilder content: () -> Content
    ) -> some View {

        HStack(spacing: 12) {

            inputIcon(icon)

            Text(title)

            Spacer()

            content()
                .frame(
                    maxWidth: 140
                )
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
                format: .currency(
                    code: "USD"
                )
            )
            .fontWeight(.semibold)
        }
    }

    // MARK: - Shift Type

    private func ensureShiftTypeExists() {

        let exists = shiftTypeStore.shiftTypes.contains {
            $0.name == shiftTypeName
        }

        if !exists && !shiftTypeName.isEmpty {

            shiftTypeStore.addShiftType(
                name: shiftTypeName
            )
        }

        if shiftTypeName.isEmpty {

            shiftTypeName =
                shiftTypeStore.shiftTypes.first?.name
                ?? "Other"
        }
    }

    // MARK: - Save Changes

    private func saveChanges() {

        let updatedShift: Shift
        do {
            updatedShift = try draft.makeShift(id: shift.id)
        } catch {
            validationError = error.localizedDescription
            return
        }

        guard shiftStore.updateShift(
            updatedShift
        ) else { return }

        dismiss()
    }
}

#Preview {

    NavigationStack {

        EditShiftView(
            shift: Shift(
                date: Date(),
                workplace: "Example Workplace",
                shiftTypeName: "Bottle Service",
                hoursWorked: 8,
                hourlyRate: 12,
                cashTips: 150,
                cardTips: 300,
                tipOut: 50
            )
        )
    }
    .environment(
        ShiftStore()
    )
    .environment(
        ShiftTypeStore()
    )
}
