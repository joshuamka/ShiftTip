import SwiftUI
import UniformTypeIdentifiers

struct BackupView: View {
    @Environment(ShiftStore.self) private var shiftStore
    @Environment(WorkplaceStore.self) private var workplaceStore
    @Environment(ShiftTypeStore.self) private var shiftTypeStore
    @State private var exporting = false
    @State private var importing = false
    @State private var document: BackupDocument?
    @State private var pending: BackupPreview?
    @State private var message: String?
    @State private var recoveryFiles: [URL] = []

    private var unavailable: Bool {
        shiftStore.loadFailed || workplaceStore.loadFailed || shiftTypeStore.loadFailed
    }

    var body: some View {
        Form {
            Section("Back Up Your Data") {
                Text("Save shifts, workplaces, shift types, and settings in one restorable file.")
                Button("Save Backup", systemImage: "square.and.arrow.up") { prepareExport() }
                    .disabled(unavailable)
            }
            Section("Restore a Backup") {
                Text("Preview the backup first. Restore adds missing records and keeps your existing versions. Settings are optional.")
                Button("Choose Backup File", systemImage: "square.and.arrow.down") { importing = true }
                    .disabled(unavailable)
            }
            if unavailable {
                Section {
                    Text("Resolve the storage error using Retry Loading before creating or restoring a backup.")
                }
            }
            Section("Recovery Copies") {
                Text("A copy of your current data is saved before each restore. These copies stay on this device; save a backup to Files for protection outside the app.")
                if recoveryFiles.isEmpty {
                    Text("No recovery copies yet.").foregroundStyle(.secondary)
                }
                ForEach(recoveryFiles, id: \.self) { url in
                    Button {
                        review(url)
                    } label: {
                        Label(recoveryDate(url), systemImage: "clock.arrow.circlepath")
                    }
                    .disabled(unavailable)
                    .contextMenu {
                        Button("Save Copy to Files", systemImage: "square.and.arrow.up") {
                            do {
                                let data = try Data(contentsOf: url)
                                _ = try ShiftTipBackup.decode(data)
                                document = BackupDocument(data: data)
                                exporting = true
                            } catch { message = error.localizedDescription }
                        }
                    }
                }
            }
        }
        .navigationTitle("Backup & Restore")
        .onAppear { refreshRecoveryFiles() }
        .fileExporter(isPresented: $exporting, document: document, contentType: .json,
                      defaultFilename: ReportFileName.make(prefix: "ShiftTip-Backup", extensionName: "json")) { result in
            switch result {
            case .success: message = "Your backup was saved."
            case .failure(let error): message = error.localizedDescription
            }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url): review(url)
            case .failure(let error): message = error.localizedDescription
            }
        }
        .sheet(item: $pending) { preview in
            BackupPreviewView(preview: preview) { restoreSettings in
                try restore(preview, restoreSettings: restoreSettings)
            }
        }
        .alert("Backup & Restore", isPresented: Binding(
            get: { message != nil }, set: { if !$0 { message = nil } }
        )) {
            Button("OK") { message = nil }
        } message: { Text(message ?? "") }
    }

    private func snapshot() throws -> ShiftTipBackup {
        guard !unavailable else { throw BackupError.unavailable }
        return ShiftTipBackup(shifts: shiftStore.shifts, workplaces: workplaceStore.workplaces,
                              shiftTypes: shiftTypeStore.shiftTypes, settings: BackupSettings(defaults: .standard))
    }

    private func prepareExport() {
        do {
            document = BackupDocument(data: try snapshot().encoded())
            exporting = true
        } catch { message = error.localizedDescription }
    }

    private func review(_ url: URL) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size <= ShiftTipBackup.maximumFileSize else { throw BackupError.tooLarge }
            let incoming = try ShiftTipBackup.decode(Data(contentsOf: url))
            let current = try snapshot()
            let plan = try BackupRestorePlan(current: current, incoming: incoming, restoreSettings: false)
            pending = BackupPreview(current: current, incoming: incoming, plan: plan)
        } catch { message = error.localizedDescription }
    }

    private func restore(_ preview: BackupPreview, restoreSettings: Bool) throws {
        let current = try snapshot()
        guard try current.contentSignature() == preview.current.contentSignature() else { throw BackupError.changed }
        let plan = try BackupRestorePlan(current: current, incoming: preview.incoming, restoreSettings: restoreSettings)
        guard let domainName = Bundle.main.bundleIdentifier else { throw BackupError.unavailable }
        let defaults = UserDefaults.standard
        try BackupPersistence.restore(plan: plan, current: current,
            domain: defaults.persistentDomain(forName: domainName) ?? [:],
            recoveryDirectory: try recoveryDirectory()) { domain in
                defaults.setPersistentDomain(domain, forName: domainName)
            }
        shiftStore.reload()
        workplaceStore.reload()
        shiftTypeStore.reload()
        guard !unavailable else { throw BackupError.unavailable }
        refreshRecoveryFiles()
        pending = nil
        message = "Restore completed. Added \(plan.addedShifts) shifts, \(plan.addedWorkplaces) workplaces, and \(plan.addedShiftTypes) shift types."
    }

    private func recoveryDirectory() throws -> URL {
        try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                    appropriateFor: nil, create: true)
            .appendingPathComponent("ShiftTip/Recovery", isDirectory: true)
    }

    private func refreshRecoveryFiles() {
        do {
            let directory = try recoveryDirectory()
            guard FileManager.default.fileExists(atPath: directory.path) else {
                recoveryFiles = []
                return
            }
            recoveryFiles = try FileManager.default.contentsOfDirectory(at: directory,
                includingPropertiesForKeys: [.contentModificationDateKey])
                .filter { $0.pathExtension == "json" }
                .sorted { modifiedDate($0) > modifiedDate($1) }
        } catch { message = "Could not read recovery copies: \(error.localizedDescription)" }
    }

    private func modifiedDate(_ url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
    }

    private func recoveryDate(_ url: URL) -> String {
        modifiedDate(url).formatted(date: .abbreviated, time: .standard)
    }
}

struct BackupPreview: Identifiable {
    let id = UUID()
    let current: ShiftTipBackup
    let incoming: ShiftTipBackup
    let plan: BackupRestorePlan
}

private struct BackupPreviewView: View {
    let preview: BackupPreview
    let restore: (Bool) throws -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var restoreSettings = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Backup") {
                    LabeledContent("Created", value: preview.incoming.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
                Section("Records to Add") {
                    LabeledContent("Shifts", value: "\(preview.plan.addedShifts)")
                    LabeledContent("Workplaces", value: "\(preview.plan.addedWorkplaces)")
                    LabeledContent("Shift types", value: "\(preview.plan.addedShiftTypes)")
                }
                Section("Existing Records Kept") {
                    LabeledContent("Shifts", value: "\(preview.plan.skippedShifts)")
                    LabeledContent("Workplaces", value: "\(preview.plan.skippedWorkplaces)")
                    LabeledContent("Shift types", value: "\(preview.plan.skippedShiftTypes)")
                    Text("Matching shift IDs are skipped, even if their values differ. Existing records are never replaced. Workplaces and shift types also match by name.")
                }
                Section("Settings") {
                    Toggle("Restore Settings", isOn: $restoreSettings)
                    Text("Replaces your default workplace, rate, shift type, tip goals, and welcome preference with the backup's settings.")
                    if restoreSettings {
                        LabeledContent("Default workplace", value: preview.incoming.settings.defaultWorkplace)
                        LabeledContent("Hourly rate", value: preview.incoming.settings.defaultHourlyRate)
                        LabeledContent("Shift type", value: preview.incoming.settings.defaultShiftType)
                        LabeledContent("Weekly tip goal", value: preview.incoming.settings.weeklyTipGoal)
                        LabeledContent("Monthly tip goal", value: preview.incoming.settings.monthlyTipGoal)
                    }
                }
                Section {
                    Text("A recovery copy of your current data will be saved first. Recovery copies use the same merge rules; they do not undo newly added records.")
                    Button("Restore Backup") {
                        do { try restore(restoreSettings) }
                        catch { errorMessage = error.localizedDescription }
                    }
                }
            }
            .navigationTitle("Review Restore")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
            .alert("Restore Failed", isPresented: Binding(
                get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }
}
