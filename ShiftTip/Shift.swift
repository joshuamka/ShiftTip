//
//  Shift.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/3/26.
//


import Foundation

enum ShiftType: String, Codable, CaseIterable, Identifiable {

    case brunch = "Brunch"
    case day = "Day"
    case night = "Night"
    case other = "Other"

    var id: String {
        rawValue
    }
}

struct Shift: Identifiable, Codable {

    var id: UUID = UUID()

    var date: Date

    var workplace: String = ""

    var shiftTypeName: String = "Other"

    var hoursWorked: Double

    var hourlyRate: Double

    var cashTips: Double

    var cardTips: Double

    var tipOut: Double

    // MARK: - Legacy Shift Type Compatibility

    var shiftType: ShiftType {

        get {
            ShiftType(
                rawValue: shiftTypeName
            ) ?? .other
        }

        set {
            shiftTypeName = newValue.rawValue
        }
    }

    // MARK: - Calculations

    var totalTips: Double {
        cashTips + cardTips - tipOut
    }

    var hourlyEarnings: Double {
        hoursWorked * hourlyRate
    }

    var totalEarnings: Double {
        hourlyEarnings + totalTips
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {

        case id
        case date
        case workplace
        case shiftType
        case hoursWorked
        case hourlyRate
        case cashTips
        case cardTips
        case tipOut
    }

    // MARK: - Existing Initializer

    init(
        id: UUID = UUID(),
        date: Date,
        workplace: String = "",
        shiftType: ShiftType = .other,
        hoursWorked: Double,
        hourlyRate: Double,
        cashTips: Double,
        cardTips: Double,
        tipOut: Double
    ) {

        self.id = id
        self.date = date
        self.workplace = workplace
        self.shiftTypeName = shiftType.rawValue
        self.hoursWorked = hoursWorked
        self.hourlyRate = hourlyRate
        self.cashTips = cashTips
        self.cardTips = cardTips
        self.tipOut = tipOut
    }

    // MARK: - Custom Shift Type Initializer

    init(
        id: UUID = UUID(),
        date: Date,
        workplace: String = "",
        shiftTypeName: String,
        hoursWorked: Double,
        hourlyRate: Double,
        cashTips: Double,
        cardTips: Double,
        tipOut: Double
    ) {

        self.id = id
        self.date = date
        self.workplace = workplace

        let cleanedShiftTypeName =
            shiftTypeName.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        self.shiftTypeName =
            cleanedShiftTypeName.isEmpty
            ? "Other"
            : cleanedShiftTypeName

        self.hoursWorked = hoursWorked
        self.hourlyRate = hourlyRate
        self.cashTips = cashTips
        self.cardTips = cardTips
        self.tipOut = tipOut
    }

    // MARK: - Decode

    init(from decoder: Decoder) throws {

        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        id = try container.decodeIfPresent(
            UUID.self,
            forKey: .id
        ) ?? UUID()

        date = try container.decode(
            Date.self,
            forKey: .date
        )

        workplace = try container.decodeIfPresent(
            String.self,
            forKey: .workplace
        ) ?? ""

        shiftTypeName = try container.decodeIfPresent(
            String.self,
            forKey: .shiftType
        ) ?? "Other"

        hoursWorked = try container.decode(
            Double.self,
            forKey: .hoursWorked
        )

        hourlyRate = try container.decode(
            Double.self,
            forKey: .hourlyRate
        )

        cashTips = try container.decode(
            Double.self,
            forKey: .cashTips
        )

        cardTips = try container.decode(
            Double.self,
            forKey: .cardTips
        )

        tipOut = try container.decode(
            Double.self,
            forKey: .tipOut
        )
    }

    // MARK: - Encode

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(
            id,
            forKey: .id
        )

        try container.encode(
            date,
            forKey: .date
        )

        try container.encode(
            workplace,
            forKey: .workplace
        )

        try container.encode(
            shiftTypeName,
            forKey: .shiftType
        )

        try container.encode(
            hoursWorked,
            forKey: .hoursWorked
        )

        try container.encode(
            hourlyRate,
            forKey: .hourlyRate
        )

        try container.encode(
            cashTips,
            forKey: .cashTips
        )

        try container.encode(
            cardTips,
            forKey: .cardTips
        )

        try container.encode(
            tipOut,
            forKey: .tipOut
        )
    }
}
