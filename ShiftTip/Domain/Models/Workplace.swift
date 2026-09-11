//
//  Workplace.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import Foundation

struct Workplace: Identifiable, Codable, Equatable {

    var id: UUID
    var name: String
    var hourlyRate: Double

    init(
        id: UUID = UUID(),
        name: String,
        hourlyRate: Double = 0
    ) {
        self.id = id
        self.name = name
        self.hourlyRate = hourlyRate
    }
}
