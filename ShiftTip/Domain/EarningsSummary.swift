import Foundation

/// Shared totals for screens and reports. Hourly averages are weighted by hours.
nonisolated struct EarningsSummary {
    let shiftCount: Int
    let hours: Double
    let tips: Double
    let hourlyPay: Double
    let earnings: Double

    init(shifts: [Shift]) {
        shiftCount = shifts.count
        var hours = 0.0
        var tips = 0.0
        var hourlyPay = 0.0
        var earnings = 0.0
        for shift in shifts {
            hours += shift.hoursWorked
            tips += shift.totalTips
            hourlyPay += shift.hourlyEarnings
            earnings += shift.totalEarnings
        }
        self.hours = hours
        self.tips = tips
        self.hourlyPay = hourlyPay
        self.earnings = earnings
    }

    var averagePerHour: Double { hours > 0 ? earnings / hours : 0 }
    var averagePerShift: Double { shiftCount > 0 ? earnings / Double(shiftCount) : 0 }
    var averageTipsPerShift: Double { shiftCount > 0 ? tips / Double(shiftCount) : 0 }
}
