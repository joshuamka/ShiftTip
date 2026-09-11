import SwiftUI

struct ShiftRow: View {

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

                    "\(shift.shiftTypeName) • \(hoursText) hrs • \(tipsPerHourText)/hr"

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

                    shift.totalTips,

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
