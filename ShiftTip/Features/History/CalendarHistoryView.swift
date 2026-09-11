import SwiftUI

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
