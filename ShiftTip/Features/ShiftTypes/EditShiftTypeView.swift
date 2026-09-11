//
//  EditShiftTypeView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import SwiftUI

struct EditShiftTypeView: View {

    @Environment(ShiftTypeStore.self)
    private var shiftTypeStore

    @Environment(\.dismiss)
    private var dismiss

    let shiftType: CustomShiftType

    @State private var name: String
    @State private var showDeleteConfirmation = false

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    init(shiftType: CustomShiftType) {
        self.shiftType = shiftType
        _name = State(initialValue: shiftType.name)
    }

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 22) {

                    header

                    shiftTypeCard

                    saveButton

                    deleteButton
                }
                .padding(18)
            }
            .background(
                Color(.systemGroupedBackground)
            )
            .navigationTitle("Edit Shift Type")
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

            Text("Edit Shift Type")
                .font(.title2)
                .fontWeight(.bold)

            Text(
                "Change the name or delete this shift type."
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
                "Shift Type",
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

            saveChanges()

        } label: {

            HStack {

                Image(
                    systemName: "checkmark.circle.fill"
                )

                Text("Save Changes")
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

    // MARK: - Delete Button

    private var deleteButton: some View {

        Button {

            showDeleteConfirmation = true

        } label: {

            HStack {

                Image(
                    systemName: "trash.fill"
                )

                Text("Delete Shift Type")
                    .fontWeight(.bold)

                Spacer()
            }
            .foregroundStyle(.red)
            .padding(.horizontal, 20)
            .frame(height: 58)
            .background(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .fill(
                    Color.red.opacity(0.10)
                )
            )
        }
        .buttonStyle(.plain)
        .confirmationDialog(
            "Delete this shift type?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {

            Button(
                "Delete Shift Type",
                role: .destructive
            ) {

                deleteShiftType()
            }

            Button(
                "Cancel",
                role: .cancel
            ) {
            }

        } message: {

            Text(
                "Existing shifts will not be deleted."
            )
        }
    }

    // MARK: - Save Changes

    private func saveChanges() {

        let cleanedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedName.isEmpty else {
            return
        }

        let updatedShiftType = CustomShiftType(
            id: shiftType.id,
            name: cleanedName
        )

        guard shiftTypeStore.updateShiftType(
            updatedShiftType
        ) else { return }

        dismiss()
    }

    // MARK: - Delete Shift Type

    private func deleteShiftType() {

        guard shiftTypeStore.deleteShiftType(
            shiftType
        ) else { return }

        dismiss()
    }
}

#Preview {

    EditShiftTypeView(
        shiftType: CustomShiftType(
            name: "Dinner"
        )
    )
    .environment(
        ShiftTypeStore()
    )
}
