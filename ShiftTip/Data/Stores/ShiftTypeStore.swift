import Foundation
import Observation

@Observable
final class ShiftTypeStore {
    private(set) var shiftTypes: [CustomShiftType] = []
    private(set) var errorMessage: String?
    private(set) var loadFailed = false
    @ObservationIgnored private let repository: RecordRepository<CustomShiftType>

    init(storage: RecordStorage = .defaults()) {
        repository = RecordRepository(key: "savedCustomShiftTypes", storage: storage)
        reload()
    }

    func reload() {
        do {
            let loaded = try repository.load()
            shiftTypes = loaded ?? ["Morning", "Day", "Evening", "Night", "Other"].map { CustomShiftType(name: $0) }
            loadFailed = false
            errorMessage = nil
        } catch {
            loadFailed = true
            errorMessage = "Could not load shift types. Existing saved data has been left untouched. Changes are blocked until loading succeeds."
        }
    }

    @discardableResult
    private func commit(_ updated: [CustomShiftType]) -> Bool {
        guard !loadFailed else { return false }
        do {
            try repository.save(updated)
            shiftTypes = updated
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Could not save shift types. Your changes were not applied. Keep your entries and try again."
            return false
        }
    }

    @discardableResult
    func addShiftType(name: String) -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validName(name, excluding: nil) else { return false }
        return commit(shiftTypes + [CustomShiftType(name: name)])
    }

    @discardableResult
    func updateShiftType(_ shiftType: CustomShiftType) -> Bool {
        let name = shiftType.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validName(name, excluding: shiftType.id) else { return false }
        guard let index = shiftTypes.firstIndex(where: { $0.id == shiftType.id }) else {
            errorMessage = "This shift type is no longer available. Your edits have not been saved."
            return false
        }
        var updated = shiftTypes
        updated[index] = CustomShiftType(id: shiftType.id, name: name)
        return commit(updated)
    }

    @discardableResult
    func deleteShiftType(_ shiftType: CustomShiftType) -> Bool {
        commit(shiftTypes.filter { $0.id != shiftType.id })
    }

    private func validName(_ name: String, excluding id: UUID?) -> Bool {
        guard !name.isEmpty else {
            errorMessage = "Enter a shift type name."
            return false
        }
        guard !shiftTypes.contains(where: {
            $0.id != id && $0.name.caseInsensitiveCompare(name) == .orderedSame
        }) else {
            errorMessage = "A shift type with this name already exists."
            return false
        }
        return true
    }
}
