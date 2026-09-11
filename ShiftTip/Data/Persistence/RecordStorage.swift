import Foundation

/// Keeps the existing JSON keys. UserDefaults acknowledges an in-process update,
/// but does not expose asynchronous disk-write failures.
nonisolated struct RecordStorage {
    var read: (String) throws -> Data?
    var write: (Data, String) throws -> Void

    static func defaults(_ defaults: UserDefaults = .standard) -> Self {
        Self(read: { key in
            guard let object = defaults.object(forKey: key) else { return nil }
            guard let data = object as? Data else { throw StorageError.invalidData }
            return data
        }, write: { data, key in
            defaults.set(data, forKey: key)
        })
    }

    enum StorageError: Error { case invalidData }
}

/// A failed load must never be treated as an empty collection ready to overwrite.
nonisolated final class RecordRepository<Record: Codable> {
    private let storage: RecordStorage
    private let key: String
    private var canWrite = false

    init(key: String, storage: RecordStorage) {
        self.key = key
        self.storage = storage
    }

    func load() throws -> [Record]? {
        canWrite = false
        guard let data = try storage.read(key) else {
            canWrite = true
            return nil
        }
        let records = try JSONDecoder().decode([Record].self, from: data)
        canWrite = true
        return records
    }

    func save(_ records: [Record]) throws {
        guard canWrite else { throw RecordStorage.StorageError.invalidData }
        let data = try JSONEncoder().encode(records)
        try storage.write(data, key)
    }
}
