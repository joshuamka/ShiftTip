import Foundation

/// Text remains editable until the user saves a validated shift.
struct ShiftDraft {
    var date: Date
    var workplace: String
    var shiftTypeName: String
    var hoursWorked: String
    var hourlyRate: String
    var cashTips: String
    var cardTips: String
    var tipOut: String

    private func number(_ text: String, locale: Locale) -> Double? {
        let separator = locale.decimalSeparator ?? "."
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: separator, with: ".")
        guard let value = Double(normalized), value.isFinite else { return nil }
        return value
    }

    var preview: Shift {
        Shift(date: date, workplace: workplace, shiftTypeName: shiftTypeName,
              hoursWorked: number(hoursWorked, locale: .current) ?? 0,
              hourlyRate: number(hourlyRate, locale: .current) ?? 0,
              cashTips: number(cashTips, locale: .current) ?? 0,
              cardTips: number(cardTips, locale: .current) ?? 0,
              tipOut: number(tipOut, locale: .current) ?? 0)
    }

    func makeShift(id: UUID = UUID(), locale: Locale = .current) throws -> Shift {
        func validated(_ text: String, field: String, required: Bool = false) throws -> Double {
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !required { return 0 }
            guard let value = number(text, locale: locale), value >= 0,
                  !required || value > 0 else {
                throw ValidationError(message: "\(field): enter \(required ? "a number greater than zero" : "zero or a positive number").")
            }
            return value
        }
        let shift = try Shift(
            id: id, date: date,
            workplace: workplace.trimmingCharacters(in: .whitespacesAndNewlines),
            shiftTypeName: shiftTypeName,
            hoursWorked: validated(hoursWorked, field: "Hours worked", required: true),
            hourlyRate: validated(hourlyRate, field: "Hourly rate"),
            cashTips: validated(cashTips, field: "Cash tips"),
            cardTips: validated(cardTips, field: "Card tips"),
            tipOut: validated(tipOut, field: "Tip out")
        )
        guard shift.totalTips.isFinite, shift.hourlyEarnings.isFinite,
              shift.totalEarnings.isFinite else {
            throw ValidationError(message: "The amounts are too large. Please check your entries.")
        }
        return shift
    }

    struct ValidationError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }
}
