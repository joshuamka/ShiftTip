import Foundation

nonisolated struct BackupRestorePlan {
    let result: ShiftTipBackup
    let addedShifts: Int
    let addedWorkplaces: Int
    let addedShiftTypes: Int
    let skippedShifts: Int
    let skippedWorkplaces: Int
    let skippedShiftTypes: Int

    init(current: ShiftTipBackup, incoming: ShiftTipBackup, restoreSettings: Bool) throws {
        try current.validate()
        try incoming.validate()
        let shiftIDs = Set(current.shifts.map(\.id))
        let workplaceIDs = Set(current.workplaces.map(\.id))
        let typeIDs = Set(current.shiftTypes.map(\.id))
        let shifts = incoming.shifts.filter { !shiftIDs.contains($0.id) }
        // Names are the references in the current data model; don't introduce duplicate choices.
        func nameKey(_ name: String) -> String { name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        var workplaceNames = Set(current.workplaces.map { nameKey($0.name) })
        let workplaces = incoming.workplaces.filter {
            !workplaceIDs.contains($0.id) && workplaceNames.insert(nameKey($0.name)).inserted
        }
        var typeNames = Set(current.shiftTypes.map { nameKey($0.name) })
        let types = incoming.shiftTypes.filter {
            !typeIDs.contains($0.id) && typeNames.insert(nameKey($0.name)).inserted
        }
        addedShifts = shifts.count
        addedWorkplaces = workplaces.count
        addedShiftTypes = types.count
        skippedShifts = incoming.shifts.count - shifts.count
        skippedWorkplaces = incoming.workplaces.count - workplaces.count
        skippedShiftTypes = incoming.shiftTypes.count - types.count
        result = ShiftTipBackup(shifts: current.shifts + shifts,
                                workplaces: current.workplaces + workplaces,
                                shiftTypes: current.shiftTypes + types,
                                settings: restoreSettings ? incoming.settings : current.settings)
    }
}

nonisolated enum BackupPersistence {
    /// Stage all encoding and a durable recovery file before changing defaults.
    /// One domain update avoids sequential updates to the three record keys.
    static func restore(plan: BackupRestorePlan, current: ShiftTipBackup,
                        domain: [String: Any], recoveryDirectory: URL,
                        commit: ([String: Any]) throws -> Void) throws {
        _ = try plan.result.encoded() // Ensure the merged result can itself be backed up.
        var updated = domain
        let encoder = JSONEncoder()
        updated["savedShifts"] = try encoder.encode(plan.result.shifts)
        updated["savedWorkplaces"] = try encoder.encode(plan.result.workplaces)
        updated["savedCustomShiftTypes"] = try encoder.encode(plan.result.shiftTypes)
        plan.result.settings.apply(to: &updated)
        let recovery = try current.encoded()
        try FileManager.default.createDirectory(at: recoveryDirectory, withIntermediateDirectories: true)
        let url = recoveryDirectory.appendingPathComponent("ShiftTip-before-restore-\(UUID()).json")
        try recovery.write(to: url, options: .atomic)
        try commit(updated)
    }
}
