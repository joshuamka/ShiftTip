//
//  WorkplacesView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/10/26.
//

import SwiftUI

struct WorkplacesView: View {

    @Environment(WorkplaceStore.self)
    private var workplaceStore

    @State private var showingAddWorkplace = false
    @State private var workplaceToEdit: Workplace?

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                header

                if workplaceStore.workplaces.isEmpty {

                    emptyState

                } else {

                    workplaceList
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
        .navigationTitle("Workplaces")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(
            isPresented: $showingAddWorkplace
        ) {

            AddWorkplaceView()
        }
        .sheet(
            item: $workplaceToEdit
        ) { workplace in

            EditWorkplaceView(
                workplace: workplace
            )
        }
    }

    // MARK: - Header

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 5
        ) {

            Text("Your Workplaces")
                .font(.title2)
                .fontWeight(.bold)

            Text(
                "Add the restaurants, bars, nightclubs, hotels, or other places where you work."
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
                systemName: "building.2.crop.circle"
            )
            .font(.system(size: 48))
            .foregroundStyle(
                accentColor
            )

            Text("No Workplaces Yet")
                .font(.headline)

            Text(
                "Add your first workplace to start building your personalized ShiftTip setup."
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

    // MARK: - Workplace List

    private var workplaceList: some View {

        VStack(spacing: 12) {

            ForEach(
                workplaceStore.workplaces
            ) { workplace in

                Button {

                    workplaceToEdit = workplace

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
                                systemName: "building.2.fill"
                            )
                            .foregroundStyle(
                                accentColor
                            )
                        }

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text(
                                workplace.name
                            )
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                .primary
                            )

                            if workplace.hourlyRate > 0 {

                                Text(
                                    workplace.hourlyRate,
                                    format: .currency(
                                        code: "USD"
                                    )
                                )
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )
                            } else {

                                Text(
                                    "Hourly rate not set"
                                )
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                        }

                        Spacer()

                        Image(
                            systemName: "chevron.right"
                        )
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
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

            showingAddWorkplace = true

        } label: {

            HStack {

                Image(
                    systemName: "plus.circle.fill"
                )

                Text("Add Workplace")
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
    }

    // MARK: - Background

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

        WorkplacesView()
    }
    .environment(
        WorkplaceStore()
    )
}
