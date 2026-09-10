//
//  ShiftStore.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import Foundation
import SwiftUI
import Observation

@Observable
class ShiftStore {

    var shifts: [Shift] = [] {
        didSet {
            saveShifts()
        }
    }

    private let saveKey = "savedShifts"

    init() {
        loadShifts()
    }

    func addShift(_ shift: Shift) {
        shifts.append(shift)
    }

    func deleteShift(_ shift: Shift) {
        shifts.removeAll { $0.id == shift.id }
    }

    func updateShift(_ updatedShift: Shift) {
        guard let index = shifts.firstIndex(where: { $0.id == updatedShift.id }) else {
            return
        }

        shifts[index] = updatedShift
    }

    private func saveShifts() {
        if let encoded = try? JSONEncoder().encode(shifts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadShifts() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Shift].self, from: data)
        else {
            return
        }

        shifts = decoded
    }
}
