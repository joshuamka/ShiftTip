import SwiftUI

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

                        "\(hoursText) hrs"

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
