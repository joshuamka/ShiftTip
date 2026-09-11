//
//  Untitled.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import SwiftUI

struct AddShiftTypeView: View {

    @Environment(ShiftTypeStore.self)
    private var shiftTypeStore

    @Environment(\.dismiss)
    private var dismiss

    @State private var name = ""

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 22) {

                    header

                    shiftTypeCard

                    saveButton
                }
                .padding(18)
            }
            .background(
                Color(.systemGroupedBackground)
            )
            .navigationTitle("New Shift Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .storageStatus(message: shiftTypeStore.errorMessage,
                       canReload: shiftTypeStore.loadFailed,
                       reload: { shiftTypeStore.reload() })
    }

    // MARK: - Header

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("Add Shift Type")
                .font(.title2)
                .fontWeight(.bold)

            Text(
                "Create a shift type that matches the way you work."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Shift Type Card

    private var shiftTypeCard: some View {

        HStack(spacing: 12) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 8
                )
                .fill(
                    accentColor.opacity(0.10)
                )
                .frame(
                    width: 34,
                    height: 34
                )

                Image(
                    systemName: "clock.fill"
                )
                .foregroundStyle(
                    accentColor
                )
            }

            Text("Name")

            Spacer()

            TextField(
                "Example: Brunch",
                text: $name
            )
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: 190)
        }
        .padding(18)
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(
                Color(.secondarySystemGroupedBackground)
            )
        )
    }

    // MARK: - Save Button

    private var saveButton: some View {

        Button {

            saveShiftType()

        } label: {

            HStack {

                Image(
                    systemName: "checkmark.circle.fill"
                )

                Text("Save Shift Type")
                    .fontWeight(.bold)

                Spacer()

                Image(
                    systemName: "arrow.right"
                )
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(height: 58)
            .background(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .fill(accentColor)
            )
        }
        .buttonStyle(.plain)
        .disabled(
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
        )
        .opacity(
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty ? 0.5 : 1
        )
    }

    // MARK: - Save Shift Type

    private func saveShiftType() {

        let cleanedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedName.isEmpty else {
            return
        }

        guard shiftTypeStore.addShiftType(
            name: cleanedName
        ) else { return }

        dismiss()
    }
}

#Preview {

    AddShiftTypeView()
        .environment(
            ShiftTypeStore()
        )
}
