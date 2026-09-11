import Foundation

nonisolated enum ReportFileName {
    static func make(
        prefix: String,
        extensionName: String,
        date: Date = Date(),
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(prefix)-\(formatter.string(from: date)).\(extensionName)"
    }
}
