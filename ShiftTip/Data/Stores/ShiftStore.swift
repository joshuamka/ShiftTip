import Foundation
import Observation

@Observable
final class ShiftStore {
    private(set) var shifts: [Shift] = []
    private(set) var errorMessage: String?
    private(set) var loadFailed = false
    @ObservationIgnored private let repository: RecordRepository<Shift>

    init(storage: RecordStorage = .defaults()) {
        repository = RecordRepository(key: "savedShifts", storage: storage)
        reload()
    }

    func reload() {
        do {
            let loaded = try repository.load()
            shifts = loaded ?? []
            loadFailed = false
            errorMessage = nil
        } catch {
            loadFailed = true
            errorMessage = "Could not load shifts. Existing saved data has been left untouched. Changes are blocked until loading succeeds."
        }
    }

    @discardableResult
    private func commit(_ updated: [Shift]) -> Bool {
        guard !loadFailed else { return false }
        do {
            try repository.save(updated)
            shifts = updated
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Could not save shifts. Your changes were not applied. Keep your entries and try again."
            return false
        }
    }

    @discardableResult
    func addShift(_ shift: Shift) -> Bool { commit(shifts + [shift]) }

    @discardableResult
    func deleteShift(_ shift: Shift) -> Bool { commit(shifts.filter { $0.id != shift.id }) }

    @discardableResult
    func updateShift(_ shift: Shift) -> Bool {
        guard let index = shifts.firstIndex(where: { $0.id == shift.id }) else {
            errorMessage = "This shift is no longer available. Your edits have not been saved."
            return false
        }
        var updated = shifts
        updated[index] = shift
        return commit(updated)
    }
}
