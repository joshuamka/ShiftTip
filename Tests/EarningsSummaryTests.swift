import Foundation

@main
struct EarningsSummaryTests {
    static func main() {
        let shifts = [
            Shift(date: Date(), hoursWorked: 2, hourlyRate: 10, cashTips: 30, cardTips: 20, tipOut: 10),
            Shift(date: Date(), hoursWorked: 8, hourlyRate: 20, cashTips: 40, cardTips: 80, tipOut: 20)
        ]
        let summary = EarningsSummary(shifts: shifts)
        precondition(summary.shiftCount == 2 && summary.hours == 10)
        precondition(summary.tips == 140 && summary.hourlyPay == 180 && summary.earnings == 320)
        precondition(summary.averagePerHour == 32) // Weighted, not average of shift rates.
        precondition(summary.averagePerShift == 160 && summary.averageTipsPerShift == 70)
        let empty = EarningsSummary(shifts: [])
        precondition(empty.shiftCount == 0 && empty.earnings == 0)
        precondition(empty.averagePerHour == 0 && empty.averagePerShift == 0 && empty.averageTipsPerShift == 0)
        let legacy = EarningsSummary(shifts: [
            Shift(date: Date(), hoursWorked: 0, hourlyRate: 10, cashTips: 5, cardTips: 0, tipOut: 10)
        ])
        precondition(legacy.averagePerHour == 0 && legacy.earnings == -5)
        print("Earnings summary checks passed: totals, weighted averages, empty data, and legacy zero-hour records.")
    }
}
