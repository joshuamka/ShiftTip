import SwiftUI

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
