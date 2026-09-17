import Foundation

@main
struct BackupTests {
    enum Failure: Error { case write }
    static func main() throws {
        let suite = "ShiftTipBackupTests-\(UUID())"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("250", forKey: "weeklyEarningsGoal")
        let settings = BackupSettings(defaults: defaults)
        let first = Shift(date: Date(), workplace: "Cafe", shiftTypeName: "Night", hoursWorked: 8,
                          hourlyRate: 15, cashTips: 30, cardTips: 70, tipOut: 10)
        let workplace = Workplace(name: "Cafe", hourlyRate: 15)
        let type = CustomShiftType(name: "Night")
        let current = ShiftTipBackup(shifts: [first], workplaces: [workplace], shiftTypes: [type], settings: settings)
        let decoded = try ShiftTipBackup.decode(current.encoded())
        precondition(decoded.shifts[0].id == first.id && decoded.settings.weeklyTipGoal == "250")
        var edited = first; edited.cashTips = 999
        let second = Shift(date: Date(), hoursWorked: 4, hourlyRate: 20, cashTips: 10, cardTips: 20, tipOut: 5)
        var importedSettings = settings; importedSettings.weeklyTipGoal = "500"
        let incoming = ShiftTipBackup(shifts: [edited, second],
            workplaces: [Workplace(name: "cafe", hourlyRate: 99)],
            shiftTypes: [CustomShiftType(name: "NIGHT")], settings: importedSettings)
        let plan = try BackupRestorePlan(current: current, incoming: incoming, restoreSettings: false)
        precondition(plan.addedShifts == 1 && plan.skippedShifts == 1)
        precondition(plan.addedWorkplaces == 0 && plan.addedShiftTypes == 0)
        precondition(plan.result.shifts[0].cashTips == 30 && plan.result.settings.weeklyTipGoal == "250")
        let again = try BackupRestorePlan(current: plan.result, incoming: incoming, restoreSettings: true)
        precondition(again.addedShifts == 0 && again.result.settings.weeklyTipGoal == "500")
        precondition(trySignature(current) == trySignature(decoded))
        precondition(trySignature(current) != trySignature(plan.result))

        func rejects(_ data: Data) {
            do { _ = try ShiftTipBackup.decode(data); fatalError("Invalid backup accepted") }
            catch is BackupError {} catch { fatalError("Unexpected error: \(error)") }
        }
        rejects(Data("not json".utf8))
        rejects(Data(repeating: 0, count: ShiftTipBackup.maximumFileSize + 1))
        var object = try JSONSerialization.jsonObject(with: current.encoded()) as! [String: Any]
        object["version"] = 999
        rejects(try JSONSerialization.data(withJSONObject: object))
        object["version"] = 1
        var records = object["shifts"] as! [[String: Any]]
        object["shifts"] = records + records
        rejects(try JSONSerialization.data(withJSONObject: object))
        records[0].removeValue(forKey: "id")
        object["shifts"] = records
        rejects(try JSONSerialization.data(withJSONObject: object))
        records[0]["id"] = first.id.uuidString; records[0]["hoursWorked"] = -1
        object["shifts"] = records
        rejects(try JSONSerialization.data(withJSONObject: object))

        let recovery = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: recovery) }
        var domain: [String: Any] = ["unrelatedSetting": "preserved"]
        try BackupPersistence.restore(plan: plan, current: current, domain: domain, recoveryDirectory: recovery) {
            domain = $0
        }
        defaults.setPersistentDomain(domain, forName: suite)
        let persisted = try JSONDecoder().decode([Shift].self, from: defaults.data(forKey: "savedShifts")!)
        precondition(persisted.count == 2 && defaults.string(forKey: "weeklyEarningsGoal") == "250")
        let restored = try JSONDecoder().decode([Shift].self, from: domain["savedShifts"] as! Data)
        precondition(restored.count == 2 && domain["unrelatedSetting"] as? String == "preserved")
        let recoveryFiles = try FileManager.default.contentsOfDirectory(at: recovery, includingPropertiesForKeys: nil)
        let savedBefore = try ShiftTipBackup.decode(Data(contentsOf: recoveryFiles[0]))
        precondition(savedBefore.shifts.count == 1 && savedBefore.shifts[0].cashTips == 30)
        var committed = false
        let blockedDirectory = recovery.appendingPathComponent("not-a-folder")
        try Data().write(to: blockedDirectory)
        do {
            try BackupPersistence.restore(plan: plan, current: current, domain: domain, recoveryDirectory: blockedDirectory) { _ in committed = true }
            fatalError("Expected recovery write failure")
        } catch { precondition(!committed) }
        do {
            try BackupPersistence.restore(plan: plan, current: current, domain: domain, recoveryDirectory: recovery) { _ in throw Failure.write }
            fatalError("Expected commit failure")
        } catch is Failure {}
        print("Backup checks passed: round trip, merge, duplicate prevention, settings choice, schema validation, recovery copy, and write failures.")
    }
    static func trySignature(_ backup: ShiftTipBackup) -> Data {
        do { return try backup.contentSignature() } catch { fatalError("Unexpected signature failure") }
    }
}
