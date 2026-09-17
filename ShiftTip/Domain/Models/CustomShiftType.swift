//
//  CustomShiftType.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import Foundation

nonisolated struct CustomShiftType: Identifiable, Codable, Equatable {

    var id: UUID
    var name: String

    init(
        id: UUID = UUID(),
        name: String
    ) {
        self.id = id
        self.name = name
    }
}
