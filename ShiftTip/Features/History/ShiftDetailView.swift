import SwiftUI

struct ShiftDetailView: View {

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

    var body: some View {

        ScrollView {

            VStack(spacing: 22) {

                earningsHero

                EstimatedWagesCard(amount: shift.hourlyEarnings)

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

                    "SHIFT TIPS",

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

                Text("Total Tips")

                    .font(.subheadline)

                    .foregroundStyle(

                        .white.opacity(0.65)

                    )

                Text(

                    shift.totalTips,

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

                    title: "Tips / Hr",

                    value:

                        tipsPerHour.formatted(

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

                value: "\(hoursText) hrs",

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

            title: "Tips",

            icon: "chart.bar.fill"

        ) {

            detailRow(

                title: "Estimated Gross Wages",

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

                    "Tips Per Hour",

                value:

                    tipsPerHour

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

                Text("Total Tips")

                    .fontWeight(.bold)

                Spacer()

                Text(

                    shift.totalTips,

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
