//
//  AddWorkplaceView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import SwiftUI

struct AddWorkplaceView: View {

    @Environment(WorkplaceStore.self)
    private var workplaceStore

    @Environment(\.dismiss)
    private var dismiss

    @State private var name = ""
    @State private var hourlyRate = ""

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 22) {

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        Text("Add Workplace")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(
                            "Save a restaurant, bar, nightclub, hotel, or any other place where you work."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    workplaceCard

                    saveButton
                }
                .padding(18)
            }
            .background(
                Color(.systemGroupedBackground)
            )
            .navigationTitle("New Workplace")
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

            saveWorkplace()

        } label: {

            HStack {

                Image(
                    systemName: "checkmark.circle.fill"
                )

                Text("Save Workplace")
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

    private func saveWorkplace() {

        workplaceStore.addWorkplace(
            name: name,
            hourlyRate: Double(hourlyRate) ?? 0
        )

        dismiss()
    }
}

#Preview {

    AddWorkplaceView()
        .environment(
            WorkplaceStore()
        )
}
