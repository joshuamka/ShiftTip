import Foundation

nonisolated struct BackupSettings: Codable {
    var defaultWorkplace: String
    var defaultHourlyRate: String
    var defaultShiftType: String
    var weeklyTipGoal: String
    var monthlyTipGoal: String
    var hasSeenWelcome: Bool

    init(defaults: UserDefaults) {
        defaultWorkplace = defaults.string(forKey: "defaultWorkplace") ?? ""
        defaultHourlyRate = defaults.string(forKey: "defaultHourlyRate") ?? ""
        defaultShiftType = defaults.string(forKey: "defaultShiftType") ?? "Night"
        weeklyTipGoal = defaults.string(forKey: "weeklyEarningsGoal") ?? ""
        monthlyTipGoal = defaults.string(forKey: "monthlyEarningsGoal") ?? ""
        hasSeenWelcome = defaults.bool(forKey: "hasSeenWelcome")
    }

    func apply(to domain: inout [String: Any]) {
        domain["defaultWorkplace"] = defaultWorkplace
        domain["defaultHourlyRate"] = defaultHourlyRate
        domain["defaultShiftType"] = defaultShiftType
        domain["weeklyEarningsGoal"] = weeklyTipGoal
        domain["monthlyEarningsGoal"] = monthlyTipGoal
        domain["hasSeenWelcome"] = hasSeenWelcome
    }
}

nonisolated struct ShiftTipBackup: Codable, Identifiable {
    static let maximumFileSize = 25 * 1_024 * 1_024
    var id: Date { createdAt }
    let format: String
    let version: Int
    let createdAt: Date
    let shifts: [Shift]
    let workplaces: [Workplace]
    let shiftTypes: [CustomShiftType]
    let settings: BackupSettings

    init(shifts: [Shift], workplaces: [Workplace], shiftTypes: [CustomShiftType], settings: BackupSettings) {
        format = "com.shifttip.backup"
        version = 1
        createdAt = Date()
        self.shifts = shifts
        self.workplaces = workplaces
        self.shiftTypes = shiftTypes
        self.settings = settings
    }

    static func decode(_ data: Data) throws -> Self {
        guard data.count <= maximumFileSize else { throw BackupError.tooLarge }
        do {
            let decoder = JSONDecoder()
            let header = try decoder.decode(Header.self, from: data)
            guard header.format == "com.shifttip.backup" else { throw BackupError.invalid }
            guard header.version == 1 else { throw BackupError.unsupportedVersion }
            // Shift's legacy decoder may invent missing IDs. Backups must not do so.
            _ = try decoder.decode(RequiredShiftIDs.self, from: data)
            let backup = try decoder.decode(Self.self, from: data)
            try backup.validate()
            return backup
        } catch let error as BackupError { throw error }
        catch { throw BackupError.invalid }
    }

    func encoded() throws -> Data {
        try validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        guard data.count <= Self.maximumFileSize else { throw BackupError.tooLarge }
        return data
    }

    func contentSignature() throws -> Data {
        guard var object = try JSONSerialization.jsonObject(with: encoded()) as? [String: Any] else { throw BackupError.invalid }
        object.removeValue(forKey: "createdAt")
        return try JSONSerialization.data(withJSONObject: object, options: .sortedKeys)
    }

    func validate() throws {
        guard format == "com.shifttip.backup", version == 1,
              createdAt.timeIntervalSince1970.isFinite,
              Set(shifts.map(\.id)).count == shifts.count,
              Set(workplaces.map(\.id)).count == workplaces.count,
              Set(shiftTypes.map(\.id)).count == shiftTypes.count else { throw BackupError.invalid }
        for shift in shifts {
            let numbers = [shift.hoursWorked, shift.hourlyRate, shift.cashTips, shift.cardTips, shift.tipOut]
            guard numbers.allSatisfy({ $0.isFinite && $0 >= 0 }),
                  shift.date.timeIntervalSince1970.isFinite,
                  shift.totalTips.isFinite, shift.hourlyEarnings.isFinite, shift.totalEarnings.isFinite,
                  shift.workplace.count <= 10_000, shift.shiftTypeName.count <= 10_000 else { throw BackupError.invalid }
        }
        guard workplaces.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.name.count <= 10_000 && $0.hourlyRate.isFinite && $0.hourlyRate >= 0 }),
              shiftTypes.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.name.count <= 10_000 }) else { throw BackupError.invalid }
        let preferences = [settings.defaultWorkplace, settings.defaultHourlyRate, settings.defaultShiftType, settings.weeklyTipGoal, settings.monthlyTipGoal]
        guard preferences.allSatisfy({ $0.count <= 10_000 }) else { throw BackupError.invalid }
    }

    private struct Header: Decodable { let format: String; let version: Int }
    private struct RequiredShiftIDs: Decodable {
        struct Record: Decodable { let id: UUID }
        let shifts: [Record]
    }
}

nonisolated enum BackupError: LocalizedError {
    case invalid, unsupportedVersion, tooLarge, unavailable, changed
    var errorDescription: String? {
        switch self {
        case .invalid: return "This is not a valid ShiftTip backup, or it contains invalid or duplicate records. Nothing was restored."
        case .unsupportedVersion: return "This backup uses an unsupported version. Update ShiftTip before trying again."
        case .tooLarge: return "This backup exceeds the 25 MB limit."
        case .unavailable: return "Resolve the current storage error before backing up or restoring."
        case .changed: return "Your records changed while the preview was open. Select the backup again to review the updated totals."
        }
    }
}
