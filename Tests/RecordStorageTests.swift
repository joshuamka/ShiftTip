import Foundation

@main
struct RecordStorageTests {
    struct Record: Codable, Equatable { var amount: Double }
    enum Failure: Error { case disk }

    static func main() throws {
        var data: Data?
        var writes = 0
        var failWrite = false
        let storage = RecordStorage(read: { _ in data }, write: { updated, _ in
            if failWrite { throw Failure.disk }
            data = updated
            writes += 1
        })
        let repository = RecordRepository<Record>(key: "test", storage: storage)
        precondition(tryLoad(repository) == nil)
        precondition(writes == 0)
        try repository.save([Record(amount: 25)])
        precondition(tryLoad(repository) == [Record(amount: 25)])
        let saved = data
        failWrite = true
        do {
            try repository.save([Record(amount: 50)])
            fatalError("Expected write failure")
        } catch is Failure {}
        precondition(data == saved)
        failWrite = false
        do {
            try repository.save([Record(amount: .nan)])
            fatalError("Expected encoding failure")
        } catch is EncodingError {}
        precondition(data == saved)
        data = Data("corrupt records".utf8)
        let corrupt = data
        do {
            _ = try repository.load()
            fatalError("Expected decoding failure")
        } catch is DecodingError {}
        do {
            try repository.save([])
            fatalError("Must not overwrite unreadable data")
        } catch is RecordStorage.StorageError {}
        precondition(data == corrupt && writes == 1)
        data = saved
        _ = try repository.load()
        try repository.save([])
        precondition(tryLoad(repository) == []) // Empty is different from missing.

        let suite = "ShiftTipStorageTests-\(UUID())"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("wrong type", forKey: "test")
        let malformed = RecordRepository<Record>(key: "test", storage: .defaults(defaults))
        do {
            _ = try malformed.load()
            fatalError("Expected wrong-type failure")
        } catch is RecordStorage.StorageError {}
        precondition(defaults.string(forKey: "test") == "wrong type")
        print("Storage checks passed: round trip, failed writes, failed encoding, corrupt-data protection, retry, empty data, and wrong-type defaults.")
    }

    static func tryLoad(_ repository: RecordRepository<Record>) -> [Record]? {
        do { return try repository.load() }
        catch { fatalError("Unexpected load failure: \(error)") }
    }
}
