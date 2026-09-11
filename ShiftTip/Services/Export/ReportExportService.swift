import Foundation

nonisolated enum ReportFormat: String, Sendable {
    case csv, pdf
}

nonisolated struct PreparedReport: Identifiable, Sendable {
    let id = UUID()
    let url: URL
}

nonisolated enum ReportExportService {
    static func create(shifts: [Shift], format: ReportFormat, filtered: Bool) async throws -> PreparedReport {
        try await Task.detached(priority: .userInitiated) {
            let prefix: String
            switch (format, filtered) {
            case (.csv, false): prefix = "ShiftTip-All-Shifts"
            case (.csv, true): prefix = "ShiftTip-Filtered-Shifts"
            case (.pdf, false): prefix = "ShiftTip-Earnings-Report"
            case (.pdf, true): prefix = "ShiftTip-Filtered-Report"
            }
            // Isolate each export so an open share sheet's file cannot be overwritten.
            let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            do {
                let filename = ReportFileName.make(prefix: prefix, extensionName: format.rawValue)
                let path = directory.lastPathComponent + "/" + filename
                let url: URL?
                switch format {
                case .csv: url = CSVExporter.createCSV(from: shifts, fileName: path)
                case .pdf: url = PDFExporter.createPDF(from: shifts, fileName: path)
                }
                guard let url else { throw ExportError() }
                return PreparedReport(url: url)
            } catch {
                try? FileManager.default.removeItem(at: directory)
                throw error
            }
        }.value
    }

    private struct ExportError: LocalizedError {
        var errorDescription: String? { "The report could not be created. Please try exporting again." }
    }
}
