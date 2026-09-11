//
//  ShiftTypesView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import SwiftUI

struct ShiftTypesView: View {

    @Environment(ShiftTypeStore.self)
    private var shiftTypeStore

    @State private var showingAddShiftType = false
    @State private var shiftTypeToEdit: CustomShiftType?

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                header

                if shiftTypeStore.shiftTypes.isEmpty {
                    emptyState
                } else {
                    shiftTypeList
                }

                addButton
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 35)
        }
        .background(
            Color(.systemGroupedBackground)
        )
        .navigationTitle("Shift Types")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(
            isPresented: $showingAddShiftType
        ) {
            AddShiftTypeView()
        }
        .sheet(
            item: $shiftTypeToEdit
        ) { shiftType in

            EditShiftTypeView(
                shiftType: shiftType
            )
        }
    }

    // MARK: - Header

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 5
        ) {

            Text("Your Shift Types")
                .font(.title2)
                .fontWeight(.bold)

            Text(
                "Create shift types that match the way you work."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {

        VStack(spacing: 16) {

            Image(
                systemName: "clock.badge.checkmark"
            )
            .font(
                .system(size: 48)
            )
            .foregroundStyle(
                accentColor
            )

            Text("No Shift Types")
                .font(.headline)

            Text(
                "Add a shift type to organize your work schedule."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(28)
        .background(
            cardBackground
        )
    }

    // MARK: - Shift Type List

    private var shiftTypeList: some View {

        VStack(spacing: 12) {

            ForEach(
                shiftTypeStore.shiftTypes
            ) { shiftType in

                Button {

                    shiftTypeToEdit = shiftType

                } label: {

                    HStack(spacing: 14) {

                        ZStack {

                            RoundedRectangle(
                                cornerRadius: 10
                            )
                            .fill(
                                accentColor.opacity(0.10)
                            )
                            .frame(
                                width: 44,
                                height: 44
                            )

                            Image(
                                systemName: icon(
                                    for: shiftType.name
                                )
                            )
                            .foregroundStyle(
                                accentColor
                            )
                        }

                        Text(
                            shiftType.name
                        )
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                        Spacer()

                        Image(
                            systemName: "chevron.right"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(
                        cardBackground
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Add Button

    private var addButton: some View {

        Button {

            showingAddShiftType = true

        } label: {

            HStack {

                Image(
                    systemName: "plus.circle.fill"
                )

                Text("Add Shift Type")
                    .fontWeight(.bold)

                Spacer()

                Image(
                    systemName: "arrow.right"
                )
            }
            .foregroundStyle(.white)
            .padding(
                .horizontal,
                20
            )
            .frame(
                height: 58
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .fill(
                    accentColor
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Icon

    private func icon(
        for name: String
    ) -> String {

        switch name.lowercased() {

        case "morning":
            return "sunrise.fill"

        case "day":
            return "sun.max.fill"

        case "evening":
            return "sunset.fill"

        case "night":
            return "moon.stars.fill"

        default:
            return "clock.fill"
        }
    }

    // MARK: - Card Background

    private var cardBackground: some View {

        RoundedRectangle(
            cornerRadius: 18,
            style: .continuous
        )
        .fill(
            Color(
                .secondarySystemGroupedBackground
            )
        )
    }
}

#Preview {

    NavigationStack {

        ShiftTypesView()
    }
    .environment(
        ShiftTypeStore()
    )
}
