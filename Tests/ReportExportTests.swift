import Foundation

@main
struct ReportExportTests {
    static func main() throws {
        let date = Date(timeIntervalSince1970: 0)
        let filename = ReportFileName.make(prefix: "ShiftTip-All-Shifts", extensionName: "csv",
                                           date: date, timeZone: TimeZone(secondsFromGMT: 0)!)
        precondition(filename == "ShiftTip-All-Shifts-1970-01-01.csv")
        let pdfName = ReportFileName.make(prefix: "ShiftTip-Filtered-Report", extensionName: "pdf",
                                          date: date, timeZone: TimeZone(secondsFromGMT: -28800)!)
        precondition(pdfName == "ShiftTip-Filtered-Report-1969-12-31.pdf")
        let shift = Shift(date: date, workplace: "Cafe, Downtown", shiftTypeName: "Private \"Event\"",
                          hoursWorked: 8, hourlyRate: 10, cashTips: 20, cardTips: 30, tipOut: 5)
        guard let url = CSVExporter.createCSV(from: [shift], fileName: "ShiftTip-test-\(UUID()).csv") else {
            fatalError("CSV export failed")
        }
        defer { try? FileManager.default.removeItem(at: url) }
        let csv = try String(contentsOf: url, encoding: .utf8)
        precondition(csv.contains("\"Cafe, Downtown\""))
        precondition(csv.contains("\"Private \"\"Event\"\"\""))
        precondition(csv.contains("45.00,80.00"))
        precondition(!csv.contains("Total Earnings"))
        precondition(!csv.contains("125.00"))
        precondition(csv.contains("Net Tips Paid After Shift,Estimated Gross Wages"))
        print("Report checks passed: dated filenames, timezone, custom shift names, CSV escaping, and totals.")
    }
}
