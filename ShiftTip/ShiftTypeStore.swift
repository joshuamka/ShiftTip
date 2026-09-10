//
//  ShiftTypeStore.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import Foundation
import Observation

@Observable
class ShiftTypeStore {

    var shiftTypes: [CustomShiftType] = [] {
        didSet {
            saveShiftTypes()
        }
    }

    private let saveKey = "savedCustomShiftTypes"

    init() {

        loadShiftTypes()

        if shiftTypes.isEmpty {
            createDefaultShiftTypes()
        }
    }

    // MARK: - Defaults

    private func createDefaultShiftTypes() {

        shiftTypes = [
            CustomShiftType(name: "Morning"),
            CustomShiftType(name: "Day"),
            CustomShiftType(name: "Evening"),
            CustomShiftType(name: "Night"),
            CustomShiftType(name: "Other")
        ]
    }

    // MARK: - Add

    func addShiftType(name: String) {

        let cleanedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedName.isEmpty else {
            return
        }

        let alreadyExists = shiftTypes.contains {
            $0.name.compare(
                cleanedName,
                options: .caseInsensitive
            ) == .orderedSame
        }

        guard !alreadyExists else {
            return
        }

        shiftTypes.append(
            CustomShiftType(
                name: cleanedName
            )
        )
    }

    // MARK: - Update

    func updateShiftType(
        _ updatedShiftType: CustomShiftType
    ) {

        guard let index = shiftTypes.firstIndex(
            where: {
                $0.id == updatedShiftType.id
            }
        ) else {
            return
        }

        let cleanedName =
            updatedShiftType.name
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        guard !cleanedName.isEmpty else {
            return
        }

        shiftTypes[index] = CustomShiftType(
            id: updatedShiftType.id,
            name: cleanedName
        )
    }

    // MARK: - Delete

    func deleteShiftType(
        _ shiftType: CustomShiftType
    ) {

        shiftTypes.removeAll {
            $0.id == shiftType.id
        }
    }

    // MARK: - Save

    private func saveShiftTypes() {

        guard let encoded = try? JSONEncoder().encode(
            shiftTypes
        ) else {
            return
        }

        UserDefaults.standard.set(
            encoded,
            forKey: saveKey
        )
    }

    // MARK: - Load

    private func loadShiftTypes() {

        guard
            let data = UserDefaults.standard.data(
                forKey: saveKey
            ),
            let decoded = try? JSONDecoder().decode(
                [CustomShiftType].self,
                from: data
            )
        else {
            return
        }

        shiftTypes = decoded
    }
}
