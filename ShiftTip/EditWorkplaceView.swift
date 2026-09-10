//
//  EditWorkplaceView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import SwiftUI

struct EditWorkplaceView: View {

    @Environment(WorkplaceStore.self)
    private var workplaceStore

    @Environment(\.dismiss)
    private var dismiss

    let workplace: Workplace

    @State private var name: String
    @State private var hourlyRate: String
    @State private var showDeleteConfirmation = false

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    init(workplace: Workplace) {

        self.workplace = workplace

        _name = State(
            initialValue: workplace.name
        )

        _hourlyRate = State(
            initialValue:
                workplace.hourlyRate == 0
                ? ""
                : String(workplace.hourlyRate)
        )
    }

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 22) {

                    workplaceCard

                    saveButton

                    deleteButton
                }
                .padding(18)
            }
            .background(
                Color(.systemGroupedBackground)
            )
            .navigationTitle("Edit Workplace")
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
    }

    private var workplaceCard: some View {

        VStack(spacing: 0) {

            HStack(spacing: 12) {

                inputIcon(
                    "building.2.fill"
                )

                Text("Name")

                Spacer()

                TextField(
                    "Workplace",
                    text: $name
                )
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 180)
            }
            .padding(.vertical, 14)

            Divider()
                .padding(.leading, 42)

            HStack(spacing: 12) {

                inputIcon(
                    "dollarsign.circle.fill"
                )

                Text("Hourly Rate")

                Spacer()

                TextField(
                    "0.00",
                    text: $hourlyRate
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 120)
            }
            .padding(.vertical, 14)
        }
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(
                Color(
                    .secondarySystemGroupedBackground
                )
            )
        )
    }

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
            ).isEmpty
            ? 0.5
            : 1
        )
    }

    private var deleteButton: some View {

        Button {

            showDeleteConfirmation = true

        } label: {

            HStack {

                Image(
                    systemName: "trash.fill"
                )

                Text("Delete Workplace")
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
            "Delete this workplace?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {

            Button(
                "Delete Workplace",
                role: .destructive
            ) {

                workplaceStore.deleteWorkplace(
                    workplace
                )

                dismiss()
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

    private func inputIcon(
        _ icon: String
    ) -> some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: 8
            )
            .fill(
                accentColor.opacity(0.10)
            )
            .frame(
                width: 32,
                height: 32
            )

            Image(
                systemName: icon
            )
            .font(.caption)
            .foregroundStyle(
                accentColor
            )
        }
    }

    private func saveChanges() {

        let updatedWorkplace = Workplace(
            id: workplace.id,
            name: name.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            hourlyRate:
                Double(hourlyRate) ?? 0
        )

        workplaceStore.updateWorkplace(
            updatedWorkplace
        )

        dismiss()
    }
}

#Preview {

    EditWorkplaceView(
        workplace: Workplace(
            name: "Example Restaurant",
            hourlyRate: 18
        )
    )
    .environment(
        WorkplaceStore()
    )
}
