# ShiftTip

Native SwiftUI app for recording shifts, tips, workplaces, and earnings.

## Source organization

- `ShiftTip/App`: app entry point and tab navigation.
- `ShiftTip/Features`: screens and components grouped by user workflow.
- `ShiftTip/Domain/Models`: Codable records and per-shift earnings calculations.
- `ShiftTip/Data/Stores`: observable stores and existing UserDefaults persistence.
- `ShiftTip/Services/Export`: CSV and PDF generation.

History's calendar, detail screen, and rows are separate views. Add and Edit Shift
share `ShiftDraft` for validation and earnings previews, and `ShiftTipsSection`
for tip entry. Other fields remain specific to each screen.

When saving, hours must be positive. Blank rate/tip fields mean zero; malformed,
negative, nonfinite, or overflowing values produce an error before store mutation.
The parser accepts the locale's decimal separator. Saved records retain their
existing JSON schema; this refactor does not migrate storage.

The source directory is an Xcode filesystem-synchronized group, so new Swift files
inside it are discovered automatically.

## Verification

Open `ShiftTip.xcodeproj` and build the ShiftTip scheme for an iOS simulator.

The focused domain checks can also run without a simulator or XCTest target:

```sh
swiftc ShiftTip/Domain/Models/Shift.swift \
  ShiftTip/Features/Shifts/ShiftDraft.swift \
  Tests/ShiftDraftTests.swift -o /tmp/shifttip-draft-tests
/tmp/shifttip-draft-tests
```

Manual checks: add a shift, edit it, try invalid numeric input, browse History and
its calendar/detail screens, and verify totals. Existing saved shifts should load.

`Domain/EarningsSummary.swift` supplies totals and weighted hourly averages for
Dashboard, Analytics (including workplace/type groups), History, and PDF reports.
Run its focused checks with:

```sh
swiftc ShiftTip/Domain/Models/Shift.swift \
  ShiftTip/Domain/EarningsSummary.swift \
  Tests/EarningsSummaryTests.swift -o /tmp/shifttip-summary-tests
/tmp/shifttip-summary-tests
```

Report filenames use a Gregorian date in the local timezone. CSV and PDF exports
preserve custom shift-type names. PDF text is fixed black on white pages.

```sh
swiftc ShiftTip/Domain/Models/Shift.swift \
  ShiftTip/Services/Export/CSVExporter.swift \
  ShiftTip/Services/Export/ReportFileName.swift \
  Tests/ReportExportTests.swift -o /tmp/shifttip-report-tests
/tmp/shifttip-report-tests
```

History exports are generated only after choosing a CSV/PDF menu action. The
selected shifts are captured before background generation; the menu is disabled
and shows progress until completion. Successful exports open the system share
sheet. Failures show an alert. Each report has its own temporary directory, which
is removed when sharing is dismissed or a canceled export finishes. Export model
and utility types are nonisolated so generation does not block the main actor.

Manual export checks: choose each all/filtered format, cancel and complete sharing,
verify custom shift names and black PDF text, and confirm filters can change
without changing the report already being generated.

## Storage failure handling

Stores load the existing UserDefaults JSON keys through `RecordRepository`.
Missing data is distinct from unreadable data. A failed load preserves the stored
bytes and blocks mutations until a successful retry. Shift-type defaults are used
only when no saved collection exists; a saved empty collection stays empty.

Mutations encode/write before publishing new observable values. Add/edit/delete
forms close or clear only when the store returns success. Error banners offer
Retry Loading for load failures; save failures retain form entries for retrying
Save. The persistence backend is injectable for deterministic failure tests.

UserDefaults does not report asynchronous disk-write errors, so this is not a
claim of durable disk-write confirmation. Atomic file/database persistence and
backup/restore remain future work.

```sh
swiftc ShiftTip/Data/Persistence/RecordStorage.swift \
  Tests/RecordStorageTests.swift -o /tmp/shifttip-storage-tests
/tmp/shifttip-storage-tests
```
