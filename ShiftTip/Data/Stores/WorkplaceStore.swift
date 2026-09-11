import Foundation
import Observation

@Observable
final class WorkplaceStore {
    private(set) var workplaces: [Workplace] = []
    private(set) var errorMessage: String?
    private(set) var loadFailed = false
    @ObservationIgnored private let repository: RecordRepository<Workplace>

    init(storage: RecordStorage = .defaults()) {
        repository = RecordRepository(key: "savedWorkplaces", storage: storage)
        reload()
    }

    func reload() {
        do {
            let loaded = try repository.load()
            workplaces = loaded ?? []
            loadFailed = false
            errorMessage = nil
        } catch {
            loadFailed = true
            errorMessage = "Could not load workplaces. Existing saved data has been left untouched. Changes are blocked until loading succeeds."
        }
    }

    @discardableResult
    private func commit(_ updated: [Workplace]) -> Bool {
        guard !loadFailed else { return false }
        do {
            try repository.save(updated)
            workplaces = updated
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Could not save workplaces. Your changes were not applied. Keep your entries and try again."
            return false
        }
    }

    @discardableResult
    func addWorkplace(name: String, hourlyRate: Double) -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            errorMessage = "Enter a workplace name."
            return false
        }
        return commit(workplaces + [Workplace(name: name, hourlyRate: hourlyRate)])
    }

    @discardableResult
    func deleteWorkplace(_ workplace: Workplace) -> Bool {
        commit(workplaces.filter { $0.id != workplace.id })
    }

    @discardableResult
    func updateWorkplace(_ workplace: Workplace) -> Bool {
        guard let index = workplaces.firstIndex(where: { $0.id == workplace.id }) else {
            errorMessage = "This workplace is no longer available. Your edits have not been saved."
            return false
        }
        var updated = workplaces
        updated[index] = workplace
        return commit(updated)
    }
}
