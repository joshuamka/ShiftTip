//
//  CSVExporter.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import Foundation

nonisolated struct CSVExporter {

    static func createCSV(
        from shifts: [Shift],
        fileName: String
    ) -> URL? {

        let sortedShifts = shifts.sorted {
            $0.date > $1.date
        }

        var csv = "Date,Workplace,Shift Type,Hours Worked,Hourly Rate,Cash Tips,Card Tips,Tip Out,Total Tips,Hourly Pay,Total Earnings\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for shift in sortedShifts {

            let date = dateFormatter.string(
                from: shift.date
            )

            let row = [
                date,
                escapeCSV(shift.workplace),
                escapeCSV(shift.shiftTypeName),
                formatNumber(shift.hoursWorked),
                formatNumber(shift.hourlyRate),
                formatNumber(shift.cashTips),
                formatNumber(shift.cardTips),
                formatNumber(shift.tipOut),
                formatNumber(shift.totalTips),
                formatNumber(shift.hourlyEarnings),
                formatNumber(shift.totalEarnings)
            ]

            csv += row.joined(separator: ",")
            csv += "\n"
        }

        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(fileName)

        do {

            try csv.write(
                to: url,
                atomically: true,
                encoding: .utf8
            )

            return url

        } catch {

            print(
                "CSV Export Error: \(error.localizedDescription)"
            )

            return nil
        }
    }

    private static func formatNumber(
        _ value: Double
    ) -> String {

        String(
            format: "%.2f",
            value
        )
    }

    private static func escapeCSV(
        _ value: String
    ) -> String {

        let escaped = value.replacingOccurrences(
            of: "\"",
            with: "\"\""
        )

        if escaped.contains(",") ||
            escaped.contains("\"") ||
            escaped.contains("\n") {

            return "\"\(escaped)\""
        }

        return escaped
    }
}
