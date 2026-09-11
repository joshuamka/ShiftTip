//
//  WorkplaceStore.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import Foundation
import Observation

@Observable
class WorkplaceStore {

    var workplaces: [Workplace] = [] {
        didSet {
            saveWorkplaces()
        }
    }

    private let saveKey = "savedWorkplaces"

    init() {
        loadWorkplaces()
    }

    // MARK: - Add

    func addWorkplace(
        name: String,
        hourlyRate: Double
    ) {

        let cleanedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedName.isEmpty else {
            return
        }

        let workplace = Workplace(
            name: cleanedName,
            hourlyRate: hourlyRate
        )

        workplaces.append(workplace)
    }

    // MARK: - Delete

    func deleteWorkplace(
        _ workplace: Workplace
    ) {

        workplaces.removeAll {
            $0.id == workplace.id
        }
    }

    // MARK: - Update

    func updateWorkplace(
        _ updatedWorkplace: Workplace
    ) {

        guard let index = workplaces.firstIndex(
            where: {
                $0.id == updatedWorkplace.id
            }
        ) else {
            return
        }

        workplaces[index] = updatedWorkplace
    }

    // MARK: - Save

    private func saveWorkplaces() {

        guard let encoded = try? JSONEncoder().encode(
            workplaces
        ) else {
            return
        }

        UserDefaults.standard.set(
            encoded,
            forKey: saveKey
        )
    }

    // MARK: - Load

    private func loadWorkplaces() {

        guard
            let data = UserDefaults.standard.data(
                forKey: saveKey
            ),
            let decoded = try? JSONDecoder().decode(
                [Workplace].self,
                from: data
            )
        else {
            return
        }

        workplaces = decoded
    }
}
