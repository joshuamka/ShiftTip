//
//  Untitled.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import SwiftUI

struct ProfileView: View {

    @Environment(ShiftTypeStore.self)
    private var shiftTypeStore

    // MARK: - Saved Preferences

    @AppStorage("defaultWorkplace")

    private var defaultWorkplace = ""

    @AppStorage("defaultHourlyRate")

    private var defaultHourlyRate = ""

    @AppStorage("defaultShiftType")

    //private var defaultShiftType = ShiftType.night.rawValue
    private var defaultShiftType = "Night"

    @AppStorage("weeklyEarningsGoal")

    private var weeklyEarningsGoal = ""

    @AppStorage("monthlyEarningsGoal")

    private var monthlyEarningsGoal = ""

    @State private var showingSavedAlert = false

    private let accentColor = Color(

        red: 1.0,

        green: 0.176,

        blue: 0.333

    )

    // MARK: - Goal Values

    private var weeklyGoalValue: Double {

        Double(weeklyEarningsGoal) ?? 0

    }

    private var monthlyGoalValue: Double {

        Double(monthlyEarningsGoal) ?? 0

    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 22) {

                    header

                    profileHero

                    shiftDefaultsCard

                    manageWorkplacesCard

                    manageShiftTypesCard

                    earningsGoalsCard

                    currentSettingsCard

                    saveButton

                }

                .padding(.horizontal, 18)

                .padding(.top, 8)

                .padding(.bottom, 35)

            }

            .background(

                Color(.systemGroupedBackground)

            )

            .navigationBarHidden(true)
            .onAppear {
                ensureDefaultShiftType()
            }

            .alert(

                "Settings Saved",

                isPresented: $showingSavedAlert

            ) {

                Button("OK") { }

            } message: {

                Text(

                    "Your preferences have been saved."

                )

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

                Text("Profile")

                    .font(.title)

                    .fontWeight(.heavy)

                Text(

                    "Customize your ShiftTip experience"

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

                        "person.fill"

                )

                .font(.title3)

                .foregroundStyle(

                    accentColor

                )

            }

        }

    }

    // MARK: - Profile Hero

    private var profileHero: some View {

        HStack(spacing: 16) {

            ZStack {

                Circle()

                    .fill(

                        LinearGradient(

                            colors: [

                                accentColor,

                                accentColor.opacity(

                                    0.65

                                )

                            ],

                            startPoint: .topLeading,

                            endPoint: .bottomTrailing

                        )

                    )

                    .frame(

                        width: 68,

                        height: 68

                    )

                Image(

                    systemName:

                        "person.fill"

                )

                .font(

                    .system(size: 28)

                )

                .foregroundStyle(.white)

            }

            VStack(

                alignment: .leading,

                spacing: 5

            ) {

                Text("ShiftTip")

                    .font(.title2)

                    .fontWeight(.bold)

                Text(

                    "Your shift preferences and earnings goals"

                )

                .font(.subheadline)

                .foregroundStyle(.secondary)

            }

            Spacer()

        }

        .padding(20)

        .background(

            cardBackground

        )

    }

    // MARK: - Shift Defaults

    private var shiftDefaultsCard: some View {

        VStack(

            alignment: .leading,

            spacing: 16

        ) {

            sectionHeader(

                title: "Shift Defaults",

                subtitle:

                    "Automatically prefill new shifts",

                icon: "briefcase.fill"

            )

            Divider()

            profileInputRow(

                icon: "building.2.fill",

                title: "Workplace"

            ) {

                TextField(

                    "Not Set",

                    text: $defaultWorkplace

                )

                .multilineTextAlignment(

                    .trailing

                )

            }

            Divider()

                .padding(.leading, 42)

            profileInputRow(

                icon:

                    "dollarsign.circle.fill",

                title: "Hourly Rate"

            ) {

                TextField(

                    "0.00",

                    text: $defaultHourlyRate

                )

                .keyboardType(.decimalPad)

                .multilineTextAlignment(

                    .trailing

                )

            }

            Divider()

                .padding(.leading, 42)
            HStack(spacing: 12) {
                profileIcon(
                    icon(for: defaultShiftType)
                )

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {
                    Text("Shift Type")

                    Text("Default for new shifts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Picker(
                    "Default Shift Type",
                    selection: $defaultShiftType
                ) {
                    ForEach(shiftTypeStore.shiftTypes) { type in
                        Label(
                            type.name,
                            systemImage: icon(for: type.name)
                        )
                        .tag(type.name)
                    }
                }
                .labelsHidden()
            }
            .padding(.vertical, 12)

        }

        .padding(18)

        .background(

            cardBackground

        )

    }

    // MARK: - Manage Workplaces

    private var manageWorkplacesCard: some View {

        NavigationLink {

            WorkplacesView()

        } label: {

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

                        width: 48,

                        height: 48

                    )

                    Image(

                        systemName: "building.2.fill"

                    )

                    .font(.title3)

                    .foregroundStyle(

                        accentColor

                    )

                }

                VStack(

                    alignment: .leading,

                    spacing: 4

                ) {

                    Text("Manage Workplaces")

                        .font(.headline)

                        .foregroundStyle(

                            .primary

                        )

                    Text(

                        "Add, edit, or remove your workplaces"

                    )

                    .font(.caption)

                    .foregroundStyle(

                        .secondary

                    )

                }

                Spacer()

                Image(

                    systemName: "chevron.right"

                )

                .font(.subheadline)

                .fontWeight(.semibold)

                .foregroundStyle(

                    .secondary

                )

            }

            .padding(18)

            .background(

                cardBackground

            )

        }

        .buttonStyle(.plain)

    }

    // MARK: - Manage Shift Types

    private var manageShiftTypesCard: some View {

        NavigationLink {

            ShiftTypesView()

        } label: {

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

                        width: 48,

                        height: 48

                    )

                    Image(

                        systemName: "clock.badge.checkmark"

                    )

                    .font(.title3)

                    .foregroundStyle(

                        accentColor

                    )

                }

                VStack(

                    alignment: .leading,

                    spacing: 4

                ) {

                    Text("Manage Shift Types")

                        .font(.headline)

                        .foregroundStyle(

                            .primary

                        )

                    Text(

                        "Add, edit, or remove your shift types"

                    )

                    .font(.caption)

                    .foregroundStyle(

                        .secondary

                    )

                }

                Spacer()

                Image(

                    systemName: "chevron.right"

                )

                .font(.subheadline)

                .fontWeight(.semibold)

                .foregroundStyle(

                    .secondary

                )

            }

            .padding(18)

            .background(

                cardBackground

            )

        }

        .buttonStyle(.plain)

    }

    // MARK: - Earnings Goals

    private var earningsGoalsCard: some View {

        VStack(

            alignment: .leading,

            spacing: 16

        ) {

            sectionHeader(

                title: "Earnings Goals",

                subtitle:

                    "Set targets to track your progress",

                icon: "target"

            )

            Divider()

            VStack(spacing: 12) {

                goalInputCard(

                    title: "Weekly Goal",

                    subtitle:

                        "Your target for each week",

                    value:

                        $weeklyEarningsGoal,

                    icon:

                        "calendar.badge.clock"

                )

                goalInputCard(

                    title: "Monthly Goal",

                    subtitle:

                        "Your target for each month",

                    value:

                        $monthlyEarningsGoal,

                    icon: "calendar"

                )

            }

            if weeklyGoalValue > 0 ||

                monthlyGoalValue > 0 {

                Divider()

                HStack(spacing: 12) {

                    goalPreview(

                        title: "Weekly",

                        amount:

                            weeklyGoalValue,

                        icon:

                            "calendar.badge.clock"

                    )

                    goalPreview(

                        title: "Monthly",

                        amount:

                            monthlyGoalValue,

                        icon: "calendar"

                    )

                }

            }

        }

        .padding(18)

        .background(

            cardBackground

        )

    }

    // MARK: - Current Settings

    private var currentSettingsCard: some View {

        VStack(

            alignment: .leading,

            spacing: 16

        ) {

            sectionHeader(

                title: "Current Settings",

                subtitle:

                    "What ShiftTip will use by default",

                icon: "gearshape.fill"

            )

            Divider()

            currentSettingRow(

                title: "Workplace",

                value:

                    defaultWorkplace.isEmpty

                    ? "Not Set"

                    : defaultWorkplace,

                icon:

                    "building.2.fill"

            )

            Divider()

            currentSettingRow(

                title: "Hourly Rate",

                value:

                    hourlyRateDisplay,

                icon:

                    "dollarsign.circle.fill"

            )

            Divider()

            currentSettingRow(

                title: "Shift Type",

                value:

                    defaultShiftType,

                icon: icon(for: defaultShiftType)

            )

        }

        .padding(18)

        .background(

            cardBackground

        )

    }

    // MARK: - Save Button

    private var saveButton: some View {

        Button {

            saveSettings()

        } label: {

            HStack {

                Image(

                    systemName:

                        "checkmark.circle.fill"

                )

                .font(.title3)

                Text("Save Settings")

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

        subtitle: String,

        icon: String

    ) -> some View {

        HStack(spacing: 12) {

            ZStack {

                RoundedRectangle(

                    cornerRadius: 10

                )

                .fill(

                    accentColor.opacity(0.10)

                )

                .frame(

                    width: 38,

                    height: 38

                )

                Image(

                    systemName: icon

                )

                .font(.subheadline)

                .foregroundStyle(

                    accentColor

                )

            }

            VStack(

                alignment: .leading,

                spacing: 2

            ) {

                Text(title)

                    .font(.headline)

                Text(subtitle)

                    .font(.caption)

                    .foregroundStyle(

                        .secondary

                    )

            }

        }

    }

    private func profileIcon(

        _ icon: String

    ) -> some View {

        ZStack {

            RoundedRectangle(

                cornerRadius: 8

            )

            .fill(

                accentColor.opacity(0.08)

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

    private func profileInputRow<Content: View>(

        icon: String,

        title: String,

        @ViewBuilder content:

            () -> Content

    ) -> some View {

        HStack(spacing: 12) {

            profileIcon(icon)

            Text(title)

            Spacer()

            content()

                .frame(maxWidth: 140)

        }

        .padding(.vertical, 12)

    }

    private func goalInputCard(

        title: String,

        subtitle: String,

        value: Binding<String>,

        icon: String

    ) -> some View {

        HStack(spacing: 12) {

            profileIcon(icon)

            VStack(

                alignment: .leading,

                spacing: 2

            ) {

                Text(title)

                    .fontWeight(.semibold)

                Text(subtitle)

                    .font(.caption)

                    .foregroundStyle(

                        .secondary

                    )

            }

            Spacer()

            HStack(spacing: 3) {

                Text("$")

                    .foregroundStyle(

                        .secondary

                    )

                TextField(

                    "0",

                    text: value

                )

                .keyboardType(.decimalPad)

                .multilineTextAlignment(

                    .trailing

                )

                .frame(width: 75)

            }

        }

        .padding(14)

        .background(

            RoundedRectangle(

                cornerRadius: 16,

                style: .continuous

            )

            .fill(

                Color(

                    .tertiarySystemGroupedBackground

                )

            )

        )

    }

    private func goalPreview(

        title: String,

        amount: Double,

        icon: String

    ) -> some View {

        VStack(

            alignment: .leading,

            spacing: 9

        ) {

            profileIcon(icon)

            Text(

                amount > 0

                ? amount.formatted(

                    .currency(

                        code: "USD"

                    )

                )

                : "Not Set"

            )

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

        .padding(14)

        .background(

            RoundedRectangle(

                cornerRadius: 16,

                style: .continuous

            )

            .fill(

                Color(

                    .tertiarySystemGroupedBackground

                )

            )

        )

    }

    private func currentSettingRow(

        title: String,

        value: String,

        icon: String

    ) -> some View {

        HStack(spacing: 12) {

            profileIcon(icon)

            Text(title)

            Spacer()

            Text(value)

                .foregroundStyle(

                    .secondary

                )

                .lineLimit(1)

                .multilineTextAlignment(

                    .trailing

                )

        }

    }

    private var hourlyRateDisplay: String {

        guard let rate =

            Double(defaultHourlyRate)

        else {

            return "Not Set"

        }

        return rate.formatted(

            .currency(

                code: "USD"

            )

        )

    }

    
    private func ensureDefaultShiftType() {
        let names = shiftTypeStore.shiftTypes.map { $0.name }

        if names.contains(defaultShiftType) {
            return
        }

        if names.contains("Night") {
            defaultShiftType = "Night"
        } else if let first = names.first {
            defaultShiftType = first
        } else {
            defaultShiftType = "Other"
        }
    }

// MARK: - Save

    private func saveSettings() {

        defaultWorkplace =

            defaultWorkplace

                .trimmingCharacters(

                    in:

                        .whitespacesAndNewlines

                )

        showingSavedAlert = true

    }

    // MARK: - Shift Type Icon

    private func icon(
        for typeName: String
    ) -> String {
        switch typeName.lowercased() {
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
    ProfileView()
        .environment(ShiftTypeStore())
}
