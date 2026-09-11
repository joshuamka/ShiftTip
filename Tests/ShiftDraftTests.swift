import Foundation

@main
struct ShiftDraftTests {
    static func main() throws {
        let us = Locale(identifier: "en_US")
        var draft = ShiftDraft(date: Date(), workplace: " Cafe ", shiftTypeName: "Night",
                               hoursWorked: "8", hourlyRate: "15.50", cashTips: "40",
                               cardTips: "60", tipOut: "20")
        let id = UUID()
        let shift = try draft.makeShift(id: id, locale: us)
        precondition(shift.id == id && shift.workplace == "Cafe")
        precondition(shift.totalTips == 80 && shift.totalEarnings == 204)
        func rejects(_ input: ShiftDraft) {
            do {
                _ = try input.makeShift(locale: us)
                fatalError("Invalid draft was accepted")
            } catch is ShiftDraft.ValidationError {} catch {
                fatalError("Unexpected error: \(error)")
            }
        }
        for invalid in ["", "0", "-1", "oops", "nan", "inf"] {
            var bad = draft; bad.hoursWorked = invalid; rejects(bad)
        }
        for invalid in ["-1", "oops", "nan", "inf"] {
            var bad = draft; bad.cardTips = invalid; rejects(bad)
        }
        var overflow = draft
        overflow.hoursWorked = "1e308"; overflow.hourlyRate = "1e308"
        rejects(overflow)
        draft.hourlyRate = ""; draft.cashTips = ""; draft.cardTips = ""; draft.tipOut = ""
        let zero = try draft.makeShift(locale: us)
        precondition(zero.totalEarnings == 0)
        draft.hoursWorked = "7,5"; draft.hourlyRate = "12,50"
        let localized = try draft.makeShift(locale: Locale(identifier: "de_DE"))
        precondition(localized.hourlyEarnings == 93.75)
        let encoded = try JSONEncoder().encode(shift)
        let decoded = try JSONDecoder().decode(Shift.self, from: encoded)
        precondition(decoded.id == id && decoded.totalEarnings == shift.totalEarnings)
        print("Shift draft validation, calculations, identity, locale, and Codable checks passed.")
    }
}
